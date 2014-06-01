//
//  TGLOListsModalListsViewController.m
//  Vic Greens
//
//  Created by andre on 20/05/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import "TGLOListsModalListsViewController.h"
#import "AFNetworking.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "TGLOUtils.h"
#import "TGLOAppDelegate.h"


static NSString * allListsUrl = @"https://cryptic-tundra-9564.herokuapp.com/allLists/%@/%@";
static NSString * isPersonInListUrl = @"https://cryptic-tundra-9564.herokuapp.com/isPersonInList/%@/%@?listId=%@&personId=%@";

@interface TGLOListsModalListsViewController ()
{
    //contains all the listsfor the user
    //used to populate table cells
    NSMutableArray *allLists;
    
    //this will always hold all of the lists. can use this
    //to cache or reset tableView to show all lists
    NSArray *allListsCache;
    
    NSString *previousSearchTerm;
    
    NSMutableArray *undoStack;
}

@end

@implementation TGLOListsModalListsViewController
//@synthesize searchBar;
//@synthesize tableView;

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
    
    //preserve selection between presentations.
    self.tableView.clearsContextBeforeDrawing = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    [self setUpAppearance];
    [self loadAllListEntities];
}


- (void)refresh:(UIRefreshControl *)refreshControl {
    //NSLog(@"in refresh method");
    
    [self getAllLists:^(NSError *error) {
        //NSLog(@"in getAllLists completionHandler, error: %@", error);
        [refreshControl endRefreshing];
        
        if (error == nil) {
            //NSLog(@"error is nil");
            [self.tableView reloadData];
        }
        
        if (error) {
            NSLog(@"ERROR: %@", error);
            [self displayErrorAlert:@"Network Error" message:@"Unable to download lists. Pleas try again."];
        }
        
    }];
}

- (void)setUpAppearance
{
    UINavigationBar *navbar = [[self navigationController] navigationBar];
    
    UIColor * black_color = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:1.0f];
    
    //this will set the 'back' button to be black
    navbar.tintColor = black_color;
    
    
}



- (void) loadAllListEntities
{
    //NSLog(@"in loadListsFromDatabase method");
    
    TGLOAppDelegate *delegate = (TGLOAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = [delegate managedObjectContext];
    
    
    // Fetch the devices from persistent data store
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"List"];
    
    //an array of managedObjects of Entity type List
    __block NSArray *fetchedListsArray = [moc executeFetchRequest:fetchRequest error:nil];
    //NSLog(@"fetchedListsArray count: %d", [fetchedListsArray count]);
    
    //first time visit to this 'page', automatically fetch events
    if ([fetchedListsArray count] == 0) {
        [self getAllLists:^(NSError *error) {
            //NSLog(@"in getAllLists completionHandler, error: %@", error);
            
            if (error == nil) {
                //NSLog(@"error is nil");
                [self.tableView reloadData];
            }
            
            if (error) {
                NSLog(@"ERROR: %@", error);
                [self displayErrorAlert:@"Network Error" message:@"Unable to download events. Pleas try again."];
            }
        }];
    }
    
    __block NSMutableArray *extractedLists = [[NSMutableArray alloc] init];
    
    [fetchedListsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger i, BOOL *stop) {
        
        NSDictionary *dic = @{ @"name":       [obj valueForKey:@"name"],
                               @"count":      [obj valueForKey:@"count"],
                               @"id":         [obj valueForKey:@"id"],
                               @"slug":       [obj valueForKey:@"slug"],
                               @"sortOrder":  [obj valueForKey:@"sortOrder"],
                               @"authorId":   [obj valueForKey:@"authorId"]
                               };
        
        [extractedLists addObject:dic];
    }];
    
    allLists = [extractedLists mutableCopy];
    allListsCache = [[NSArray alloc] initWithArray:extractedLists];
}


//results is a mutable array of dics
- (void) saveAllListEntities:(NSMutableArray *)results
{
    TGLOAppDelegate *delegate = (TGLOAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = [delegate managedObjectContext];
    
    
    
    //reset the database to empty
    //fetch em all and delete em all
    NSFetchRequest * allListsFR = [[NSFetchRequest alloc] init];
    [allListsFR setEntity:[NSEntityDescription entityForName:@"List" inManagedObjectContext:moc]];
    [allListsFR setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError * error = nil;
    NSArray * lists = [moc executeFetchRequest:allListsFR error:&error];
    
    //error handling goes here
    for (NSManagedObject * list in lists) {
        [moc deleteObject:list];
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
        NSManagedObject *newList = [NSEntityDescription insertNewObjectForEntityForName:@"List" inManagedObjectContext:moc];
        
        
        [newList setValue:[obj valueForKey:@"name"] forKey:@"name"];
        [newList setValue:[obj valueForKey:@"count"] forKey:@"count"];
        [newList setValue:[obj valueForKey:@"id"] forKey:@"id"];
        [newList setValue:[obj valueForKey:@"slug"] forKey:@"slug"];
        [newList setValue:[obj valueForKey:@"sort_order"] forKey:@"sortOrder"];
        [newList setValue:[obj valueForKey:@"author_id"] forKey:@"authorId"];
        
        NSError *error = nil;
        // Save the object to persistent store
        if (![moc save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
            *stop = YES;
            [self displayErrorAlert:@"Database Error" message:@"Unable to save event to database. Please try again."];
            return;
        }
        
    }];
    
    //success in saving to database so we can assigned results to table data source
    allLists =      [[NSMutableArray alloc] initWithArray:results];
    allListsCache = [[NSArray alloc] initWithArray:results];
}




- (void) getAllLists:(allListsCompletionHandler)completionBlock
{
    NSString *myNBId = [TGLOUtils getUserNationBuilderId];
    NSString *token = [TGLOUtils getUserAccessToken];
    NSString * allListsUrl_ = [NSString stringWithFormat:allListsUrl, myNBId, token];
    __block NSError *error;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager GET:allListsUrl_ parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //responseObject is has a single array with all the lists
        //NSLog(@"LISTS TABLE VIEW CONTROLLER and response for lists: %@", responseObject);
        
        NSArray *results_array = [[responseObject objectForKey:@"lists" ] allObjects];
        NSMutableArray *results_array_mutable = [[NSMutableArray alloc] initWithArray:results_array];
        
        //NSLog(@"results_array_mutable: %@", results_array_mutable);
        //allLists = [[NSMutableArray alloc] initWithArray:results_array];
        //allListsCache = [[NSArray alloc] initWithArray: results_array];
        //NSLog(@"ALL LISTS allLists array count: %d", [allLists count]);
        
        
        [self saveAllListEntities:results_array_mutable];
        
        completionBlock(error);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        error = [NSError errorWithDomain:@"GreensApp" code:1 userInfo:nil];
        completionBlock(error);
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



#pragma UISearchBarDelegate methods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSInteger searchTextLength = [searchText length];
    NSInteger previousSearchTermLength = [previousSearchTerm length];
    
    //NSLog(@"searchBar textDidChange");
    
    if ([searchText isEqualToString:@""]) {
        //NSLog(@"searchText is empty String");
        
        //reload table with original all lists array
        allLists = [[NSMutableArray alloc] initWithArray:allListsCache];
        [[self tableView] reloadData];
        
        [undoStack removeAllObjects];
        previousSearchTerm = @"";
        
        
        //check we are bak to start
        for (int k = 0; k < [allListsCache count]; k++) {
            [allLists containsObject:[allListsCache objectAtIndex:k]] ? nil: NSLog(@"ERROR: cache and searchResults not equal!");
        }
        
        return;
    }
    
    if (searchTextLength > previousSearchTermLength) {
        //NSLog(@"drilling down");
        //push removed objects to undo stack
        NSMutableArray *collectionOfEvents = [[NSMutableArray alloc] init];
        
        NSMutableIndexSet *removeEventsAtIndexes = [self getIndexSetOfMatches:searchText];
        
        
        NSArray *tempArray = [[NSArray alloc] initWithArray:allLists];
        int tempArrayCount = [tempArray count];
        
        [allLists removeObjectsAtIndexes:removeEventsAtIndexes];
        
        for (int j = 0; j < tempArrayCount; j++) {
            if (![allLists containsObject:tempArray[j]]) {
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
        [allLists addObjectsFromArray:[undoStack lastObject]];
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
    int listCount = [allLists count];
    
    for (int i = 0; i < listCount; i++) {
        NSString *tempName = [[allLists[i] objectForKey:@"name"] lowercaseString];
        
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





#pragma UITableView delegate + source methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [allLists count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"listsCell";
    UITableViewCell *cell = [tableView_ dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [allLists[indexPath.row] objectForKey:@"name"];
    
    cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%@",[allLists[indexPath.row] objectForKey:@"count"]];
    
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"seelcted: %@", allLists[indexPath.row]);
    self.delegate.listDetails = [[NSMutableDictionary alloc] initWithDictionary:allLists[indexPath.row]];
    [self.delegate.listDetails setValue:@"list" forKey:@"jobType"];
    
    
    UIButton *listButton = (UIButton *)[[self.delegate view] viewWithTag:44];
    [listButton setTitle:[allLists[indexPath.row] objectForKey:@"name"] forState:UIControlStateNormal];
    
    
    UIActionSheet *actionSheet =
    [[UIActionSheet alloc]
     initWithTitle:@"Add or Delete person to/from list?"
     delegate:self
     cancelButtonTitle:@"Cancel"
     destructiveButtonTitle:nil
     otherButtonTitles:@"Add", @"Delete", nil];
    
    [actionSheet showInView:self.view];
}




#pragma UIActionSheetDelegate methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //NSLog(@"buttonIndex: %d", buttonIndex);
    //NSLog(@"actionSheet.title: %@", actionSheet.title);
    
    //also update the list label
    UILabel *listLabel = (UILabel *)[self.delegate.containerView viewWithTag:43];
    if ([actionSheet.title isEqualToString:@"Add or Delete person to/from list?"]){
        //NSLog(@"ADD or DELETE person from list");
        
        if (buttonIndex == [actionSheet cancelButtonIndex]) {
            // User pressed cancel -- abort
            return;
        }
        
        if (buttonIndex == 0) {
            //NSLog(@"add person hit");
            self.delegate.sendInAddToList = YES;
            [self.delegate.listDetails setValue:@"POST" forKey:@"httpMethod"];
            
            listLabel.text = @"Add to LIST";
            [self.delegate dismissViewControllerAnimated:YES completion:nil];
            
            return;
        }
        
        if (buttonIndex == 1) {
            //NSLog(@"delete person hit");
            self.delegate.sendInAddToList = YES;
            [self.delegate.listDetails setValue:@"DELETE" forKey:@"httpMethod"];
            
            listLabel.text = @"Delete person from list";
            [self.delegate dismissViewControllerAnimated:YES completion:nil];
            
            return;
        }
    }
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
    [self delegate].sendInAddToList = NO;
    
    
    //also update the LIST label
    UILabel *listLabel = (UILabel *)[ [self delegate].containerView viewWithTag:43];
    UIButton *labelButton = (UIButton *)[[[self delegate ] view] viewWithTag:44];
    
    listLabel.text = @"Add to LIST";
    [labelButton titleLabel].font = [UIFont systemFontOfSize:18];
    [labelButton setTitle:@"Choose the list..." forState:UIControlStateNormal];
}
@end


