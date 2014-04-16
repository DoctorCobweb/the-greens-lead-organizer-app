//
//  TGLOMyListsViewController.m
//  TheGreensLeadOrganizerApp
//
//  Created by andre on 13/04/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import "TGLOMyListsViewController.h"
#import "AFNetworking.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "SWRevealViewController.h"
#import "TGLOAppDelegate.h"
#import "TGLOListViewController.h"

static NSString *myNationBuilderId = @"my_nation_builder_id";
static NSString *accessToken= @"access_token";

static NSString * meUrl = @"https://%@.nationbuilder.com/api/v1/people/me?access_token=%@";

static NSString * myListsUrl = @"https://%@.nationbuilder.com/api/v1/lists/%@/people?page=1&per_page=100&access_token=%@";
static NSString * allListsUrl = @"https://%@.nationbuilder.com/api/v1/lists?page=1&per_page=100&access_token=%@";

@interface TGLOMyListsViewController ()
{
    NSString *token;
    
    //contains all the listsfor the user
    //used to populate table cells
    NSMutableArray *allLists;
}

@end

@implementation TGLOMyListsViewController

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
    
    token = [[NSUserDefaults standardUserDefaults] valueForKey:accessToken];
    NSLog(@"access_token: %@", token);
    
    if (token) {
        [self getMyNationBuilderDetails];
        
    } else {
        NSLog(@"ERROR in TGLOMyListsViewController.m. access_token is nil");
    }
    
    [self setUpAppearance];
}


- (void)setUpAppearance
{
    self.title = @"My Lists";
    
    // Change button color
    self.sidebarButton.tintColor = [UIColor colorWithWhite:0.05f alpha:1.0f];
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    self.sidebarButton.target = self.revealViewController;
    self.sidebarButton.action = @selector(revealToggle:);
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
}



- (void)getMyNationBuilderDetails
{
    NSString * meUrl_ = [NSString stringWithFormat:meUrl, nationBuilderSlugValue, token];
    
    //check to see if UserDefaults has a non nil
    //value for key @"my_nb_id"
    //if it is non-nil then we have previously
    //called the GET people/me endpoint for this
    //app user's profile info & subsequently stored
    //it in UserDefaults.
    NSString *myNBId = [[NSUserDefaults standardUserDefaults] objectForKey:myNationBuilderId];
    NSLog(@"myNBId: %@", myNBId);
    
    if (myNBId == nil) {
        //need to get user's details
        //call GET people/me and store results
        //in UserDefaults
        
        
        NSLog(@"NO NB USER ID set for this app. getting them...");
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        [manager GET:meUrl_ parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            //NSLog(@"in TAGS TABLE VIEW CONTROLLER and response: %@", responseObject);
            
            //responseObject is an NSDictionary with a "results" key with value of type
            //NSSet.
            //in this set then there are NSDictionary objects for each person
            //the following will thus get all people returned from the api call
            NSSet * person_set = [responseObject objectForKey:@"person"];
            NSLog(@"person_set[id] SET: %@", [person_set valueForKey:@"id"]);
            
            if ([person_set valueForKey:@"id"]) {
                #warning set more user defaults if you want!
                //set the id into user defaults
                [[NSUserDefaults standardUserDefaults] setObject:[person_set valueForKey:@"id"] forKey:myNationBuilderId];
                
                //remember to sync the additions
                //made to user defaults
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                //now go onto getting the taggings
                [self getAllLists];
                
            } else {
                NSLog(@"ERROR: NB ID is nil. after GET people/me in lists view controller");
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
    } else {
        NSLog(@"in TGLOMyListsViewController.m ALREADY HAVE MY PROFILE ID in  UserDefaults");
        
        //go onto calling the tags for user's
        //profile
        [self getAllLists];
    }
}


- (void) getAllLists
{
#warning ALL LISTS for a NATION atm!!! what about lists for a user??
    //NSString * myListsUrl_ = [NSString stringWithFormat:myListsUrl, nationBuilderSlugValue, @"23", token];
    NSString *allListsUrl_ = [NSString stringWithFormat:allListsUrl, nationBuilderSlugValue, token];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager GET:allListsUrl_ parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"LISTS TABLE VIEW CONTROLLER and response for lists: %@", responseObject);
        
        //responseObject is an NSDictionary with a "results" key with value of type
        //NSSet.
        //in this set then there are NSDictionary objects for each person
        //the following will thus get all people returned from the api call
        NSSet * results_set = [responseObject objectForKey:@"results"];
        //NSLog(@"results_set SET: %@", results_set);
        
        //an array of dicts e.g.
        //{"person_id":9; tag=xyz}
        NSArray * results_array = [results_set allObjects];
        NSLog(@"%d results records returned", [results_array count]);
        
        //alloc and init the people array
        
        allLists = [[NSMutableArray alloc] initWithArray:results_array];
        
        //taggings now has all the tags for person
        NSLog(@"allLists array: %@", allLists);
        
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
    static NSString *CellIdentifier = @"listCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [allLists[indexPath.row] objectForKey:@"name"];
    
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
