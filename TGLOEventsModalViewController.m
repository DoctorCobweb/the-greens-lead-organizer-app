//
//  TGLOEventsModalViewController.m
//  Vic Greens
//
//  Created by andre on 7/05/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import "TGLOEventsModalViewController.h"
#import "AFNetworking.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "TGLOUtils.h"


static NSString * eventsUrl = @"https://cryptic-tundra-9564.herokuapp.com/events/all/%@/%@";

@interface TGLOEventsModalViewController () {

    //this is what the tableView will use to make rows.
    //when user makes a search this array will be filtered to hold
    //best matched events to search term
    NSMutableArray *searchResults;
    
    //this will always hold all of the searchResults. can use this
    //to cache or reset tableView to show all events
    NSArray *searchResultsCache;
}

@end

@implementation TGLOEventsModalViewController
@synthesize searchBar;
@synthesize tableView;

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
    // Do any additional setup after loading the view.
    
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    [self getAllEvents];
    
    
    NSLog(@"in TGLOEventsModalViewController");
    //NSLog(@"%@", searchBar);
    searchBar.delegate = self;
    
    UINavigationBar *navbar = [[self navigationController] navigationBar];
    
    UIColor * black_color = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:1.0f];
    
    //this will set the 'back button' to be black
    navbar.tintColor = black_color;
}

- (void)getAllEvents
{

    NSString *myNBId = [TGLOUtils getUserNationBuilderId];
    NSString *accessToken = [TGLOUtils getUserAccessToken];
    NSString * eventsUrl_ = [NSString stringWithFormat:eventsUrl, myNBId, accessToken];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager GET:eventsUrl_ parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"EVENTS MODAL VIEW CONTROLLER and response for events: %@", responseObject);
        
        NSArray *results_array = [[responseObject objectForKey:@"events"] allObjects];
        searchResults = [[NSMutableArray alloc] initWithArray:results_array];
        
        searchResultsCache = [[NSArray alloc] initWithArray:results_array];
        
        //reload tableview to display new data returned from server
        [self.tableView reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.a
}


#pragma UISearchBarDelegate methods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSLog(@"in textDidChange");
    NSLog(@"%@", searchText);
    
    if ([searchText isEqualToString:@""]) {
        NSLog(@"searchText is empty String");
        //reload table with original all events array
        searchResults = [[NSMutableArray alloc] initWithArray:searchResultsCache];
        [[self tableView] reloadData];
        return;
    }
    
    NSMutableIndexSet *indexes = [[NSMutableIndexSet alloc] init];
    
    
    
    int searchCount = [searchResults count];
    for (int i = 0; i < searchCount; i++) {
        NSString *tempName = [[searchResults[i] objectForKey:@"name"] lowercaseString];
        
        if ([tempName rangeOfString:[searchText lowercaseString]].location == NSNotFound) {
            //NSLog(@"%@ does NOT contain %@", tempName, searchText);
            [indexes addIndex:i];
            
        } else {
            //NSLog(@"%@ DOES contain %@", tempName, searchText);
        }
    }
    
    
    [searchResults removeObjectsAtIndexes:indexes];
    [[self tableView] reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar_
{
    NSLog(@"searchBar SEARCH clicked");
    [searchBar_ resignFirstResponder];
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

- (UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"eventsSearchCell";
    UITableViewCell *cell = [tableView_ dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [[searchResults objectAtIndex:indexPath.row] objectForKey:@"name"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"selected event: %@", searchResults[ indexPath.row]);
    [[self delegate] dismissViewControllerAnimated:YES completion:nil];
    TGLOEditMyProfileViewController *delegate = [self delegate];
    
    
    UIButton *rsvpButton = (UIButton *)[[delegate view] viewWithTag:41];
    [rsvpButton titleLabel].font = [UIFont systemFontOfSize:13];
    //rsvpButton.titleEdgeInsets = UIEdgeInsetsMake(0, -30, 0, 30);
    [rsvpButton setTitle:[searchResults[indexPath.row] objectForKey:@"name"] forState:UIControlStateNormal];
    
    delegate.rsvpDetails = [[NSMutableDictionary alloc] initWithDictionary:searchResults[indexPath.row]];
    delegate.sendInANewRSVP = YES;
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

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/





- (IBAction)cancelModal:(id)sender {
    [[self delegate] dismissViewControllerAnimated:YES completion:nil];
    [self delegate].sendInANewRSVP = NO;
}

@end
