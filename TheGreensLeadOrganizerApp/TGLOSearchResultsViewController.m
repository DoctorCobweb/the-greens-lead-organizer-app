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
    NSArray *searchResults_;
}

@end

@implementation TGLOSearchResultsViewController

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
        
        searchResults_ = [results_set allObjects];
        //NSLog(@"searchResults: %@", searchResults_);
        
        //after we have received search results
        //tell table view to re render using fresh
        //data
        [self.tableView reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}




//get arbitrary fields from each person.
-(TGLOPerson *) personFieldsForObject:(NSDictionary*)person
{
    //NSLog(@"personFieldsForObject, person: %@", person);
    
    //create a temp person to which we will
    //return the reference to to caller
    TGLOPerson * _person = [[TGLOPerson alloc] init];
    
    
    //check to see if any of the entries are equal to the
    //null singleton returned by [NSNull null]
    //from inspection some fields in the console print out to
    //"<null>" which is how [NSNull null] is printed out
    if ([person objectForKey:@"id"] == [NSNull null]) {
        _person.recordID = nil;
    } else {
        _person.recordID = [person objectForKey:@"id"];
    }
    
    
    if ([person objectForKey:@"first_name"] == [NSNull null]) {
        _person.firstName = nil;
    } else {
        _person.firstName = [person objectForKey:@"first_name"];
    }
    
    
    if ([person objectForKey:@"last_name"] == [NSNull null]) {
        _person.lastName = nil;
    } else {
        _person.lastName = [person objectForKey:@"last_name"];
    }
    
    
    if ([person objectForKey:@"email"] == [NSNull null]) {
        _person.email = nil;
    } else {
        _person.email = [person objectForKey:@"email"];
    }
    
    
    if ([person objectForKey:@"phone"] == [NSNull null]) {
        _person.phone = nil;
    } else {
        _person.phone = [person objectForKey:@"phone"];
    }
    
    
    if ([person objectForKey:@"mobile"] == [NSNull null]) {
        _person.mobile= nil;
    } else {
        _person.mobile= [person objectForKey:@"mobile"];
    }
    
    
    if ([person objectForKey:@"note"] == [NSNull null]) {
        _person.note= nil;
    } else {
        _person.note = [person objectForKey:@"note"];
    }
    
    
    if ([person objectForKey:@"support_level"] == [NSNull null]) {
        _person.supportLevel= nil;
    } else {
        _person.supportLevel= [person objectForKey:@"support_level"];
    }
    
    
    if ([person objectForKey:@"tags"] == [NSNull null]) {
        _person.tags= nil;
    } else {
        _person.tags = [person objectForKey:@"tags"];
    }
    
    return _person;
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
    return [searchResults_ count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"personCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSString *firstName_ = [(searchResults_ [indexPath.row]) objectForKey:@"first_name"];
    NSString *lastName_ = [(searchResults_ [indexPath.row]) objectForKey:@"last_name"];
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
        
        
        TGLOPerson *personSelected = [self personFieldsForObject:[searchResults_ objectAtIndex:indexPath.row]];
        
        TGLOPersonFromSearchViewController *destViewController = (TGLOPersonFromSearchViewController *) segue.destinationViewController;
        destViewController.person = personSelected;
    }
}

@end
