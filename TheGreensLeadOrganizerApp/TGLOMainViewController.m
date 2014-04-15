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
#import "TGLOAppDelegate.h"
#import "TGLOCustomContactView.h"


static NSString *myNationBuilderId = @"my_nation_builder_id";
static NSString *accessToken= @"access_token";


NSString * const meUrl= @"https://%@.nationbuilder.com/api/v1/people/me?access_token=%@";
NSString * const myContactsUrl = @"https://%@.nationbuilder.com/api/v1/people/%@/contacts?page=1&per_page=10&access_token=%@";

@interface TGLOMainViewController ()
{
    NSString *token;
    NSMutableArray *taggings;
    NSMutableArray *contacts;
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
    
    token = [[NSUserDefaults standardUserDefaults] valueForKey:accessToken];
    NSLog(@"access_token: %@", token);
    
    [self setUpAppearance];
    
    if (token) {
        [self getMyNationBuilderDetails];
        
    } else {
        NSLog(@"ERROR in TGLOMainViewController.m. access_token is nil");
    }
    
    
}




- (void)setUpAppearance
{
    self.title = @"My Profile";
    
    //set an initial scroll view size
    self.scrollView.contentSize =CGSizeMake(320, 550);
    
    //set the initial container view to be equal
    //to scroll view size
    self.containerView.frame = CGRectMake(0, 0, 320, 550);
    
    
    
    // Change button color
    //self.sidebarButton.tintColor = [UIColor colorWithWhite:0.04f alpha:0.9f];
    self.sidebarButton.tintColor = [UIColor colorWithWhite:0.05f alpha:1.0f];
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    self.sidebarButton.target = self.revealViewController;
    self.sidebarButton.action = @selector(revealToggle:);
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
}


- (void)getMyNationBuilderDetails
{
    NSString * meUrl_ = [NSString stringWithFormat:meUrl, nationBuilderSlugValue, token];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:meUrl_ parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"in MAIN VIEW CONTROLLER and response: %@", responseObject);
         
        //responseObject is an NSDictionary with a "results" key with value of type
        //NSSet.
        //in this set then there are NSDictionary objects for each person
        //the following will thus get all people returned from the api call
        NSDictionary * me_dic = [responseObject objectForKey:@"person"];
        //NSLog(@"me_set: %@", me_dic);
        
        NSLog(@"me_dic[id] SET: %@", [me_dic valueForKey:@"id"]);
        
        //EXTRACTIONS
        //go and setup userdefaults somemore
        [self setMyNBId:[me_dic valueForKey:@"id"]];
        
        
        //start setting up the ui stuff
        [self setupPerson: me_dic];
        
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
     }];
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


- (void)setupPerson:(NSDictionary *)me_dic
{
    NSLog(@"Setting up the person obj, fields...");
    
    
    TGLOPerson *me = [self personFieldsForObject:me_dic];
    
    //UIColor * white_color = [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1.0f];
    

    self.firstName.text = me.firstName;
    self.lastName.text = me.lastName;
    self.supportLevel.text = [me.supportLevel stringValue];
    
    [self.email setTitle:me.email forState:UIControlStateNormal];
    //[self.email setTitleColor:white_color forState:UIControlStateNormal];
    
    [self.phone setTitle:me.phone forState:UIControlStateNormal];
    //[self.phone setTitleColor:white_color forState:UIControlStateNormal];
    
    [self.mobile setTitle:me.mobile forState:UIControlStateNormal];
    //[self.mobile setTitleColor:white_color forState:UIControlStateNormal];
    
    //now we can be sure that we have myNBId in
    //user defaults. onwards to getting tags and
    //contacts API calls, which rely on having
    //myNBId non-nil.
    //[self getAllMyTags];
    
    taggings = [[NSMutableArray alloc] initWithCapacity:[[me valueForKey:@"tags"] count]];
    [taggings addObjectsFromArray:[me valueForKey:@"tags"]];
    
    [self addTagViews];
    
}




- (void)addTagViews
{
    NSLog(@"SETTING UP ALL MY TAGS");
    NSLog(@"taggings array: %@", taggings);
    
    for (NSString *tag in taggings) {
        [self addASingleTag:tag];
    }
    
    [self getAllMyContacts];
}


- (void) addASingleTag:(NSString*)tag
{
    CGFloat labelSpacing = 10; //spacing between the views
    CGFloat makeMoreRoom = 40; //additional room on end of scroll/container view
    CGFloat labelWidth = 280;  //new label width
    CGFloat labelHeight= 30;   //new label height
    
    
    UITextField *newTextField = (UITextField *)[self fabricateANewView:@"UITextField" width:labelWidth height:labelHeight spacing:labelSpacing];
    
    newTextField.borderStyle = UITextBorderStyleRoundedRect;
    newTextField.text = tag;
    

    //update the scroll and container view to fit/display new content
    [self updateScrollAndContainerViewSize:makeMoreRoom];
    
    //finally add the new view to as last subview
    [self.containerView addSubview:newTextField];
}





- (void)getAllMyContacts
{
    //this method is always called after all
    //the tags have rendered. therefore, before
    //going off to call the contacts api, create
    //the contact label and add it to ui
    [self addContactsLabel];
    
    
    //now go onto getting all the contacts
    //and eventually rendering them too.
    NSString *myNBId = [[NSUserDefaults standardUserDefaults] objectForKey:myNationBuilderId];
    
    NSString * myContactsUrl_ = [NSString stringWithFormat:myContactsUrl, nationBuilderSlugValue, myNBId , token];

    
    //need to get notes on the person from a different api, namely
    // the contacts api
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    
    [manager GET:myContactsUrl_ parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@" got contacts in MAIN DETAIL VIEW CONTROLLER and CONTACTS response: %@", responseObject);
        
        NSSet * contacts_set = [responseObject objectForKey:@"results"];
        NSArray *contacts_ = [contacts_set allObjects];
        
        contacts = [[NSMutableArray alloc] initWithArray:contacts_];
        
        //NSLog(@"contacts: %@", contacts);
        //NSLog(@"%d contact records returned", [contacts count]);
        
        [self addContactViews];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}



- (void)addContactsLabel
{
    CGFloat labelSpacing = 10; //spacing between the views
    CGFloat makeMoreRoom = 40; //additional room on end of scroll/container view
    CGFloat labelWidth = 280;  //new label width
    CGFloat labelHeight= 30;   //new label height
    
    
    UILabel *newLabel = (UILabel *)[self fabricateANewView:@"UILabel" width:labelWidth height:labelHeight spacing:labelSpacing];
    
    newLabel.text = @"Contacts";
    newLabel.font = [UIFont boldSystemFontOfSize:13];
    
    
    [self updateScrollAndContainerViewSize:makeMoreRoom];
    
    //finally add the new view to as last subview
    [self.containerView addSubview:newLabel];
}




- (void)addContactViews
{
    NSLog(@"adding in the contact views...");
    
    int number_of_contacts = [contacts count];
    for (int i = 0; i < number_of_contacts; i++) {
        [self addASingleContact:i];
    }
}


- (void)addASingleContact:(int)index
{
    CGFloat labelSpacing = 20; //spacing between the views
    CGFloat makeMoreRoom = 250; //additional room on end of scroll/container view
    CGFloat labelWidth = 280;  //new label width
    CGFloat labelHeight= 230;   //new label height
    
    
    TGLOCustomContactView *customView = (TGLOCustomContactView*)[self fabricateANewView:@"TGLOCustomContactView" width:labelWidth height:labelHeight spacing:labelSpacing];
    
    customView.clipsToBounds = YES;
    customView.opaque = NO;
    
    
    //get all the subview objects from our custom
    //view. we need to set the text to be what our
    //contacts are
    NSArray *customViews_ = [customView subviews];
    
    
    //make sure we dont try to assign null to
    //text property of a view
    //with reference to the view heirachy of
    //a TGLOCustomContactView instance:
    //index 4 = type value field
    //index 5 = method value field
    //index 6 = status value field
    //index 7 = note value field
    NSNull *null = [NSNull null];
    NSNumber *typeValue = [contacts[index] objectForKey:@"type_id"];
    NSLog(@"typeValue: %@", typeValue);
    if ([contacts[index] objectForKey:@"type_id"] != null) {
        ((UILabel *)customViews_[4]).text = [customView getFormattedTypeValue:[typeValue stringValue]];
    }
    
    NSString *methodValue = [contacts[index] objectForKey:@"method"];
    NSLog(@"methodValue: %@", methodValue);
    if ([contacts[index] objectForKey:@"method"] != null) {
        ((UILabel *)customViews_[5]).text = [customView getFormattedMethodValue:methodValue];
    }
    
    NSString *statusValue = [contacts[index] objectForKey:@"status"];
    NSLog(@"statusValue: %@", statusValue);
    if ([contacts[index] objectForKey:@"status"] != null) {
        ((UILabel *)customViews_[6]).text = [customView getFormattedStatusesValue:statusValue];
    }
    
    NSString *noteValue = [contacts[index] objectForKey:@"note"];
    NSLog(@"noteValue: %@", noteValue);
    if ([contacts[index] objectForKey:@"note"] != null) {
        ((UITextView *)[customView subviews][7]).text =noteValue;
    }
    
    
    NSLog(@"customView.frame: %@",NSStringFromCGRect(customView.frame));
    
    [self updateScrollAndContainerViewSize:makeMoreRoom];
    
    //finally add the new custom contact view
    [self.containerView addSubview:customView];
}



// utility method for construct different types of views
- (id) fabricateANewView:(NSString *)viewType width:(CGFloat)viewWidth height:(CGFloat)viewHeight spacing: (CGFloat)viewSpacing
{
    
    NSLog(@"self.containerView frame: %@",NSStringFromCGRect([self.containerView frame]));
    
    CGRect containerFrame = [self.containerView frame];
    CGFloat containerHeight = CGRectGetHeight(containerFrame);
    CGFloat containerWidth = CGRectGetWidth(containerFrame);
    
    NSLog(@"containerFrame height: %f", containerHeight);
    NSLog(@"containerFrame width: %f", containerWidth);
    
    
    NSArray *containerSubviews = [self.containerView subviews];
    
    CGRect lastViewFrame = ((UILabel *)[containerSubviews lastObject]).frame;
    NSLog(@"lastViewFrame: %@", NSStringFromCGRect(lastViewFrame));
    
    //get dimensions of the lower left corner of
    //last subview of containerView
    CGFloat lastViewYLocation = CGRectGetMaxY(lastViewFrame);
    CGFloat lastViewXLocation = CGRectGetMinX(lastViewFrame);
    NSLog(@"lastViewYLocation: %f, lastViewXLocation: %f", lastViewYLocation, lastViewXLocation);
    
    //now create a new rect, taking into account
    //location of last subview
    CGRect viewRect = CGRectMake(lastViewXLocation, lastViewYLocation + viewSpacing, viewWidth, viewHeight);
    
    
    if ([viewType  isEqualToString:@"UILabel"]){
        return [[UILabel alloc] initWithFrame:viewRect];
    } else if ([viewType isEqualToString:@"UITextField"]) {
        return [[UITextField alloc] initWithFrame:viewRect];
    } else if ([viewType isEqualToString:@"TGLOCustomContactView"]) {
        return [[TGLOCustomContactView alloc] initWithFrame:viewRect];
    } else {
        return @"ERROR";
    }
}


//adding in more room to the scroll and container view to fit in newly added content
- (void)updateScrollAndContainerViewSize:(CGFloat)makeMoreRoom
{
    NSLog(@"in updateScrollAndContainerViewSize");
    //update the scroll height to accomodate for
    //new added view
    CGSize contentSize = self.scrollView.contentSize;
    CGFloat scrollHeight = contentSize.height;
    
    self.scrollView.contentSize =CGSizeMake(320, scrollHeight + makeMoreRoom);
    NSLog(@"self.scrollView.contentSize: %@", NSStringFromCGSize(self.scrollView.contentSize));
    
    
    //must also update the containerView height
    CGRect containerViewFrame = self.containerView.frame;
    
    NSLog(@"self.containerView.frame Max X: %f", CGRectGetMaxX(containerViewFrame));
    NSLog(@"self.containerView.frame Max Y: %f", CGRectGetMaxY(containerViewFrame));
    
    self.containerView.frame = CGRectMake(0, 0, (CGRectGetMaxX(containerViewFrame)), (CGRectGetMaxY(containerViewFrame)) + makeMoreRoom);
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
