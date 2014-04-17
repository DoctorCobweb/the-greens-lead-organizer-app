//
//  TGLOPersonFromListViewController.m
//  TheGreensLeadOrganizerApp
//
//  Created by andre on 15/04/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import "TGLOPersonFromListViewController.h"
#import "TGLOAppDelegate.h"
#import "TGLOCustomContactView.h"
#import "AFNetworking.h"
#import "TGLOPerson.h"

static NSString *accessToken= @"access_token";
static NSString * myContactsUrl = @"https://%@.nationbuilder.com/api/v1/people/%@/contacts?page=1&per_page=10&access_token=%@";



@interface TGLOPersonFromListViewController ()
{
    NSString *token;
    NSMutableArray *contacts;
    
    
}
@property (nonatomic, strong) UIAlertView *tokenAlert;


@end

@implementation TGLOPersonFromListViewController

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
    
    token = [[NSUserDefaults standardUserDefaults] valueForKey:accessToken];
    NSLog(@"access_token: %@", token);
    
    
    [self setUpAppearance];
}


- (void)setUpAppearance
{
    self.title = @"Person";
    
    //UIColor * white_color = [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1.0f];
    
    
    //set an initial scroll view size
    self.scrollView.contentSize =CGSizeMake(320, 550);
    
    //set the initial container view to be equal
    //to scroll view size
    self.containerView.frame = CGRectMake(0, 0, 320, 550);
    
    NSLog(@"TGLOPersonFromListView person: %@", self.person);
    
    self.person = [self personFieldsForObject:self.rawPerson];
    
    if(self.person){
        //get the person object passed through from segue
        self.firstName.text = self.person.firstName;
        self.lastName.text = self.person.lastName;
        self.supportLevel.text = [TGLOPerson formattedSupportLevel:self.person.supportLevel];
        
        
        
        [self.email setTitle:self.person.email forState:UIControlStateNormal];
        //[self.email setTitleColor:white_color forState:UIControlStateNormal];
        
        [self.phone setTitle:self.person.phone forState:UIControlStateNormal];
        //[self.phone setTitleColor:white_color forState:UIControlStateNormal];
        
        [self.mobile setTitle:self.person.mobile forState:UIControlStateNormal];
        //[self.mobile setTitleColor:white_color forState:UIControlStateNormal];
        
    }
    
    [self addTagViews];
    
    
}

-(void)addTagViews
{
    NSLog(@"SETTING UP ALL MY TAGS");
    
    for (NSString *tag in self.person.tags) {
        [self addASingleTag:tag];
    }
    
    [self getAllMyContacts];
    
    
}






- (void)addASingleTag:(NSString *)tag
{
    CGFloat labelSpacing = 10; //spacing between the views
    CGFloat makeMoreRoom = 40; //additional room on end of scroll/container view
    CGFloat labelWidth = 280;  //new label width
    CGFloat labelHeight= 30;   //new label height
    
    UIColor * greenColor = [UIColor colorWithRed:129/255.0f green:193/255.0f blue:87/255.0f alpha:1.0f];
    
    
    UITextField *newTextField = (UITextField *)[self fabricateANewView:@"UITextField" width:labelWidth height:labelHeight spacing:labelSpacing];
    
    newTextField.borderStyle = UITextBorderStyleRoundedRect;
    newTextField.text = tag;
    newTextField.userInteractionEnabled = NO;
    newTextField.backgroundColor = greenColor;
    
    
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
    
    NSLog(@"in getAllMyContacts");
    NSLog(@"self.person.recordID: %@", self.person.recordID);
    NSLog(@"token: %@", token);
    
    
    //this evals to true if token is not set
    if (!token) {
        
        NSLog(@"!token is true");
    }
    
    if (!!self.person.recordID && !!token) {
        
        NSString * myContactsUrl_ = [NSString stringWithFormat:myContactsUrl, nationBuilderSlugValue, self.person.recordID, token];
        
        
        //need to get notes on the person from a different api, namely
        // the contacts api
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        
        [manager GET:myContactsUrl_ parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            //NSLog(@" got contacts in MAIN DETAIL VIEW CONTROLLER and CONTACTS response: %@", responseObject);
            
            NSSet * contacts_set = [responseObject objectForKey:@"results"];
            NSArray *contacts_ = [contacts_set allObjects];
            
            contacts = [[NSMutableArray alloc] initWithArray:contacts_];
            
            [self addContactViews];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
    } else {
        NSLog(@"ERROR in TGLOPersonViewController.m. access_token is nil OR person.recordID is nil");
    }
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
    
    
    //make sure we dont try to assign null to
    //text property of a view
    //using view.tag to find respective views of
    //TGLOCustomContactView
    NSNull *null = [NSNull null];
    NSNumber *typeValue = [contacts[index] objectForKey:@"type_id"];
    NSLog(@"typeValue: %@", typeValue);
    if ([contacts[index] objectForKey:@"type_id"] != null) {
        ((UILabel *)[customView viewWithTag:1]).text = [customView getFormattedTypeValue:[typeValue stringValue]];
    }
    
    NSString *methodValue = [contacts[index] objectForKey:@"method"];
    NSLog(@"methodValue: %@", methodValue);
    if ([contacts[index] objectForKey:@"method"] != null) {
        ((UILabel *)[customView viewWithTag:2]).text = [customView getFormattedMethodValue:methodValue];
    }
    
    NSString *statusValue = [contacts[index] objectForKey:@"status"];
    NSLog(@"statusValue: %@", statusValue);
    if ([contacts[index] objectForKey:@"status"] != null) {
        ((UILabel *)[customView viewWithTag:3]).text = [customView getFormattedStatusesValue:statusValue];
    }
    
    NSString *noteValue = [contacts[index] objectForKey:@"note"];
    NSLog(@"noteValue: %@", noteValue);
    if ([contacts[index] objectForKey:@"note"] != null) {
        ((UITextView *)[customView viewWithTag:4]).text =noteValue;
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







-(void)makeCall:(id)sender
{
    
    NSLog(@"makeCall method called, sender is: %@", sender);
    NSString *title = [((UIButton *) sender) currentTitle];
    NSLog(@"currentTitle: %@", title);
    
    NSArray *title_split =  [title componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" -+()"]];
    
    NSString *title_cleaned= [title_split componentsJoinedByString:@""];
    NSLog(@"title_split: %@", title_split);
    NSLog(@"title_joined: %@", title_cleaned);
    
    NSString *theCall = [NSString stringWithFormat:@"telprompt://%@", title_cleaned];
    NSLog(@"theCall: %@", theCall);
    UIApplication *myApp = [UIApplication sharedApplication];
    
    NSURL *theCallUrl = [NSURL URLWithString:theCall];
    
    //check to see if the app can make calls before making the call
    if ([myApp canOpenURL:theCallUrl]) {
        NSLog(@"this app can open the url %@", theCallUrl);
        [myApp openURL:theCallUrl];
    } else {
        NSLog(@"ERROR: this app can NOT open the url: %@", theCallUrl);
        
        NSString *message = @"This device cannot make call. Try to find a phone booth.";
        
        // show alert view saying we are getting token
        _tokenAlert = [[UIAlertView alloc] initWithTitle:@"Whoopsies"
                                                 message:message
                                                delegate:nil
                                       cancelButtonTitle:@"Cancel"
                                       otherButtonTitles:nil];
        [_tokenAlert show];
    }
}

- (IBAction)writeEmail:(id)sender
{
    NSLog(@"writeEmail method called, sender is: %@", sender);
    NSString *title = [((UIButton *) sender) currentTitle];
    NSLog(@"currentTitle: %@", title);
    
    NSString *theEmail = [NSString stringWithFormat:@"mailTo://%@", title];
    NSLog(@"theEmail: %@", theEmail);
    UIApplication *myApp = [UIApplication sharedApplication];
    
    NSURL *theEmailUrl = [NSURL URLWithString:theEmail];
    
    //check to see if the app can make calls before making the call
    if ([myApp canOpenURL:theEmailUrl]) {
        NSLog(@"this app can open the url %@", theEmailUrl);
        [myApp openURL:theEmailUrl];
    } else {
        NSLog(@"ERROR: this app can NOT open the url: %@", theEmailUrl);
        
        NSString *message = @"This device cannot send emails. Go find an internet cafe.";
        
        // show alert view saying we are getting token
        _tokenAlert = [[UIAlertView alloc] initWithTitle:@"Whoopsies"
                                                 message:message
                                                delegate:nil
                                       cancelButtonTitle:@"Cancel"
                                       otherButtonTitles:nil];
        [_tokenAlert show];
    }
}

//get arbitrary fields from each person.
-(TGLOPerson *) personFieldsForObject:(NSDictionary*)person
{
    //NSLog(@"personFieldsForObject, person: %@", person);
    
    //create a temp person to which we will
    //return the reference to to caller
    TGLOPerson * person_ = [[TGLOPerson alloc] init];
    
    
    //check to see if any of the entries are equal to the
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
    
    
    if ([person objectForKey:@"email"] == [NSNull null]) {
        person_.email = nil;
    } else {
        person_.email = [person objectForKey:@"email"];
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
