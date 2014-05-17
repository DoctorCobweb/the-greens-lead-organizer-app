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
#import "TGLOAppDelegate.h"
#import "TGLOUtils.h"

static NSString * myTaggingsUrl = @"https://%@.nationbuilder.com/api/v1/people/%@/taggings?access_token=%@";

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
    
    //since Lists tab hides our app wide nav bar
    //make sure it is NOT hidden before displaying
    //this view controllers' view
    [[[self navigationController] navigationBar] setHidden:NO];
    

    
    //enable afnetworking to show spinner in top bar
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;

    //preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    token = [TGLOUtils getUserAccessToken];
    
    if (token) {
        [self getAllMyTags];
        
    } else {
        NSLog(@"ERROR in TGLOMyTagsViewController.m. access_token is nil");
    }
    
    [self setUpAppearance];
}


- (void) getAllMyTags
{
    NSString *myNBId = [TGLOUtils getUserNationBuilderId];
    NSString * myTaggingsUrl_ = [NSString stringWithFormat:myTaggingsUrl, nationBuilderSlugValue, myNBId, token];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager GET:myTaggingsUrl_ parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"TAGGINGS TABLE VIEW CONTROLLER and response for taggings: %@", responseObject);
        
        NSSet * taggings_set = [responseObject objectForKey:@"taggings"];
        //NSLog(@"taggins_set SET: %@", taggings_set);
        
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
        //NSLog(@"taggings: %@", taggings);
        
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
    }
}

@end
