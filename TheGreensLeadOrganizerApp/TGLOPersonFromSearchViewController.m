//
//  TGLOPersonFromSearchViewController.m
//  TheGreensLeadOrganizerApp
//
//  Created by andre on 12/04/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import "TGLOPersonFromSearchViewController.h"
#import "TGLOAppDelegate.h"
#import "AFNetworking.h"
#import "TGLOCustomContactView.h"

static NSString *accessToken= @"access_token";
static NSString * myContactsUrl = @"https://%@.nationbuilder.com/api/v1/people/%@/contacts?page=1&per_page=10&access_token=%@";



@interface TGLOPersonFromSearchViewController ()
{
    NSString *token;
    NSMutableArray *contacts;
    NSDictionary *contactTypes;
    NSDictionary *methodTypes;
    NSDictionary *statusTypes;
    
}
@property (nonatomic, strong) UIAlertView *tokenAlert;


@end

@implementation TGLOPersonFromSearchViewController

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
    
    contactTypes = @{ @"1": @"Event debrief", @"2": @"Event confirmation", @"3":@"Inbox response", @"4":@"Donation thank-you", @"5":@"Donation request", @"6":@"Volunteer recruitment", @"7": @"Meeting 1:1", @"8": @"Volunteer intake",@"9": @"Voter outreach election",@"10": @"Voter outreach issue",@"11": @"Voter persuasion",@"12": @"diggity"};
    
    
    methodTypes = @{@"delivery":@"Delivery",@"door_knock":@"Door knock",@"email":@"Email",@"email_blast":@"Email blast",@"face_to_face":@"Face to face",@"facebook":@"Facebook",@"meeting":@"Meeting",@"phone_call":@"Phone call",@"robocall":@"Robocall",@"snail_mail":@"Snail mail",@"text":@"Text",@"text_blast":@"Text blast",@"tweet":@"Tweet",@"video_call":@"Video call",@"webinar":@"Webinar",@"other":@"Other"};
    
    statusTypes = @{@"answered":@"Answered",@"bad_info":@"Bad info",@"inaccessible":@"Inaccessible",@"left_message":@"Left message",@"meaningful_interaction":@"Meaningful interaction",@"not_interested":@"Not interested",@"no_answer":@"No answer",@"refused":@"Refused",@"send_information":@"Send information",@"other":@"Other"};
    
    [self setUpAppearance];
}


- (void)setUpAppearance
{
    self.title = @"Person";
    
    UIColor * white_color = [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1.0f];
    
    
    //set an initial scroll view size
    self.scrollView.contentSize =CGSizeMake(320, 550);
    
    //set the initial container view to be equal
    //to scroll view size
    self.containerView.frame = CGRectMake(0, 0, 320, 550);
    
    if(self.person){
        //get the person object passed through from segue
        self.firstName.text = self.person.firstName;
        self.lastName.text = self.person.lastName;
        self.supportLevel.text = [self.person.supportLevel stringValue];
        
        
        
        [self.email setTitle:self.person.email forState:UIControlStateNormal];
        [self.email setTitleColor:white_color forState:UIControlStateNormal];
        
        [self.phone setTitleColor:white_color forState:UIControlStateNormal];
        [self.phone setTitle:self.person.phone forState:UIControlStateNormal];
        
        [self.mobile setTitle:self.person.mobile forState:UIControlStateNormal];
        [self.mobile setTitleColor:white_color forState:UIControlStateNormal];
        
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
    
    NSLog(@"in getAllMyContacts");
    NSLog(@"self.person.recordID: %@", self.person.recordID);
    NSLog(@"token: %@", token);
    
    if ([token isEqual:nil]){
        NSLog(@"token is equal to nil");
        
    }
    if ([token isEqual:Nil]){
        NSLog(@"token is equal to Nil");
        
    }
    if ([token isEqual:[NSNull null]]){
        NSLog(@"token is equal to [NSNull null]");
    }
    
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
    if ([contacts[index] objectForKey:@"type_id"] != null && !![contactTypes objectForKey:([typeValue stringValue])]) {
        ((UILabel *)customViews_[4]).text = [contactTypes objectForKey:([typeValue stringValue])];
    }
    
    NSString *methodValue = [contacts[index] objectForKey:@"method"];
    NSLog(@"methodValue: %@", methodValue);
    if ([contacts[index] objectForKey:@"method"] != null && !![methodTypes objectForKey:methodValue]) {
        ((UILabel *)customViews_[5]).text = [methodTypes objectForKey:methodValue];
    }
    
    NSString *statusValue = [contacts[index] objectForKey:@"status"];
    NSLog(@"statusValue: %@", statusValue);
    if ([contacts[index] objectForKey:@"status"] != null && !![statusTypes objectForKey:  statusValue]) {
        ((UILabel *)customViews_[6]).text = [statusTypes objectForKey:  statusValue];
    }
    
    NSString *noteValue = [contacts[index] objectForKey:@"note"];
    NSLog(@"noteValue: %@", noteValue);
    if ([contacts[index] objectForKey:@"note"] != null) {
        ((UITextView *)[customView subviews][7]).text =noteValue;
    }
    
    /*
    NSNull *null = [NSNull null];
    NSNumber *typeValue = [contacts[index] objectForKey:@"type_id"];
    NSLog(@"typeValue: %@", typeValue);
    if ([contacts[index] objectForKey:@"type_id"] != null ) {
        ((UILabel *)customViews_[4]).text = [typeValue stringValue];
    }
    
    NSString *methodValue = [contacts[index] objectForKey:@"method"];
    NSLog(@"methodValue: %@", methodValue);
    if ([contacts[index] objectForKey:@"method"] != null) {
        ((UILabel *)customViews_[5]).text = methodValue;
    }
    
    NSString *statusValue = [contacts[index] objectForKey:@"status"];
    NSLog(@"statusValue: %@", statusValue);
    if ([contacts[index] objectForKey:@"status"] != null) {
        ((UILabel *)customViews_[6]).text = statusValue;
    }
    
    NSString *noteValue = [contacts[index] objectForKey:@"note"];
    NSLog(@"noteValue: %@", noteValue);
    if ([contacts[index] objectForKey:@"note"] != null) {
        ((UITextView *)[customView subviews][7]).text =noteValue;
    }
     */
    
    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
