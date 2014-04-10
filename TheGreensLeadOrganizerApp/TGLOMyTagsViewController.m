//
//  TGLOMyTagsViewController.m
//  TheGreensLeadOrganizerApp
//
//  Created by andre on 9/04/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import "TGLOMyTagsViewController.h"
#import "SWRevealViewController.h"
#import "AFNetworking.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "TGLOTagViewController.h"

static NSString *myNationBuilderId = @"my_nation_builder_id";
static NSString *accessToken= @"access_token";

@interface TGLOMyTagsViewController ()
{
    NSString *token;
    
    //contains all the tags for the user
    //used to populate table cells
    NSMutableArray *taggings;

}

@end

@implementation TGLOMyTagsViewController

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
    
    //enable afnetworking to show spinner in top bar
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    token = [[NSUserDefaults standardUserDefaults] valueForKey:accessToken];
    NSLog(@"access_token: %@", token);
    
    if (token) {
        [self getMyNationBuilderDetails];
        
    } else {
        NSLog(@"ERROR in TGLOMyTagsViewController.m. access_token is nil");
    }
    
    [self setUpAppearance];
}

- (void)getMyNationBuilderDetails
{
    NSString * meUrl= [NSString stringWithFormat:@"https://agtest.nationbuilder.com/api/v1/people/me?access_token=%@", token];
    
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
        
        [manager GET:meUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
                [self getAllMyTags];
                
            } else {
                NSLog(@"ERROR: NB ID is nil. after GET people/me in tags view controller");
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
        
        
        
    
    } else {
        NSLog(@"in TGLOMyTagsViewController.m ALREADY HAVE MY PROFILE ID in  UserDefaults");
        
        //go onto calling the tags for user's
        //profile
        [self getAllMyTags];
    }
}


- (void) getAllMyTags
{
    NSString *myNBId = [[NSUserDefaults standardUserDefaults] objectForKey:myNationBuilderId];
    
    NSString * myTaggingsUrl= [NSString stringWithFormat:@"https://agtest.nationbuilder.com/api/v1/people/%@/taggings?access_token=%@", myNBId, token];
    
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager GET:myTaggingsUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"TAGGINGS TABLE VIEW CONTROLLER and response for taggings: %@", responseObject);
        
        //responseObject is an NSDictionary with a "results" key with value of type
        //NSSet.
        //in this set then there are NSDictionary objects for each person
        //the following will thus get all people returned from the api call
        NSSet * taggings_set = [responseObject objectForKey:@"taggings"];
        NSLog(@"taggins_set SET: %@", taggings_set);
        
        //an array of dicts e.g.
        //{"person_id":9; tag=xyz}
        NSArray * taggings_array = [taggings_set allObjects];
        NSLog(@"%d taggings records returned", [taggings_array count]);
        
        //alloc and init the people array
        taggings = [[NSMutableArray alloc] initWithCapacity:[taggings_array count]];
        
        
        for (NSDictionary *tag in taggings_array) {
            NSLog(@"%@", tag);
            [taggings addObject:[tag objectForKey:@"tag"]];
        }
        
        //taggings now has all the tags for person
        NSLog(@"taggings: %@", taggings);
        
        
        
        //reload tableview to display new data returned from server
        [self.tableView reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    


}

- (void)setUpAppearance
{
    self.title = @"My Tags";
    
    // Change button color
    //self.sidebarButton.tintColor = [UIColor colorWithWhite:0.04f alpha:0.9f];
    self.sidebarButton.tintColor = [UIColor colorWithWhite:0.05f alpha:1.0f];
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    self.sidebarButton.target = self.revealViewController;
    self.sidebarButton.action = @selector(revealToggle:);
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];

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
    return [taggings count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"tagCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [taggings objectAtIndex:indexPath.row];
    
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

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showPeopleInTag"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        TGLOTagViewController *destViewController = (TGLOTagViewController *) segue.destinationViewController;
        destViewController.tag = [taggings objectAtIndex:indexPath.row];
        //NSLog(@"%@", ((PersonDetailViewController *)segue.destinationViewController).person);
    }
}

@end
