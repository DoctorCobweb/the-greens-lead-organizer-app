//
//  TGLOEventsAllViewController.m
//  Vic Greens
//
//  Created by andre on 8/05/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//



#import "TGLOEventsAllViewController.h"
#import "AFNetworking.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "TGLOUtils.h"


static NSString * eventsUrl = @"https://cryptic-tundra-9564.herokuapp.com/events/all/%@/%@";

@interface TGLOEventsAllViewController () {
    NSMutableArray *searchResults;
}

@end

@implementation TGLOEventsAllViewController

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
    
    self.title = @"All Vic events";
    
    [self getAllEvents];
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




#pragma UISearchBarDelegate methods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSLog(@"%@", searchText);
    //[searchResults removeLastObject];
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
    static NSString *CellIdentifier = @"eventsAllCell";
    UITableViewCell *cell = [tableView_ dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [[searchResults objectAtIndex:indexPath.row] objectForKey:@"name"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    NSLog(@"selected event: %@", searchResults[ indexPath.row]);
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end