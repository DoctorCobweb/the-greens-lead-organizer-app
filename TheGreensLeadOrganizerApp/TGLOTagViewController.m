//
//  TGLOTagViewController.m
//  TheGreensLeadOrganizerApp
//
//  Created by andre on 9/04/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import "TGLOTagViewController.h"
#import "AFNetworking.h"
#import "AFNetworkActivityIndicatorManager.h"

static NSString *accessToken= @"access_token";

@interface TGLOTagViewController ()
{
    NSString *token;
    NSMutableArray *people;
    
}

@end

@implementation TGLOTagViewController

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //enable afnetworking to show spinner in top bar
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    self.title = [[NSString alloc] initWithFormat:@"%@", self.tag];
    
    
    token = [[NSUserDefaults standardUserDefaults] valueForKey:accessToken];
    NSLog(@"access_token: %@", token);
    
    if (token) {
        [self getPeopleInTag];
        
    } else {
        NSLog(@"ERROR in TGLOMyTagsViewController.m. access_token is nil");
    }
}


- (void) getPeopleInTag
{

    
    NSString * peopleForTagUrl= [NSString stringWithFormat:@"https://agtest.nationbuilder.com/api/v1/tags/%@/people?page=1&per_page=50&access_token=%@", self.tag, token];
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager GET:peopleForTagUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"PEOPLE IN TAG VIEW CONTROLLER and response: %@", responseObject);
        
        //responseObject is an NSDictionary with a "results" key with value of type
        //NSSet.
        //in this set then there are NSDictionary objects for each person
        //the following will thus get all people returned from the api call
        NSSet * people_set = [responseObject objectForKey:@"results"];
        //NSLog(@"people_set SET: %@", people_set);
        
        //an array of dicts e.g.
        //{"person_id":9; tag=xyz}
        NSArray * people_array = [people_set allObjects];
        NSLog(@"%d people records returned", [people_array count]);
        
        //alloc and init the people array
        people = [[NSMutableArray alloc] initWithCapacity:[people_array count]];
        
        
        for (NSDictionary *person in people_array) {
            NSLog(@"%@", person);
            NSString *firstName = [person objectForKey:@"first_name"];
            NSString *lastName = [person objectForKey:@"last_name"];
            NSString *combinedName = [[NSString alloc] initWithFormat:@"%@ %@", firstName, lastName];
            
            [people addObject:combinedName];
            
        }
        
        //taggings now has all the tags for person
        NSLog(@"people: %@", people);
        
        
        
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
    return [people count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"tagPersonCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [people objectAtIndex:indexPath.row];
    
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

@end
