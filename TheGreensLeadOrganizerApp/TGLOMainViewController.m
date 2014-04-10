//
//  TGLOMainViewController.m
//  TheGreensLeadOrganizerApp
//
//  Created by andre on 8/04/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import "TGLOMainViewController.h"
#import "SWRevealViewController.h"
#import "AFNetworking.h"

static NSString *myNationBuilderId = @"my_nation_builder_id";
static NSString *accessToken= @"access_token";
static NSString *NBSlug = @"agtest";

@interface TGLOMainViewController ()
{
   NSString *token;
}
@property (nonatomic, strong) UIAlertView *tokenAlert;


@end

@implementation TGLOMainViewController

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
    [self setUpAppearance];
 
    
    token = [[NSUserDefaults standardUserDefaults] valueForKey:accessToken];
    NSLog(@"access_token: %@", token);
    
    
    if (token) {
        [self getMyNationBuilderDetails];
        
    } else {
        NSLog(@"ERROR in TGLOMyTagsViewController.m. access_token is nil");
    }
}



- (void)getMyNationBuilderDetails
{
    NSString * meUrl= [NSString stringWithFormat:@"https://%@.nationbuilder.com/api/v1/people/me?access_token=%@", NBSlug, token];
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
     [manager GET:meUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
         //NSLog(@"in MAIN VIEW CONTROLLER and response: %@", responseObject);
         
         //responseObject is an NSDictionary with a "results" key with value of type
         //NSSet.
         //in this set then there are NSDictionary objects for each person
         //the following will thus get all people returned from the api call
         NSDictionary * me_dic = [responseObject objectForKey:@"person"];
         NSLog(@"me_set: %@", me_dic);
         
         NSLog(@"me_dic[id] SET: %@", [me_dic valueForKey:@"id"]);
         //go and setup userdefaults somemore
         [self setMyNBId:[me_dic valueForKey:@"id"]];
         
         
         [self setupPerson: me_dic];
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
     }];
    
}


- (void)setupPerson:(NSDictionary *)me_dic
{
    NSLog(@"Setting up the person obj, fields...");
    
    
    TGLOPerson *me = [self personFieldsForObject:me_dic];
    NSLog(@"me: %@", me);
    
    //finally setup the UI with sanized fields
    [self populateTheUIWith:me];
}


- (void)populateTheUIWith:(TGLOPerson *)me
{
    UIColor * white_color = [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1.0f];

    self.firstName.text = me.firstName;
    self.lastName.text = me.lastName;
    self.supportLevel.text = [me.supportLevel stringValue];
    
    [self.email setTitle:me.email forState:UIControlStateNormal];
    [self.email setTitleColor:white_color forState:UIControlStateNormal];
    
    [self.phone setTitleColor:white_color forState:UIControlStateNormal];
    [self.phone setTitle:me.phone forState:UIControlStateNormal];
    
    [self.mobile setTitle:me.mobile forState:UIControlStateNormal];
    [self.mobile setTitleColor:white_color forState:UIControlStateNormal];

}

//get arbitrary fields from each person.
-(TGLOPerson *) personFieldsForObject:(NSDictionary*)person
{
    //create a temp person to which we will
    //return the reference to to caller
    TGLOPerson * person_ = [[TGLOPerson alloc] init];
    
    
    //check to see if any of entries are equal to
    //null singleton returned by [NSNull null]
    //from inspection some fields in the console print out to
    //"<null>" which is how [NSNull null] is printed out
    if ([person objectForKey:@"id"] == [NSNull null]) {
        person_.recordID = nil;
    } else {
        person_.recordID = [person objectForKey:@"id"];
    }
    
    
    if ([person objectForKey:@"first_name"] == [NSNull null]) {
        person_.firstName = nil;
    } else {
        person_.firstName = [person objectForKey:@"first_name"];
    }
    
    
    if ([person objectForKey:@"last_name"] == [NSNull null]) {
        person_.lastName = nil;
    } else {
        person_.lastName = [person objectForKey:@"last_name"];
    }
    
    
    if ([person objectForKey:@"email1"] == [NSNull null]) {
        person_.email = nil;
    } else {
        person_.email = [person objectForKey:@"email1"];
    }
    
    
    if ([person objectForKey:@"phone"] == [NSNull null]) {
        person_.phone = nil;
    } else {
        person_.phone = [person objectForKey:@"phone"];
    }
    
    
    if ([person objectForKey:@"mobile"] == [NSNull null]) {
        person_.mobile= nil;
    } else {
        person_.mobile= [person objectForKey:@"mobile"];
    }
    
    
    if ([person objectForKey:@"note"] == [NSNull null]) {
        person_.note= nil;
    } else {
        person_.note = [person objectForKey:@"note"];
    }
    
    
    if ([person objectForKey:@"support_level"] == [NSNull null]) {
        person_.supportLevel= nil;
    } else {
        person_.supportLevel= [person objectForKey:@"support_level"];
    }
    
    
    if ([person objectForKey:@"tags"] == [NSNull null]) {
        person_.tags= nil;
    } else {
        person_.tags = [person objectForKey:@"tags"];
    }
    
    return person_;
}

- (void)setMyNBId:(NSString *)myNBId
{
    //check to see if UserDefaults has a non nil
    //value for key @"my_nb_id"
    //if it is non-nil then we have previously
    //called the GET people/me endpoint for this
    //app user's profile info & subsequently stored
    //it in UserDefaults.
    NSString *_myNBId = [[NSUserDefaults standardUserDefaults] objectForKey:myNationBuilderId];
    NSLog(@"myNBId: %@", myNBId);
    
    if (_myNBId == nil) {
        NSLog(@"NO NB USER ID set for this app => setting it up now...");
        
        //set myNBId into user defaults
        //then sync user defaults
        [[NSUserDefaults standardUserDefaults] setObject:myNBId forKey:myNationBuilderId];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        NSLog(@"in TGLOMainViewController.m ALREADY HAVE MY PROFILE ID in  UserDefaults");
    }
}


- (void)setUpAppearance
{
    self.title = @"My Profile";
    
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

@end
