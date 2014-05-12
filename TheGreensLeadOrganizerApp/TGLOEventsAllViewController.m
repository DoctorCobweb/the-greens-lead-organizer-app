//
//  TGLOEventsAllViewController.m
//  Vic Greens
//
//  Created by andre on 8/05/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//



#import "TGLOEventsAllViewController.h"
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
    // Do any additional setup after loading the view.
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    undoStack = [[NSMutableArray alloc] init];
    
    self.title = @"Search Events";
    searchBar.delegate = self;
    
    [self getAllEvents];
}




- (void)getAllEvents
{
    
    NSString *myNBId = [TGLOUtils getUserNationBuilderId];
    NSString *accessToken = [TGLOUtils getUserAccessToken];
    NSString * eventsUrl_ = [NSString stringWithFormat:eventsUrl, myNBId, accessToken];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager GET:eventsUrl_ parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"EVENTS MODAL VIEW CONTROLLER and response for events: %@", responseObject);
        
        NSArray *results_array = [[responseObject objectForKey:@"events"] allObjects];
        searchResults = [[NSMutableArray alloc] initWithArray:results_array];
        
        searchResultsCache = [[NSArray alloc] initWithArray:results_array];

        
        //reload tableview to display new data returned from server
        [self.tableView reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma UISearchBarDelegate methods



- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSLog(@"%@", searchText);
    NSInteger searchTextLength = [searchText length];
    NSInteger previousSearchTermLength = [previousSearchTerm length];
    
    
    
    if ([searchText isEqualToString:@""]) {
        NSLog(@"searchText is empty String");
        
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
        NSLog(@"drilling down");
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
        
        NSLog(@"pushing: %d objects to undoStack", [[undoStack lastObject ] count]);
        //NSLog(@"collectionOfEvents: %@", collectionOfEvents);
        //NSLog(@"undoStack: %@", undoStack);
        return;
    }
    
    if (searchTextLength < previousSearchTermLength) {
        NSLog(@"drilling up");
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
    NSLog(@"searchBar SEARCH clicked");
    [searchBar_ resignFirstResponder];
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
    
    TGLOEventTableViewCell *cell = (TGLOEventTableViewCell *)[tableView dequeueReusableCellWithIdentifier:eventCellIdentifier];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TGLOEventTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    NSDictionary *anEvent = [searchResults objectAtIndex:indexPath.row];
    
    NSDictionary *venue   = [[NSDictionary alloc] init];
    NSDictionary *address = [[NSDictionary alloc] init];
    NSString *address1    = [[NSString alloc] init];
    NSString *city        = [[NSString alloc] init];
    
    //we MUST check to see if any fields are <null> along the way to
    //finding the address1 and city value.
    //if any of checks fail, city or addres1 will just be nil and
    //UI will display blank to that label.
    //
    //check to see if venue is <null>
    if (![[anEvent objectForKey:@"venue"] isEqual:[NSNull null]]) {
        
        venue = [anEvent objectForKey:@"venue"];
        
        //check to see if address is <null>
        if (![[venue objectForKey:@"address"] isEqual:[NSNull null]])
        {
            address = [venue objectForKey:@"address"];
            
            //check to see if address1 is <null>
            if (![[address objectForKey:@"address1"] isEqual:[NSNull null]] ) {
                
                address1 = [address objectForKey:@"address1"];
                
            }
            
            //check to see if city is <null>
            if (![[address objectForKey:@"city"] isEqual:[NSNull null]] ) {
                
                city = [address objectForKey:@"city"];
                
            }
        }
    }
    
    //NSLog(@"VENUE: %@", venue);
    //NSLog(@"ADDRESS: %@", address);
    
    cell.dateLabel.text = [TGLOUtils formatTheDate:[anEvent objectForKey:@"startTime"] withCustomFormat:@"yyyy-MM-dd'T'HH:mm:ss+HH:mm"];
    
    //set the text contents finally
    cell.nameLabel.text = [anEvent objectForKey:@"name"];
    cell.venueLabel.text = [[NSString alloc] initWithFormat:@"%@ %@", address1, city];
    
    return cell;
    
    /*
    static NSString *CellIdentifier = @"eventsAllCell";
    UITableViewCell *cell = [tableView_ dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [[searchResults objectAtIndex:indexPath.row] objectForKey:@"name"];
    
    return cell;
     */
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    NSLog(@"selected event: %@", searchResults[ indexPath.row]);

    //manually call the segue giving its identifier string which is
    //set in storyboard
    [self performSegueWithIdentifier:@"showEventDetails" sender:self];
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