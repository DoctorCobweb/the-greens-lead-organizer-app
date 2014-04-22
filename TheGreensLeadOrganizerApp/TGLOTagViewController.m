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
#import "TGLOPersonFromTagViewController.h"
#import "TGLOPerson.h"
#import "TGLOAppDelegate.h"
#import "TGLOUtils.h"


static NSString *accessToken= @"access_token";
static NSString *peopleForTagUrl= @"https://%@.nationbuilder.com/api/v1/tags/%@/people?page=1&per_page=100&access_token=%@";

@interface TGLOTagViewController ()
{
    NSString *token;
    NSMutableArray *people; //holds all people in tag. sanitized.
}

@end

@implementation TGLOTagViewController
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
    #warning TODO: default to getting 100 people for now
    //do pagination later
    //you must percent encode self.tag because sometimes
    //can have spaces in the.
    NSString *encodedTag = [TGLOUtils percentEncodeString:self.tag];
    NSString * peopleForTagUrl_ = [NSString stringWithFormat:peopleForTagUrl, nationBuilderSlugValue, encodedTag, token];
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager GET:peopleForTagUrl_ parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"PEOPLE IN TAG VIEW CONTROLLER and response: %@", responseObject);
        
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
    static NSString *CellIdentifier = @"tagPersonCell";
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
    if ([segue.identifier isEqualToString:@"showPersonInTag"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        lastPersonSelected = indexPath.row;
        TGLOPerson *personSelected = searchResults[indexPath.row];
        
        TGLOPersonFromTagViewController *destViewController = (TGLOPersonFromTagViewController *) segue.destinationViewController;
        destViewController.person = personSelected;
    }
}

@end
