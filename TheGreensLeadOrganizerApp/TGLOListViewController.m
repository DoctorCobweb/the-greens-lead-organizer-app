//
//  TGLOListViewController.m
//  TheGreensLeadOrganizerApp
//
//  Created by andre on 13/04/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import "TGLOListViewController.h"
#import "AFNetworking.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "TGLOAppDelegate.h"
#import "TGLOPersonFromListViewController.h"
#import "TGLOUtils.h"


//default to get 1000 results for a single page call to endpoint
static NSString * aListUrl = @"https://%@.nationbuilder.com/api/v1/lists/%@/people?page=1&per_page=1000&access_token=%@";

@interface TGLOListViewController ()
{
    NSMutableArray *peopleInList;
    NSString *token;
}

@end

@implementation TGLOListViewController
@synthesize searchResults;
@synthesize lastPersonSelected;

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
    
    UINavigationBar *navbar = [[self navigationController] navigationBar];
    //NSLog(@"navigation bar: %@", navbar);
    UIColor * black_color = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:1.0f];
    //this will set the 'back button' to be black
    navbar.tintColor = black_color;
    
    
    //NSLog(@"list is: %@", self.list);
    self.title = [self.list objectForKey:@"name"];
    
    if (token) {
        [self getPeopleInList];
        
    } else {
        NSLog(@"ERROR in TGLOListViewController.m. access_token is nil");
    }

    
}


- (void) getPeopleInList
{
    NSString * aListUrl_ = [NSString stringWithFormat:aListUrl, nationBuilderSlugValue, [self.list objectForKey:@"id"], token];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager GET:aListUrl_ parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"A LIST TABLE VIEW CONTROLLER and response for lists: %@", responseObject);
        
        
        NSSet * results_set = [responseObject objectForKey:@"results"];
        //NSLog(@"results_set: %@", results_set);
        
        searchResults = [[NSMutableArray alloc] initWithCapacity:[results_set count]];
        NSArray *results_array = [results_set allObjects];
        for (NSDictionary *person in results_array) {
            TGLOPerson *parsedPerson = [TGLOPerson personFieldsForObject:person];
            [searchResults addObject:parsedPerson];
        }
        
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
    return [searchResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"listPersonCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSString *firstName_ = ((TGLOPerson *)searchResults[indexPath.row]).firstName;
    NSString *lastName_= ((TGLOPerson *)searchResults[indexPath.row]).lastName;
    NSString *fullName_ = [[NSString alloc] initWithFormat:@"%@ %@", firstName_, lastName_ ];
    int tagCount = [((TGLOPerson *)searchResults[indexPath.row]).tags count];
    cell.textLabel.text = fullName_;
    cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%d tags", tagCount ? tagCount: 0];
    
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
    if ([segue.identifier isEqualToString:@"showListPerson"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        lastPersonSelected = indexPath.row;
        TGLOPerson *personSelected = searchResults[indexPath.row];
        
        TGLOPersonFromListViewController *destViewController = (TGLOPersonFromListViewController *) segue.destinationViewController;
        destViewController.person = personSelected;
    }
}


@end
