//
//  TGLOEventsAllViewController.m
//  Vic Greens
//
//  Created by andre on 8/05/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//



#import "TGLOEventsAllViewController.h"
#import "SWRevealViewController.h"
#import "AFNetworking.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "TGLOUtils.h"
#import "TGLOEventDetailsViewController.h"
#import "TGLOEventTableViewCell.h"
#import "TGLOAppDelegate.h"


static NSString * eventsUrl = @"https://cryptic-tundra-9564.herokuapp.com/events/all/%@/%@";

@interface TGLOEventsAllViewController () {
    
    //this is what the tableView will use to make rows.
    //when user makes a search this array will be filtered to hold
    //best matched events to search term
    NSMutableArray *searchResults;
    
    //this will always hold all of the searchResults. can use this
    //to cache or reset tableView to show all events
    NSArray *searchResultsCache;
    
    NSString *previousSearchTerm;
    
    NSMutableArray *undoStack;
}

@end

@implementation TGLOEventsAllViewController
@synthesize searchBar;
@synthesize tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //preserve selection between presentations.
    self.tableView.clearsContextBeforeDrawing = NO;
    
    searchBar.delegate = self;
    
    // Do any additional setup after loading the view.
    //since Lists tab hides our app wide nav bar
    //make sure it is NOT hidden before displaying
    //this view controllers' view
    [[[self navigationController] navigationBar] setHidden:NO];
    
    //use pull to refresh even without having a UITableViewController
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl]; //the trick
    
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    undoStack = [[NSMutableArray alloc] init];
    
    [self setUpAppearance];
    [self loadAllEventEntities];
}


-(void)setUpAppearance
{
    self.title = @"Search Events";
    // Change button color
    self.sidebarButton.tintColor = [UIColor colorWithWhite:0.05f alpha:1.0f];
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
}


- (void) loadAllEventEntities
{
    NSLog(@"in loadEventsFromDatabase method");
    //get all events and assign them to searchResults and searchResultsCache arrays
    
    TGLOAppDelegate *delegate = (TGLOAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = [delegate managedObjectContext];
    
    
    
    // Fetch the devices from persistent data store
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Event"];
    
    //an array of managedObjects of Entity type Event
    NSArray *fetchedEventsArray = [moc executeFetchRequest:fetchRequest error:nil];
    
    //first time visit to this 'page', automatically fetch events
    if ([fetchedEventsArray count] == 0) {
        [self getAllEvents:^(NSError *error, NSMutableArray *resultsArray ) {
            NSLog(@"in getAllEvents completionHandler, error: %@", error);
            
            if (error == nil) {
                NSLog(@"error is nil");
                
                
                [self saveAllEventEntities:resultsArray];
                
            }
            
            if (error) {
                NSLog(@"ERROR: %@", error);
                [self displayErrorAlert:@"Network Error" message:@"Unable to download events. Pleas try again."];
            }
        }];
        
    } else {
        [self populateSearchArrays:fetchedEventsArray];
    }
    
}

-(void)populateSearchArrays:(NSArray *)theArray
{
    __block NSMutableArray *extractedEvents = [[NSMutableArray alloc] init];
    
    [theArray enumerateObjectsUsingBlock:^(id obj, NSUInteger i, BOOL *stop) {
        
        NSString *quickDate = [TGLOUtils formattedDateStringFromDate:[obj valueForKey:@"startTime"]];
        
        NSDictionary *dic = @{ @"eventId":   [obj valueForKey:@"eventId"],
                               @"name":      [obj valueForKey:@"name"],
                               @"startTime": quickDate,
                               @"venue":     [obj valueForKey:@"venue"]
                               };
        
        [extractedEvents addObject:dic];
    }];
    
    searchResults = [extractedEvents mutableCopy];
    searchResultsCache = [[NSArray alloc] initWithArray:extractedEvents];
    
    [self sortResults];
}

     
     
- (void)sortResults
{
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startTime"
                                                 ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray;
    sortedArray = [searchResults sortedArrayUsingDescriptors:sortDescriptors];
    
    searchResults = [[NSMutableArray alloc] initWithArray:sortedArray];
    searchResultsCache = [[NSMutableArray alloc] initWithArray:sortedArray];
    
    [self.tableView reloadData];
}


//results is a mutable array of dics
- (void) saveAllEventEntities:(NSMutableArray *)results
{
    TGLOAppDelegate *delegate = (TGLOAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = [delegate managedObjectContext];
    
    
    
    //reset the database to empty
    //fetch em all and delete em all
    NSFetchRequest * allEvents = [[NSFetchRequest alloc] init];
    [allEvents setEntity:[NSEntityDescription entityForName:@"Event" inManagedObjectContext:moc]];
    [allEvents setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError * error = nil;
    NSArray * events = [moc executeFetchRequest:allEvents error:&error];
    
    //error handling goes here
    for (NSManagedObject * event in events) {
        [moc deleteObject:event];
    }
    
    //save delete all changes
    NSError *saveError = nil;
    if(![moc save:&saveError]) {
        NSLog(@"Can't Save reset! %@ %@", error, [error localizedDescription]);
        [self displayErrorAlert:@"Database Reset Error" message:@"Unable to reset database. Please try again."];
        return;
    }
    
    
    //add all new events now
    [results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        // Create a new managed object, new Event
        NSManagedObject *newE = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:moc];
        
        NSDate *date = [TGLOUtils formattedDateFromString:[obj valueForKey:@"startTime"] page:@"eventDetails"];
        
        
        [newE setValue:[obj valueForKey:@"eventId"] forKey:@"eventId"];
        [newE setValue:[obj valueForKey:@"name"] forKey:@"name"];
        [newE setValue:date forKey:@"startTime"];
        [newE setValue:[obj valueForKey:@"venue"] forKey:@"venue"];
        
        NSError *error = nil;
        // Save the object to persistent store
        if (![moc save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
            *stop = YES;
            [self displayErrorAlert:@"Database Error" message:@"Unable to save event to database. Please try again."];
            return;
        }
        
    }];
    
    [self loadAllEventEntities];
}




- (void)refresh:(UIRefreshControl *)refreshControl {
    NSLog(@"in refresh method");
    
    [self getAllEvents:^(NSError *error, NSMutableArray *resultsArray) {
        NSLog(@"in getAllEvents completionHandler, error: %@", error);
        [refreshControl endRefreshing];
        
        if (error == nil) {
            NSLog(@"error is nil");
            
            [self saveAllEventEntities:resultsArray];
        }
        
        if (error) {
            NSLog(@"ERROR: %@", error);
            [self displayErrorAlert:@"Network Error" message:@"Unable to download events. Pleas try again."];
        }
    }];
}


- (void)getAllEvents:(allEventsCompletionHandler)completionBlock
{
    
    NSString *myNBId = [TGLOUtils getUserNationBuilderId];
    NSString *accessToken = [TGLOUtils getUserAccessToken];
    NSString * eventsUrl_ = [NSString stringWithFormat:eventsUrl, myNBId, accessToken];
    __block NSError *error;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager GET:eventsUrl_ parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"EVENTS MODAL VIEW CONTROLLER and response for events: %@", responseObject);
        
        NSArray *results_array = [[responseObject objectForKey:@"events"] allObjects];
        NSMutableArray *results_array_mutable = [[NSMutableArray alloc] initWithArray:results_array];
        
        
        completionBlock(error, results_array_mutable);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
        error = [NSError errorWithDomain:@"GreensApp" code:1 userInfo:nil];
        completionBlock(error, nil);
    }];
}




- (void)displayErrorAlert:(NSString *)errorTitle message:(NSString *)message
{
    // show alert view saying we are getting token
    UIAlertView *alert =
    [[UIAlertView alloc]
     initWithTitle:errorTitle
     message:message
     delegate:nil
     cancelButtonTitle:@"Okay"
     otherButtonTitles:nil];
    
    [alert show];
}



- (IBAction)menuHit:(id)sender {
    //NSLog(@"menuHit action");
    [self.searchBar resignFirstResponder];
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    [self.revealViewController revealToggle:nil];
}




#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [searchResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *eventCellIdentifier = @"eventTableCell";
    NSDictionary *anEvent = [searchResults objectAtIndex:indexPath.row];
    //NSLog(@"anEvent: %@", anEvent);
    
    TGLOEventTableViewCell *cell = (TGLOEventTableViewCell *)[tableView dequeueReusableCellWithIdentifier:eventCellIdentifier];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TGLOEventTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    
    //set the text contents finally
    cell.dateLabel.text = [anEvent valueForKey:@"startTime"];
    cell.nameLabel.text = [anEvent objectForKey:@"name"];
    cell.venueLabel.text = [anEvent objectForKey:@"venue"];
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [self.searchBar resignFirstResponder];
    
    NSLog(@"selected event: %@", searchResults[ indexPath.row]);

    //manually call the segue giving its identifier string which is
    //set in storyboard
    [self performSegueWithIdentifier:@"showEventDetails" sender:self];
}


#pragma UISearchBarDelegate methods



- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    //NSLog(@"%@", searchText);
    NSInteger searchTextLength = [searchText length];
    NSInteger previousSearchTermLength = [previousSearchTerm length];
    
    
    
    if ([searchText isEqualToString:@""]) {
        //NSLog(@"searchText is empty String");
        
        //reload table with original all events array
        searchResults = [[NSMutableArray alloc] initWithArray:searchResultsCache];
        [[self tableView] reloadData];
        
        [undoStack removeAllObjects];
        previousSearchTerm = @"";
        
        
        //check we are bak to start
        for (int k = 0; k < [searchResultsCache count]; k++) {
            [searchResults containsObject:[searchResultsCache objectAtIndex:k]] ? nil: NSLog(@"ERROR: cache and searchResults not equal!");
        }
        
        return;
    }
    
    if (searchTextLength > previousSearchTermLength) {
        //NSLog(@"drilling down");
        //push removed objects to undo stack
        NSMutableArray *collectionOfEvents = [[NSMutableArray alloc] init];
        
        NSMutableIndexSet *removeEventsAtIndexes = [self getIndexSetOfMatches:searchText];
        
        
        NSArray *tempArray = [[NSArray alloc] initWithArray:searchResults];
        int tempArrayCount = [tempArray count];
        
        [searchResults removeObjectsAtIndexes:removeEventsAtIndexes];
        
        for (int j = 0; j < tempArrayCount; j++) {
            if (![searchResults containsObject:tempArray[j]]) {
                //add this to dic of undo stack
                [collectionOfEvents addObject:tempArray[j]];
            }
        }
        
        //commented out for the sake of easily poping undoStack
        //(at expense of adding empty arrays as last object...)
        /*
         //only add to undoStack nonempty array
         if (!![collectionOfEvents count]) {
         [undoStack addObject:collectionOfEvents];
         }
         */
        
        [undoStack addObject:collectionOfEvents];
        
        [[self tableView] reloadData];
        previousSearchTerm = searchText;
        
        //NSLog(@"pushing: %d objects to undoStack", [[undoStack lastObject ] count]);
        //NSLog(@"collectionOfEvents: %@", collectionOfEvents);
        //NSLog(@"undoStack: %@", undoStack);
        return;
    }
    
    if (searchTextLength < previousSearchTermLength) {
        //NSLog(@"drilling up");
        //pop objects off stack back onto searchResults
        
        //NSLog(@"searchResults count BEFORE POP: %d", [searchResults count]);
        [searchResults addObjectsFromArray:[undoStack lastObject]];
        //NSLog(@"poping: %d objects off undoStack", [[undoStack lastObject ] count]);
        
        [undoStack removeLastObject];
        //NSLog(@"searchResults count AFTER POP: %d", [searchResults count]);
        
        [[self tableView] reloadData];
        previousSearchTerm = searchText;
        return;
    }
}


- (NSMutableIndexSet *)getIndexSetOfMatches:(NSString *)searchTerm
{
    NSMutableIndexSet *indexes = [[NSMutableIndexSet alloc] init];
    int searchCount = [searchResults count];
    
    for (int i = 0; i < searchCount; i++) {
        NSString *tempName = [[searchResults[i] objectForKey:@"name"] lowercaseString];
        
        if ([tempName rangeOfString:[searchTerm lowercaseString]].location == NSNotFound) {
            //no match so add to index set
            [indexes addIndex:i];
            
        } else {
            //match, do nothing
            
        }
    }
    return indexes;
}



- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar_
{
    //NSLog(@"searchBar SEARCH clicked");
    [searchBar_ resignFirstResponder];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showEventDetails"]) {
        NSLog(@"showEventDetails segue hit");
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        TGLOEventDetailsViewController *destViewController = (TGLOEventDetailsViewController *) segue.destinationViewController;
        
        destViewController.selectedEventId = [searchResults[indexPath.row] valueForKey:@"eventId"];
    }
}

@end