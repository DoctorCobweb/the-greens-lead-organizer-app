//
//  TGLOSearchResultsViewController.m
//  TheGreensLeadOrganizerApp
//
//  Created by andre on 10/04/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import "TGLOSearchResultsViewController.h"
#import "AFNetworking.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "TGLOPersonFromSearchViewController.h"

@interface TGLOSearchResultsViewController ()
{
}

@end

@implementation TGLOSearchResultsViewController
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

    //preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    UINavigationBar *navbar = [[self navigationController] navigationBar];
    
    NSLog(@"navigation bar: %@", navbar);
    UIColor * black_color = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:1.0f];
    
    //this will set the 'back button' to be black
    navbar.tintColor = black_color;
    
    self.title = @"Search Results";
    
    
    //enable afnetworking to show spinner in top bar
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    [self makeSearch];
}

- (void) makeSearch
{
    
    NSLog(@"self.searchUrl: %@", self.searchUrl);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager GET:self.searchUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"in SEARCH VIEW CONTROLLER and response: %@", responseObject);
        
        //responseObject is an NSDictionary with a "results" key with value of type
        //NSSet.
        //in this set then there are NSDictionary objects for each person
        //the following will thus get all people returned from the api call
        NSSet * results_set = [responseObject objectForKey:@"results"];
        //NSLog(@"results_set: %@", results_set);
        
        //searchResults_ = [results_set allObjects];
        searchResults = [[NSMutableArray alloc] initWithCapacity:[results_set count]];
        NSArray *results_array = [results_set allObjects];
        for (NSDictionary *person in results_array) {
            TGLOPerson *parsedPerson = [TGLOPerson personFieldsForObject:person];
            [searchResults addObject:parsedPerson];
        }
        
        //after we have received search results
        //tell table view to re render using fresh
        //data
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
    static NSString *CellIdentifier = @"personCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSString *firstName_ = ((TGLOPerson *)searchResults[indexPath.row]).firstName;
    NSString *lastName_= ((TGLOPerson *)searchResults[indexPath.row]).lastName;
    NSString *fullName_ = [[NSString alloc] initWithFormat:@"%@ %@", firstName_, lastName_ ];
    
    cell.textLabel.text = fullName_;
    
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
    if ([segue.identifier isEqualToString:@"showPersonFromSearch"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        lastPersonSelected =  self.tableView.indexPathForSelectedRow.row;
        
        TGLOPerson *personSelected = searchResults[indexPath.row];
        
        TGLOPersonFromSearchViewController *destViewController = (TGLOPersonFromSearchViewController *) segue.destinationViewController;
        destViewController.person = personSelected;
    }
}


@end
