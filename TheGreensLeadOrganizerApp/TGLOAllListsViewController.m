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
    NSString *token;
    
    //contains all the listsfor the user
    //used to populate table cells
    NSMutableArray *allLists;
}

@end

@implementation TGLOAllListsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    //preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    token = [TGLOUtils getUserAccessToken];
    if (token) {
        [self getAllLists];
        
    } else {
        NSLog(@"ERROR in TGLOMyListsViewController.m. access_token is nil");
    }
    
    [self setUpAppearance];
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




- (void) getAllLists
{
    NSString *myNBId = [TGLOUtils getUserNationBuilderId];
    NSString * allListsUrl_ = [NSString stringWithFormat:allListsUrl, myNBId, token];
    
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