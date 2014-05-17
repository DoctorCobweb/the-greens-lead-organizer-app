//
//  TGLOAllListsViewController.m
//  Vic Greens
//
//  Created by andre on 16/05/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import "TGLOAllListsViewController.h"



#import "TGLOMyListsViewController.h"
#import "AFNetworking.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "SWRevealViewController.h"
#import "TGLOAppDelegate.h"
#import "TGLOListViewController.h"
#import "TGLOUtils.h"

static NSString * allListsUrl = @"https://cryptic-tundra-9564.herokuapp.com/allLists/%@/%@";


@interface TGLOAllListsViewController ()
{
    //contains all the listsfor the user
    //used to populate table cells
    NSMutableArray *allLists;
}

@end

@implementation TGLOAllListsViewController

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
    
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    //use pull to refresh even without having a UITableViewController
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl]; //the trick
    
    #warning TODO: fix this
    //preserve selection between presentations.
    //self.tableView.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    /*
    NSString *token = [TGLOUtils getUserAccessToken];
    if (token) {
        [self getAllLists];
        
    } else {
        NSLog(@"ERROR in TGLOMyListsViewController.m. access_token is nil");
    }
     */
    
    [self setUpAppearance];
}


- (void)refresh:(UIRefreshControl *)refreshControl {
    NSLog(@"in refresh method");
    
    [self getAllLists:^(NSError *error) {
        NSLog(@"in getAllLists completionHandler, error: %@", error);
        [refreshControl endRefreshing];
        
        if (error == nil) {
            NSLog(@"error is nil");
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
    self.title = @"All Lists";
    
    // Change button color
    self.sidebarButton.tintColor = [UIColor colorWithWhite:0.05f alpha:1.0f];
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    self.sidebarButton.target = self.revealViewController;
    self.sidebarButton.action = @selector(revealToggle:);
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
}




- (void) getAllLists:(allListsCompletionHandler)completionBlock
{
    NSString *myNBId = [TGLOUtils getUserNationBuilderId];
    NSString *token = [TGLOUtils getUserAccessToken];
    NSString * allListsUrl_ = [NSString stringWithFormat:allListsUrl, myNBId, token];
    __block NSError *error;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager GET:allListsUrl_ parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"LISTS TABLE VIEW CONTROLLER and response for lists: %@", responseObject);
        
        //responseObject is has a single array with all the lists
        //=> results_array[0] is the array of lists
        NSArray *results_array = [responseObject allObjects];
        //NSLog(@"results_array: %@", results_array);
        //NSLog(@"%d results records returned", [results_array[0] count]);
        
        allLists = [[NSMutableArray alloc] initWithArray:results_array[0]];
        
        //taggings now has all the tags for person
        //NSLog(@"allLists array: %@", allLists);
        NSLog(@"ALL LISTS allLists array count: %d", [allLists count]);
        
        //reload tableview to display new data returned from server
        //[self.tableView reloadData];
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return [allLists count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"allListsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [allLists[indexPath.row] objectForKey:@"name"];
    
    cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%@",[allLists[indexPath.row] objectForKey:@"count"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"seelcted: %@", allLists[indexPath.row]);
    
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

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showList"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        TGLOListViewController *destViewController = (TGLOListViewController *) segue.destinationViewController;
        destViewController.list= [allLists objectAtIndex:indexPath.row];
    }
}

@end