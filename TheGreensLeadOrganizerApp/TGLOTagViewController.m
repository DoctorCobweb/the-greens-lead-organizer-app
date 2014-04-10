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
#import "TGLOPersonViewController.h"
#import "TGLOPerson.h"


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


    
    #warning TODO: default to getting 100 people for now
    //do pagination later
    NSString * peopleForTagUrl= [NSString stringWithFormat:@"https://agtest.nationbuilder.com/api/v1/tags/%@/people?page=1&per_page=100&access_token=%@", self.tag, token];
    
    
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
            //NSLog(@"%@", person);
            
            //get a properly parsed TGLOPerson
            //then add it to people array
            TGLOPerson *_person = [self personFieldsForObject:person];
            [people addObject:_person];
        }
        
        //check taggings now has all the tags for person
        NSLog(@"people: %@", people);
        
        //reload tableview to display new data returned from server
        [self.tableView reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}



//get arbitrary fields from each person.
-(TGLOPerson *) personFieldsForObject:(NSDictionary*)person
{
    NSLog(@"personFieldsForObject, person: %@", person);
    
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
    return [people count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"tagPersonCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSString *_firstName = ((TGLOPerson *)[people objectAtIndex:indexPath.row]).firstName;
    NSString *_lastName = ((TGLOPerson *)[people objectAtIndex:indexPath.row]).lastName;
    // Configure the cell...
    cell.textLabel.text = [[NSString alloc] initWithFormat:@"%@ %@", _firstName, _lastName ];
    
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
        
        TGLOPersonViewController *destViewController = (TGLOPersonViewController *) segue.destinationViewController;
        destViewController.person = [people objectAtIndex:indexPath.row];
        //NSLog(@"%@", ((PersonDetailViewController *)segue.destinationViewController).person);
    }
}

@end
