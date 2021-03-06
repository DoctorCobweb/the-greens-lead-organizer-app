//
//  TGLOEventsModalMyTagsViewController.m
//  Vic Greens
//
//  Created by andre on 14/05/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import "TGLOEventsModalMyTagsViewController.h"


#import "AFNetworking.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "TGLOUtils.h"
#import "TGLOAppDelegate.h"
#import "TGLOEventTableViewCell.h"


static NSString *eventRsvpsUrl = @"https://agv.nationbuilder.com/api/v1/sites/%@/pages/events/%@/rsvps?page=1&per_page=1000&access_token=%@";
static NSString *eventsUrl = @"https://cryptic-tundra-9564.herokuapp.com/events/all/%@/%@";

@interface TGLOEventsModalMyTagsViewController () {
    
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

@implementation TGLOEventsModalMyTagsViewController
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
    
    //use pull to refresh even without having a UITableViewController
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl]; //the trick
    
    
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    undoStack = [[NSMutableArray alloc] init];
    
    
    searchBar.delegate = self;
    UINavigationBar *navbar = [[self navigationController] navigationBar];
    
    UIColor * black_color = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:1.0f];
    
    //this will set the 'back' button to be black
    navbar.tintColor = black_color;
    
    [self loadAllEventEntities];
}



- (void) loadAllEventEntities
{
    //NSLog(@"in loadEventsFromDatabase method");
    //get all events and assign them to searchResults and searchResultsCache arrays
    
    TGLOAppDelegate *delegate = (TGLOAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = [delegate managedObjectContext];
    
    
    
    // Fetch the devices from persistent data store
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Event"];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"startTime" ascending:YES];
    
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    //an array of managedObjects of Entity type Event
    __block NSArray *fetchedEventsArray = [moc executeFetchRequest:fetchRequest error:nil];
    
    //first time visit to this 'page', automatically fetch events
    if ([fetchedEventsArray count] == 0) {
        [self getAllEvents:^(NSError *error, NSMutableArray *resultsArray) {
            //NSLog(@"in getAllEvents completionHandler, error: %@", error);
            
            if (error == nil) {
                //NSLog(@"error is nil");
                
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
        //NSLog(@"Can't Save reset! %@ %@", error, [error localizedDescription]);
        [self displayErrorAlert:@"Database Reset Error" message:@"Unable to reset database. Please try again."];
        return;
    }
    
    
    //add all new events now
    [results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        // Create a new managed object, new Event
        NSManagedObject *newE = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:moc];
        
        NSDate *date = [TGLOUtils formattedDateFromString:[obj valueForKey:@"startTime"]];
        
        [newE setValue:[obj valueForKey:@"eventId"] forKey:@"eventId"];
        [newE setValue:[obj valueForKey:@"name"] forKey:@"name"];
        [newE setValue:date forKey:@"startTime"];
        [newE setValue:[obj valueForKey:@"venue"] forKey:@"venue"];
        
        NSError *error = nil;
        // Save the object to persistent store
        if (![moc save:&error]) {
            //NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
            *stop = YES;
            [self displayErrorAlert:@"Database Error" message:@"Unable to save event to database. Please try again."];
            return;
        }
        
    }];
    
    
    [self loadAllEventEntities];
}


- (void)refresh:(UIRefreshControl *)refreshControl {
    //NSLog(@"in refresh method");
    
    [self getAllEvents:^(NSError *error, NSMutableArray *resultsArray) {
        //NSLog(@"in getAllEvents completionHandler, error: %@", error);
        [refreshControl endRefreshing];
        
        if (error == nil) {
            //NSLog(@"error is nil");
            
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
    
#warning  TODO could/should change backend to reflect this
    //all events url doesnt really require myNBId nor the persons NBid
    //to get all events.
    NSString *myNBId =      [TGLOUtils getUserNationBuilderId];
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



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.a
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
    
    TGLOEventTableViewCell *cell = (TGLOEventTableViewCell *)[tableView dequeueReusableCellWithIdentifier:eventCellIdentifier];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TGLOEventTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    
    //set the text contents finally
    cell.dateLabel.text = [anEvent objectForKey:@"startTime"];
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
    //NSLog(@"selected event: %@", searchResults[ indexPath.row]);
    
    [self.searchBar resignFirstResponder];
    
    //__block allows block to access this var
    __block BOOL alreadyRsvpd = NO;
    __block BOOL alreadyCanceledRsvpd = NO;
    __block NSString *matchedRsvpId = [[NSString alloc] init];
    
    //gotta check to see if user has already rsvpd to this event
    NSString *eventRsvpsUrl_ = [NSString stringWithFormat:eventRsvpsUrl, nationBuilderSlugValue, [searchResults[indexPath.row] objectForKey:@"eventId"],[TGLOUtils getUserAccessToken]];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:eventRsvpsUrl_ parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"EVENTS RSVP check and response for events: %@", responseObject);
        
        NSArray *results_array = [[responseObject objectForKey:@"results"] allObjects];
        //NSString *myNBId = [TGLOUtils getUserNationBuilderId];
        
        if (![results_array isEqual:[NSNull null]] && [results_array count] > 0) {
            //NSLog(@"we HAVE rsvps. check to see if user NB id is in there");
            [results_array enumerateObjectsUsingBlock: ^(id obj, NSUInteger indx, BOOL *stop){
                
                NSString *personIdString = [[NSString alloc] initWithFormat:@"%@",[obj valueForKey:@"person_id"]];
                
                //NSLog(@"personIdString: %@", personIdString);
                //NSLog(@"myNBId: %@", myNBId);
                
                //if ([personIdString isEqualToString:myNBId]) {
                if ([personIdString isEqualToString:[[NSString alloc] initWithFormat:@"%@", self.personIdFromList]]) {
                    //NSLog(@"MATCH => person has ALREADY resvpd to this event");
                    
                    //extract the rsvp id for match. we need it when PUTing the rsvp
                    //to update it
                    matchedRsvpId = [obj valueForKey:@"id"];
                    alreadyRsvpd = YES;
                    
                    NSNumber *canceled = [obj valueForKey:@"canceled"];
                    if ([canceled isEqualToNumber:@1]) {
                        //NSLog(@"ALREADY CANCELED RSVP");
                        alreadyCanceledRsvpd = YES;
                    }
                    
                    *stop = YES;
                }
            }];
        }
        
        
        //now handle the three different cases:
        //1. previously rsvpd and not canceled
        //2. previously rsvpd and canceled
        //3. new rsvp
        
        if (alreadyRsvpd) {
            //and matchedRsvpId will be a string non-nil
            if (!alreadyCanceledRsvpd) {
                [self handleRsvp:@"alreadyRsvpd" selectedRowAtIndexPath:indexPath  matchedRsvpId:matchedRsvpId alreadyCanceledRsvp:NO];
            } else {
                //careful
                //just show the newRsvp actionsheet. but set method to POST
                [self handleRsvp:@"newRsvp" selectedRowAtIndexPath:indexPath  matchedRsvpId:matchedRsvpId alreadyCanceledRsvp:YES];
            }
            
        } else {
            //either no rsvps or user id is not in rsvp list or has rsvpd but canceled
            //matchedRsvpId will be nil because there was no match
            [self handleRsvp:@"newRsvp" selectedRowAtIndexPath:indexPath matchedRsvpId:matchedRsvpId alreadyCanceledRsvp:NO];
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}


//status is either 1. @"alreadyRsvpd" or 2. @"newRsvp"
- (void)handleRsvp:(NSString *)status selectedRowAtIndexPath: (NSIndexPath *)indexPath matchedRsvpId:(NSString *)matchedRsvpId alreadyCanceledRsvp:(BOOL)alreadyCanceledRsvp
{
    TGLOEditPersonFromTagViewController *delegate = [self delegate];
    UIButton *rsvpButton = (UIButton *)[[delegate view] viewWithTag:41];
    
    [rsvpButton titleLabel].font = [UIFont systemFontOfSize:13];
    [rsvpButton setTitle:[searchResults[indexPath.row] objectForKey:@"name"] forState:UIControlStateNormal];
    
    delegate.rsvpDetails = [[NSMutableDictionary alloc] initWithDictionary:searchResults[indexPath.row]];
    delegate.sendInRSVP = YES;
    
    
    
    if ([status isEqualToString:@"newRsvp"]) {
        //NSLog(@"NEW RSVPD to EVENT");
        
        if (!alreadyCanceledRsvp) {
            //also set the http method to POST
            [delegate.rsvpDetails setObject:@"POST" forKey:@"httpMethod"];
            //NSLog(@"alreadyCanceledRsvp is NO so we are POSTting");
        } else {
            //NSLog(@"alreadyCanceledRsvp is YES so we are PUTting");
            //remember that an already canceled rsvp needs to use PUT instead
            [delegate.rsvpDetails setObject:@"PUT" forKey:@"httpMethod"];
            [delegate.rsvpDetails setObject:matchedRsvpId forKey:@"matchedRsvpId"];
        }
        
        
        //prompt user to choose how many addional guests also.
        //this also handles dismissing the modal VC in its body
        [self chooseHowManyGuests];
        
    } else if ([status isEqualToString:@"alreadyRsvpd"]) {
        //NSLog(@"USER HAS ALREADY RSVPD to EVENT!!!");
        
        //set the http method to PUT
        //and the matchedRsvpId which we need for PUT req
        [delegate.rsvpDetails setObject:@"PUT" forKey:@"httpMethod"];
        [delegate.rsvpDetails setObject:matchedRsvpId forKey:@"matchedRsvpId"];
        
        
        //prompt user to choose how many addional guests also.
        //this also handles dismissing the modal VC in its body
        [self cancelRsvpOrChooseGuestsNumber];
    }
    
}


- (void) cancelRsvpOrChooseGuestsNumber
{
    UIActionSheet *updateRsvpActionSheet =
    [[UIActionSheet alloc]
     initWithTitle:@"Already RSVPd: Cancel RSVP or update number of guests"
     delegate:self
     cancelButtonTitle:@"Back to events list"
     destructiveButtonTitle:nil
     otherButtonTitles:@"CANCEL THIS RSVP", @"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", nil];
    
    [updateRsvpActionSheet showInView:self.view];
}


- (void)chooseHowManyGuests
{
    UIActionSheet *guestsNumberActionSheet =
    [[UIActionSheet alloc]
     initWithTitle:@"New RSVP. Any guests?"
     delegate:self
     cancelButtonTitle:@"Back to events list"
     destructiveButtonTitle:nil
     otherButtonTitles:@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", nil];
    
    [guestsNumberActionSheet showInView:self.view];
}


#pragma UIActionSheetDelegate methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //NSLog(@"buttonIndex: %d", buttonIndex);
    //NSLog(@"actionSheet.title: %@", actionSheet.title);
    
    TGLOEditPersonFromTagViewController *delegate = [self delegate];
    
    //also update the RSVP label to show additional guests
    UILabel *rsvpLabel = (UILabel *)[delegate.containerView viewWithTag:42];
    
    if ([actionSheet.title isEqualToString:@"New RSVP. Any guests?"]) {
        //NSLog(@"NEW RSVP ACTIONSHEET");
        if (buttonIndex == [actionSheet cancelButtonIndex]) {
            // User pressed cancel -- abort
            //NSLog(@"user cancelled guest selection");
            
            //just dismiss actionsheet
            return;
        }
        
        [delegate.rsvpDetails setObject:[NSNumber numberWithInt:buttonIndex] forKey:@"guests_count"];
        [delegate.rsvpDetails setObject:@"false" forKey:@"canceled"];
        
        //NSLog(@"delegate.rsvpDetails: %@", delegate.rsvpDetails);
        
        //also update the RSVP label to show additional guests
        rsvpLabel.text = [[NSString alloc] initWithFormat:@"RSVP + %d guests", buttonIndex];
        
        [delegate dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    
    if ([actionSheet.title isEqualToString:@"Already RSVPd: Cancel RSVP or update number of guests"]) {
        //NSLog(@"ALREADY RSVPED ACTIONSHEET");
        
        if (buttonIndex == [actionSheet cancelButtonIndex]) {
            // User pressed cancel -- abort
            return;
        }
        
        if (buttonIndex == 0) {
            //NSLog(@"user wants to CANCEL RSVP");
            //user wants to cancel the event
            [delegate.rsvpDetails setObject:@"true" forKey:@"canceled"];
            
            //just set a dummy val so we dont attempt to set nil in a dic literal
            [delegate.rsvpDetails setObject:[NSNumber numberWithInt:0] forKey:@"guests_count"];
            
            rsvpLabel.text = @"RSVP CANCEL";
            
            [delegate dismissViewControllerAnimated:YES completion:nil];
            return;
        }
        
        
        [delegate.rsvpDetails setObject:@"false" forKey:@"canceled"];
        [delegate.rsvpDetails setObject:[NSNumber numberWithInt:(buttonIndex - 1)] forKey:@"guests_count"];
        
        rsvpLabel.text = [[NSString alloc] initWithFormat:@"RSVP + %d guests", (buttonIndex- 1)];
        
        [delegate dismissViewControllerAnimated:YES completion:nil];
        return;
    }
}




#pragma UISearchBarDelegate methods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
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




/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */





- (IBAction)cancelModal:(id)sender {
    [[self delegate] dismissViewControllerAnimated:YES completion:nil];
    [self delegate].sendInRSVP = NO;
    //also update the RSVP label to show additional guests
    UILabel *rsvpLabel = (UILabel *)[ [self delegate].containerView viewWithTag:42];
    UIButton *rsvpButton = (UIButton *)[[[self delegate ] view] viewWithTag:41];
    
    rsvpLabel.text = @"Add new RSVP";
    [rsvpButton titleLabel].font = [UIFont systemFontOfSize:18];
    [rsvpButton setTitle:@"Choose the event..." forState:UIControlStateNormal];
}

@end
