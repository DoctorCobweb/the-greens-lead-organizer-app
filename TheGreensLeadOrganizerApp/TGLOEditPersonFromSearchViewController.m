//
//  TGLOEditPersonFromSearchViewController.m
//  TheGreensLeadOrganizerApp
//
//  Created by andre on 16/04/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//



//IMPORTANT INFO on tags set for Views
//
//1.views with tag = 123 are the tags to_be_removed when save button
//is hit
//2. the edit contact view has tag = 300 which allows us to get at
//the text input when save button is hit
//3. the label "Current Tags" has tag = 50. set in storyboard.
//we need this to rerender add/remove tags in ui after saving
//4. the UIButton for Support Level has tag = 40. set in storyboard.


#import "TGLOEditPersonFromSearchViewController.h"
#import "TGLOCustomContactView.h"
#import "TGLOCustomEditContactView.h"
#import "TGLOCustomEditContactHeaderView.h"
#import "TGLOCustomEditTagView.h"
#import "AFNetworking.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "TGLOAppDelegate.h"

static NSString *myNationBuilderId = @"my_nation_builder_id";
static NSString *accessToken= @"access_token";
static NSString * myContactsUrl = @"https://%@.nationbuilder.com/api/v1/people/%@/contacts?page=1&per_page=10&access_token=%@";
static NSString * updatePeopleUrl = @"https://%@.nationbuilder.com/api/v1/people/%@?access_token=%@";
static NSString *buttonBackground = @"%@/appIcon120x120.png";
static NSString *greyButtonBackground =  @"%@/grey120x120.png";


@interface TGLOEditPersonFromSearchViewController ()
{
    NSString *token;
    
    //store the tags the user has chosen to delete in this dic
    NSMutableDictionary *tagsToDelete;
    
    //important to store old person details for an undo possibilty
    TGLOPerson *oldPersonDetails;
    
    //used to see if we should save a contact
    BOOL sendInANewContact;
}

@property (nonatomic, strong) UIAlertView *updateAlert;

@end

@implementation TGLOEditPersonFromSearchViewController


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
    
    //used to determine if user has signified they want to
    //add a new contact to  save
    sendInANewContact = NO;
    
	// Do any additional setup after loading the view.
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    token = [[NSUserDefaults standardUserDefaults] valueForKey:accessToken];
    NSLog(@"access_token: %@", token);
    
    [self setupTagsToDeleteArray];
    [self setUpAppearance];
    [self addTagViews];
}

- (void)setupTagsToDeleteArray
{
    //create a dictionary of 1's, keys corresponging to tag (slug?) name
    int number_of_tags = [self.person.tags count];
    tagsToDelete = [[NSMutableDictionary alloc] initWithCapacity:number_of_tags];
    
    for (int i = 0; i < number_of_tags; i++) {
        [tagsToDelete setObject:@"1" forKey:self.person.tags[i]];
    }
    
    NSLog(@"tagsToDelete: %@", tagsToDelete);
}


- (void)setUpAppearance
{
    self.title = @"Edit Person";
    
    //UIColor * whiteColor = [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1.0f];
    UIColor * blackColor = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:1.0f];
    
    
    //set an initial scroll view size
    self.scrollView.contentSize =CGSizeMake(320, 750);
    
    //set the initial container view to be equal
    //to scroll view size
    self.containerView.frame = CGRectMake(0, 0, 320, 750);
    
    //setup listern on the support level button
    [self.supportLevel addTarget:self action:@selector(supportLevelButtonHit:) forControlEvents:UIControlEventTouchUpInside];
    
    
    if(self.person){
        //get the person object passed through from segue
        self.firstName.text = self.person.firstName;
        self.lastName.text = self.person.lastName;
        [self.supportLevel setTitle:[TGLOPerson formattedSupportLevel:self.person.supportLevel] forState:UIControlStateNormal];
        [self.supportLevel setTitleColor:blackColor forState:UIControlStateNormal];
        self.email.text = self.person.email;
        self.phone.text = self.person.phone;
        self.mobile.text = self.person.mobile;
        
        
        //store the person details in oldPersonDetails as an undo
        oldPersonDetails = [[TGLOPerson alloc] init];
        oldPersonDetails.firstName = self.person.firstName;
        oldPersonDetails.lastName = self.person.lastName;
        oldPersonDetails.email = self.person.email;
        oldPersonDetails.phone = self.person.phone;
        oldPersonDetails.mobile = self.person.mobile;
        oldPersonDetails.supportLevel = self.person.supportLevel;
        oldPersonDetails.tags = self.person.tags;
    }
    
}

-(void)addTagViews
{
    NSLog(@"SETTING UP ALL MY TAGS");
    
    for (NSString *tag in self.person.tags) {
        [self addASingleTag:tag];
    }
    
    [self addContactsLabel];
    [self makeABlankContactView];
    //NSLog(@"self subviews: %@", [self.containerView subviews]);
}

- (void)addASingleTag:(NSString *)tag
{
    CGFloat labelSpacing = 10; //spacing between the views
    CGFloat makeMoreRoom = 45; //additional room on end of scrollview
    CGFloat labelWidth = 280;  //new label width
    CGFloat labelHeight= 35;   //new label height
    
    TGLOCustomEditTagView *aCustomEditTag = (TGLOCustomEditTagView *)[self fabricateANewView:@"TGLOCustomEditTagView" width:labelWidth height:labelHeight spacing:labelSpacing];
    aCustomEditTag.clipsToBounds = YES;
    
    NSArray *customEditTagSubViews = [aCustomEditTag subviews];
    
    UIButton *theButton = (UIButton *)customEditTagSubViews[0];
    UISwitch *theSwitch = (UISwitch *)customEditTagSubViews[1];
    [theButton setTitle:tag forState:UIControlStateNormal];
    //register an action for the button to trigger when pressed
    [theSwitch addTarget:self action:@selector(toggleTag:) forControlEvents:UIControlEventTouchUpInside];
    
    
    //update the scroll and container view to fit/display new content
    [self updateScrollAndContainerViewSize:makeMoreRoom];
    
    //finally add the new view to as last subview
    [self.containerView addSubview:aCustomEditTag];
}


- (void)addContactsLabel
{
    CGFloat labelSpacing = 10; //spacing between the views
    CGFloat makeMoreRoom = 45; //additional room on end of scroll/container view
    CGFloat labelWidth = 280;  //new label width
    CGFloat labelHeight= 35;   //new label height
    
    TGLOCustomEditContactHeaderView *newContactHeader = (TGLOCustomEditContactHeaderView *)[self fabricateANewView:@"TGLOCustomEditContactHeaderView" width:labelWidth height:labelHeight spacing:labelSpacing];
    
    //setup the switch toggle for logging a new contact
    UISwitch *newContactSwitch = (UISwitch *)[newContactHeader viewWithTag:1];
    
    [newContactSwitch addTarget:self action:@selector(toggleContact:) forControlEvents:UIControlEventTouchUpInside];
    
    [self updateScrollAndContainerViewSize:makeMoreRoom];
    
    //finally add the new view as last subview
    [self.containerView addSubview:newContactHeader];
}



- (void)makeABlankContactView
{
    CGFloat labelSpacing = 20; //spacing between the views
    CGFloat makeMoreRoom = 250; //additional room on end of scrollview
    CGFloat labelWidth = 280;  //new label width
    CGFloat labelHeight= 230;   //new label height
    
    
    TGLOCustomEditContactView *customView = (TGLOCustomEditContactView*)[self fabricateANewView:@"TGLOCustomEditContactView" width:labelWidth height:labelHeight spacing:labelSpacing];
    
    customView.clipsToBounds = YES;
    customView.opaque = NO;
    
    [self updateScrollAndContainerViewSize:makeMoreRoom];
    
    //finally add the new custom contact view
    [self.containerView addSubview:customView];
}


//triggered when user toggles the switch for a new contact
- (void)toggleContact:(id)sender
{
    UIColor *disabledEditing = [UIColor colorWithRed:230/255.0f green:230/255.0f blue:230/255.0f alpha:1.0f];;
    UIColor *disabledEditingDark = [UIColor colorWithRed:220/255.0f green:220/255.0f blue:220/255.0f alpha:1.0f];
    UIColor *backgroundValue = [UIColor colorWithRed:242/255.0f green:178/255.0f blue:210/255.0f alpha:1.0f];
    UIColor *backgroundDark = [UIColor colorWithRed:235/255.0f green:230/255.0f blue:235/255.0f alpha:1.0f];;
    UIColor *backgroundLabel = [UIColor colorWithRed:197/255.0f green:72/255.0f blue:148/255.0f alpha:1.0f];;
    
    
    
    UISwitch *theSwitch = (UISwitch *)sender;
    TGLOCustomEditContactView *theContact = (TGLOCustomEditContactView*) [self.containerView viewWithTag:300];
    UILabel *typeLabel = ((UILabel *)[theContact viewWithTag:301]);
    UILabel *methodLabel = ((UILabel *)[theContact viewWithTag:302]);
    UILabel *statusLabel = ((UILabel *)[theContact viewWithTag:303]);
    UILabel *noteLabel = ((UILabel *)[theContact viewWithTag:304]);
    UIButton *typeValue = ((UIButton *)[theContact viewWithTag:305]);
    UIButton *methodValue = ((UIButton *)[theContact viewWithTag:306]);
    UIButton *statusValue = ((UIButton *)[theContact viewWithTag:307]);
    UITextView *noteValue = ((UITextView *)[theContact viewWithTag:308]);
    
    
    //setup listeners
    [typeValue addTarget:self action:@selector(typeValueHit:) forControlEvents:UIControlEventTouchUpInside];
    
    [methodValue addTarget:self action:@selector(methodValueHit:) forControlEvents:UIControlEventTouchUpInside];
    [statusValue addTarget:self action:@selector(statusValueHit:) forControlEvents:UIControlEventTouchUpInside];
    
    
    if (theSwitch.on ) {
        
        //set flag
        sendInANewContact = YES;
        
        //make contact look available for editing
        theContact.backgroundColor = backgroundDark;
        typeLabel.backgroundColor = backgroundLabel;
        methodLabel.backgroundColor = backgroundLabel;
        statusLabel.backgroundColor = backgroundLabel;
        noteLabel.backgroundColor = backgroundLabel;
        
        typeValue.backgroundColor = backgroundValue;
        methodValue.backgroundColor = backgroundValue;
        statusValue.backgroundColor = backgroundValue;
        noteValue.backgroundColor = backgroundValue;
        
        //default editing is ON
        typeValue.userInteractionEnabled = YES;
        methodValue.userInteractionEnabled = YES;
        statusValue.userInteractionEnabled = YES;
        noteValue.editable = YES;
        noteValue.scrollEnabled = YES;
        
    } else {
        //set flag
        sendInANewContact = NO;
        
        //make swith look NOT available for editing
        theContact.backgroundColor = disabledEditingDark;
        typeLabel.backgroundColor = disabledEditing;
        methodLabel.backgroundColor = disabledEditing;
        statusLabel.backgroundColor = disabledEditing;
        noteLabel.backgroundColor = disabledEditing;
        
        typeValue.backgroundColor = disabledEditing;
        methodValue.backgroundColor = disabledEditing;
        statusValue.backgroundColor = disabledEditing;
        noteValue.backgroundColor = disabledEditing;
        
        
        //default editing is OFF
        typeValue.userInteractionEnabled = NO;
        methodValue.userInteractionEnabled = NO;
        statusValue.userInteractionEnabled = NO;
        noteValue.editable = NO;
        noteValue.scrollEnabled = NO;
    }
}





// utility method for construct different types of views
- (id) fabricateANewView:(NSString *)viewType width:(CGFloat)viewWidth height:(CGFloat)viewHeight spacing: (CGFloat)viewSpacing
{
    
    //NSLog(@"self.containerView frame: %@",NSStringFromCGRect([self.containerView frame]));
    
    //CGRect containerFrame = [self.containerView frame];
    //CGFloat containerHeight = CGRectGetHeight(containerFrame);
    //CGFloat containerWidth = CGRectGetWidth(containerFrame);
    
    //NSLog(@"containerFrame height: %f", containerHeight);
    //NSLog(@"containerFrame width: %f", containerWidth);
    
    
    NSArray *containerSubviews = [self.containerView subviews];
    
    CGRect lastViewFrame = ((UILabel *)[containerSubviews lastObject]).frame;
    //NSLog(@"lastViewFrame: %@", NSStringFromCGRect(lastViewFrame));
    
    //get dimensions of the lower left corner of
    //last subview of containerView
    CGFloat lastViewYLocation = CGRectGetMaxY(lastViewFrame);
    CGFloat lastViewXLocation = CGRectGetMinX(lastViewFrame);
    //NSLog(@"lastViewYLocation: %f, lastViewXLocation: %f", lastViewYLocation, lastViewXLocation);
    
    //now create a new rect, taking into account
    //location of last subview
    CGRect viewRect = CGRectMake(lastViewXLocation, lastViewYLocation + viewSpacing, viewWidth, viewHeight);
    
    
    //the meat of the method
    if ([viewType  isEqualToString:@"UILabel"]){
        return [[UILabel alloc] initWithFrame:viewRect];
    } else if ([viewType isEqualToString:@"UITextField"]) {
        return [[UITextField alloc] initWithFrame:viewRect];
    } else if ([viewType isEqualToString:@"TGLOCustomContactView"]) {
        return [[TGLOCustomContactView alloc] initWithFrame:viewRect];
    } else if ([viewType isEqualToString:@"TGLOCustomEditContactView"]) {
        return [[TGLOCustomEditContactView alloc] initWithFrame:viewRect];
    } else if ([viewType isEqualToString:@"TGLOCustomEditContactHeaderView"]) {
        return  [[TGLOCustomEditContactHeaderView alloc] initWithFrame:viewRect];
    } else if ([viewType isEqualToString:@"UIButton"]) {
        UIColor * blackColor = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:1.0f];

        //setting the background color of button etc
        UIButton *tempButton =[UIButton buttonWithType:UIButtonTypeSystem];
        tempButton.frame = viewRect;
        
        [tempButton setTitleColor:blackColor forState:UIControlStateNormal];
        
        NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
        NSString *imageLocation = [[NSString alloc] initWithFormat:buttonBackground, bundlePath ];
        UIImage *backgroundImage = [[UIImage alloc] initWithContentsOfFile:imageLocation];
        [tempButton setBackgroundImage:backgroundImage forState:UIControlStateNormal];
        
        //register an action for the button to trigger when pressed
        [tempButton addTarget:self action:@selector(toggleTag:) forControlEvents:UIControlEventValueChanged];
        
        return tempButton;
    } else if ([viewType isEqualToString:@"TGLOCustomEditTagView"]) {
    
        return [[TGLOCustomEditTagView alloc] initWithFrame:viewRect];
    
    } else {
        return @"ERROR";
    }
}

- (void)toggleTag:(id)sender
{
    NSLog(@"toggleTag called, sender: %@", sender);
    UISwitch *switch_ = (UISwitch *)sender;
    //get reference to parent TGLOCustomEditTagView, then
    //find the corresponding UIButton
    TGLOCustomEditTagView *superView = (TGLOCustomEditTagView *)[switch_ superview];
    NSArray *subviews = [superView subviews];
    UIButton *correspondingButton = (UIButton *) subviews[0];
    
    //NSLog(@"the state of the swith is now: %d", switch_.on);
    
    //first, get the background and state of the button
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    //NSLog(@"bundlePath: %@", bundlePath);
    
    if (!switch_.on) {
        //user wants to delete the corresponding tag
        NSLog(@"DELETE corresponding tag");
        
        NSString *imageLocation = [[NSString alloc] initWithFormat:greyButtonBackground, bundlePath ];
        UIImage *backgroundImage = [[UIImage alloc] initWithContentsOfFile:imageLocation];
       
        //tag the parent view to say delete it. 1 == 'delete'
        //have to tag it here as it signifies the tag should
        //be deleted
        superView.tag = 123;
        
        [correspondingButton setBackgroundImage:backgroundImage forState:UIControlStateNormal];
        
        [tagsToDelete setObject:@"0" forKey:correspondingButton.titleLabel.text];
        
    } else {
        //user wants to keep the corresponding tag
        //NSLog(@"KEEP corresponding tag");
        NSString *imageLocation = [[NSString alloc] initWithFormat:buttonBackground, bundlePath ];
        UIImage *backgroundImage = [[UIImage alloc] initWithContentsOfFile:imageLocation];
        //NSLog(@"backgroundImage: %@", backgroundImage);
        
        [correspondingButton setBackgroundImage:backgroundImage forState:UIControlStateNormal];
        
        //reset the tag to defualt value of 0
        superView.tag = 0;
        
        [tagsToDelete setObject:@"1" forKey:correspondingButton.titleLabel.text];
    }
    NSLog(@"tagsToDelete is now: %@", tagsToDelete);
}


- (IBAction)saveChanges:(id)sender {
    NSLog(@"saveChanges button hit");
    
    //1.
    //create an updated person
    TGLOPerson *updatedPerson = [[TGLOPerson alloc] init];
    updatedPerson.firstName = self.firstName.text;
    updatedPerson.lastName = self.lastName.text;
    updatedPerson.email = self.email.text;
    updatedPerson.phone = self.phone.text;
    updatedPerson.mobile = self.mobile.text;
    updatedPerson.recordID = self.person.recordID;  //dont change the recordID => copy it over!
    
    //you have to handle supportLevel a bit differently
    NSString *theSupportLevel = [updatedPerson apiVersionOfSupportLevel:self.supportLevel.titleLabel.text];
    //needed for NSString -> NSNumber
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    updatedPerson.supportLevel = [f numberFromString:theSupportLevel];
    
    
    //2. tags update
    //construct the body for PUT request. contains surviving tags
    //which still have a value of @"1" in tagsToDelete array
    int number_of_tags = [tagsToDelete count];
    NSArray *tagsKey = [tagsToDelete allKeys];
    NSMutableDictionary *tagsToKeep = [[NSMutableDictionary alloc] initWithCapacity:number_of_tags];
    
    for (int i = 0; i < number_of_tags; i++) {
        NSString *key_ = tagsKey[i];
        NSString *value_ = [tagsToDelete objectForKey:tagsKey[i]];
        
        if (![value_ isEqualToString:@"0"]) {
            [tagsToKeep setObject:value_ forKey:key_];
        }
    }
    
    //also include the new tag from addNewTag property
    //note: if user adds tags like "v_book, flow, gurkin"
    //nation builder will parse these into individual tags
    //separated by commas. cool!
    if (![self.addANewTag.text isEqualToString:@""]) {
        NSLog(@"adding in a new tag also: %@", self.addANewTag.text);
        [tagsToKeep setObject:@"1" forKey:self.addANewTag.text];
    }
    
    NSLog(@"tagToKeep dic: %@", tagsToKeep);
    updatedPerson.tags = [[NSMutableArray alloc] initWithArray:[tagsToKeep allKeys]];
    
    
    //tagsToDelete dic should only hold tags we want to keep
    //=> can use this tagsToDelete as body obj for PUT request below
    NSDictionary *updateBody =@{@"person":@{@"tags":[tagsToKeep allKeys], @"first_name":updatedPerson.firstName, @"last_name":updatedPerson.lastName, @"email1":updatedPerson.email, @"phone":updatedPerson.phone, @"mobile":updatedPerson.mobile, @"support_level":theSupportLevel}};
    
    NSLog(@"KEEPing tags: %@", [tagsToKeep allKeys]);
    NSLog(@"%@", updateBody);
    
    
    //update taggings
    NSString * updatePeopleUrl_ = [NSString stringWithFormat:updatePeopleUrl, nationBuilderSlugValue, self.person.recordID, token];
    
    //need to get notes on the person from a different api, namely
    // the contacts api
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    //must set request serializer to application/json. otherwise 406
    //is responded
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    NSLog(@"manager.requestSerializer: %@", manager.requestSerializer);
    
    [manager PUT:updatePeopleUrl_ parameters:updateBody success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@" PUT => updating tags and person details with response %@",responseObject);
        NSLog(@"SUCCESSfully deleted tags, added a new tag and updated person details.");
        
        //UPDATE PERSON DETAILS property
        //because changes were successul we can now swap over the
        //self.person to use updated details
        //change over to use new person details. careful.
        self.person = updatedPerson;
        //sanity check:
        NSLog(@"self.person.firstName: %@", self.person.firstName);
        NSLog(@"oldPersonDetails.firstName: %@", oldPersonDetails.firstName);
        NSLog(@"self.person.supportLevel: %@", self.person.supportLevel);
        NSLog(@"oldPersonDetails.supportLevel: %@", oldPersonDetails.supportLevel);
        NSLog(@"self.person.tags: %@", self.person.tags);
        NSLog(@"oldPersonDetails.tags: %@", oldPersonDetails.tags);
          
        
        //we should go onto saving a new contact as soon as possible
        //if it has been signalled to be added
        if (sendInANewContact) {
            [self saveTheNewContact];
        } else {
            [self reRenderUI];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}


- (void) saveTheNewContact
{
    TGLOCustomEditContactView *newContact = (TGLOCustomEditContactView *)[self.containerView viewWithTag:300];

    
    NSString *contactType_ = ((UIButton *)[newContact viewWithTag:305]).titleLabel.text;
    NSString *contactMethod_ =  ((UIButton *)[newContact viewWithTag:306]).titleLabel.text;
    NSString *contactStatus_ =  ((UIButton *)[newContact viewWithTag:307]).titleLabel.text;
    NSString *noteType =    ((UITextField *)[newContact viewWithTag:308]).text;
    
    //need to translate the 3 button values to api values for contact api call
    NSString *contactType = [newContact apiVersionOfContactType:contactType_];
    NSString *contactMethod = [newContact apiVersionOfContactMethod:contactMethod_];
    NSString *contactStatus = [newContact apiVersionOfContactStatus:contactStatus_];
    
    NSLog(@"contactType: %@", contactType);
    NSLog(@"contactMethod: %@", contactMethod);
    NSLog(@"contactStatus: %@", contactStatus);
    NSLog(@"noteType: %@", noteType);
    
    NSString *myNBId = [[NSUserDefaults standardUserDefaults] objectForKey:myNationBuilderId];

    //semantics:
    //*sender_id" as *broadcaster_id* contacted *recipient_id* for *contact_type* via *method*.
    //*note*
    //
    //if there's no id associated for *broadcaster_id* then broadcaster is left out of semantic string
    NSDictionary *contactBody = @{ @"contact": @{@"note": noteType, @"type_id":contactType, @"method":contactMethod, @"sender_id":myNBId, @"status":contactStatus, @"broadcaster_id": @"1", @"recipient_id": self.person.recordID}  };

    //post endpoint for making new contact
    NSString * myContactsUrl_ = [NSString stringWithFormat:myContactsUrl, nationBuilderSlugValue, self.person.recordID, token];
    
    //need to get notes on the person from a different api, namely
    // the contacts api
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    //must set request serializer to application/json. otherwise 406
    //is responded
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    NSLog(@"manager.requestSerializer: %@", manager.requestSerializer);
    
    [manager POST:myContactsUrl_ parameters:contactBody success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@" POST => updating contact with response %@",responseObject);
        NSLog(@"SUCCESSfully added new contact.");
        
        [self reRenderUI];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)displaySuccessAlert
{
        NSString *message = @"You successfully updated the record for the person.";
        // show alert view saying we are getting token
        _updateAlert = [[UIAlertView alloc] initWithTitle:@"Update success"
                                                 message:message
                                                delegate:nil
                                       cancelButtonTitle:@"Okay"
                                       otherButtonTitles:nil];
        [_updateAlert show];


}

- (void)reRenderUI
{
    //reset the field
    self.addANewTag.text = @"";
    
    UILabel *currentTagsLabel = (UILabel *)[self.containerView viewWithTag:50];
    NSArray *allSubViews = [self.containerView subviews];
    
    //this block of code removes all the views below
    //currentTagsLabel in preparation of rerending updated details
    NSLog(@"finding currentTagsLabel view...");
    int no_of_subviews = [allSubViews count];
    int current_tags_label_index;
    BOOL foundIt = NO;
    //this removes all subviews after currentTagsLabel
    for (int j = 0; j < no_of_subviews; j++) {
        
        if (foundIt) {
            [allSubViews[j] removeFromSuperview];
        }
        
        if (allSubViews[j] == currentTagsLabel) {
            current_tags_label_index = j;
            NSLog(@"current_tags_label_index = %d", current_tags_label_index);
            
            foundIt = YES;
        }
     }
    
    [self addTagViews];
    [self displaySuccessAlert];
    [self reRenderPreviousControllerUI];
}

//call the didUpdatePereson method of the previous view controller
//pass over the updated person details and tell it to rerender its ui
- (void)reRenderPreviousControllerUI
{
    if([self.delegate respondsToSelector:@selector(didUpdatePerson:)])
    {
        NSLog(@"calling didUpdatePerson....");
        [self.delegate didUpdatePerson:self.person];
    }
}



- (void)typeValueHit:(id)sender
{
    NSLog(@"typeValueHit, in TGLOEditPersonFromSearchViewController");
    UIActionSheet *typeValueActionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose type"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Event debrief", @"Event confirmation", @"Inbox response", @"Donation thank-you", @"Donation request",@"Volunteer recruitment",@"Meeting 1:1",@"Volunteer intake",@"Voter outreach election",@"Voter outreach issue",@"Voter persuasion",@"diggity", nil];
    [typeValueActionSheet showInView:self.containerView];
}


- (void)methodValueHit:(id)sender
{
    NSLog(@"methodValueHit, in TGLOEditPersonFromSearchViewController");
    UIActionSheet *methodValueActionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose method"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Delivery", @"Door knock",@"Email",@"Email blast",@"Face to face",@"Facebook",@"Meeting",@"Phone call",@"Robocall",@"Snail mail",@"Text",@"Text blast",@"Tweet",@"Video call",@"Webinar",@"Other", nil];
    [methodValueActionSheet showInView:self.containerView];
}


- (void)statusValueHit:(id)sender
{
    NSLog(@"statusValueHit, in TGLOEditPersonFromSearchViewController");
    UIActionSheet *statusValueActionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose status"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Answered", @"Bad info",@"Inaccessible",@"Left message",@"Meaningful interaction",@"Not interested",@"No answer",@"Refused",@"Send information",@"Other", nil];
    [statusValueActionSheet showInView:self.containerView];
}

- (void)supportLevelButtonHit:(id)sender
{

    NSLog(@"supportLevelButtonHit call");
    UIActionSheet *supportLevelActionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose support level"
                                                                        delegate:self
                                                               cancelButtonTitle:@"Cancel"
                                                          destructiveButtonTitle:nil
                                                               otherButtonTitles:@"Strong support", @"Weak support",@"Undecided",@"Weak oppose",@"Strong oppose", nil];
    [supportLevelActionSheet showInView:self.containerView];

}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    TGLOCustomEditContactView *newContact = (TGLOCustomEditContactView *)[self.containerView viewWithTag:300];
    UIButton *contactTypeButton = ((UIButton *)[newContact viewWithTag:305]);
    UIButton *methodTypeButton =  ((UIButton *)[newContact viewWithTag:306]);
    UIButton *statusTypeButton =  ((UIButton *)[newContact viewWithTag:307]);
    UIButton *supportLevelButton =  ((UIButton *)[self.containerView viewWithTag:40]);
    NSString *typeValue_;
    NSString *methodValue_;
    NSString *statusValue_;
    NSString *supportLevel_;
    
    if ([actionSheet.title isEqualToString:@"Choose type"]) {
        NSLog(@"actionSheet.title: %@", actionSheet.title);
        if (buttonIndex == [actionSheet cancelButtonIndex]) {
            // User pressed cancel -- abort
            typeValue_ = @"";
            [contactTypeButton setTitle:typeValue_ forState:UIControlStateNormal];
            return;
        }
        typeValue_ = [TGLOCustomEditContactView translateContactType:buttonIndex];
        NSLog(@"translated typeValue_: %@", typeValue_);
        [contactTypeButton setTitle:typeValue_ forState:UIControlStateNormal];
    }
    
    if ([actionSheet.title isEqualToString:@"Choose method"]) {
        NSLog(@"actionSheet.title: %@", actionSheet.title);
        if (buttonIndex == [actionSheet cancelButtonIndex]) {
            // User pressed cancel -- abort
            methodValue_ = @"";
            [methodTypeButton setTitle:methodValue_ forState:UIControlStateNormal];
            return;
        }
        methodValue_ = [TGLOCustomEditContactView translateContactMethod:buttonIndex];
        NSLog(@"translated methodValue_: %@", methodValue_);
        [methodTypeButton setTitle:methodValue_ forState:UIControlStateNormal];
    }
    
    if ([actionSheet.title isEqualToString:@"Choose status"]) {
        NSLog(@"actionSheet.title: %@", actionSheet.title);
        if (buttonIndex == [actionSheet cancelButtonIndex]) {
            // User pressed cancel -- abort
            statusValue_ = @"";
            [statusTypeButton setTitle:statusValue_ forState:UIControlStateNormal];
            return;
        }
        statusValue_ = [TGLOCustomEditContactView translateContactStatus:buttonIndex];
        NSLog(@"translated statusValue_: %@", statusValue_);
        [statusTypeButton setTitle:statusValue_ forState:UIControlStateNormal];
    }
    if ([actionSheet.title isEqualToString:@"Choose support level"]) {
        NSLog(@"actionSheet.title: %@", actionSheet.title);
        if (buttonIndex == [actionSheet cancelButtonIndex]) {
            // User pressed cancel -- abort
            //dont reset the title! because it will throw error
            //as support level must be non nil
            return;
        }
        supportLevel_= [self translateSupportLevel:buttonIndex];
        NSLog(@"translated supportLevel_: %@", supportLevel_);
        [supportLevelButton  setTitle:supportLevel_ forState:UIControlStateNormal];
        NSLog(@"supportLevelButton title: %@", supportLevelButton.titleLabel.text);
    }
}


- (NSString *)translateSupportLevel:(NSInteger)index
{
    NSDictionary *supportLevel = @{ @"1":@"Strong support", @"2":@"Weak support", @"3":@"Undecided", @"4":@"Weak oppose", @"5":@"Strong oppose"};

    return [supportLevel valueForKey:[[NSString alloc] initWithFormat:@"%d", index + 1]];
}



//adding in more room to the scroll and container view to fit in newly added content
- (void)updateScrollAndContainerViewSize:(CGFloat)makeMoreRoom
{
    //NSLog(@"in updateScrollAndContainerViewSize");
    //update the scroll height to accomodate for
    //new added view
    CGSize contentSize = self.scrollView.contentSize;
    CGFloat scrollHeight = contentSize.height;
    
    self.scrollView.contentSize =CGSizeMake(320, scrollHeight + makeMoreRoom);
    //NSLog(@"self.scrollView.contentSize: %@", NSStringFromCGSize(self.scrollView.contentSize));
    
    
    //must also update the containerView height
    CGRect containerViewFrame = self.containerView.frame;
    
    //NSLog(@"self.containerView.frame Max X: %f", CGRectGetMaxX(containerViewFrame));
    //NSLog(@"self.containerView.frame Max Y: %f", CGRectGetMaxY(containerViewFrame));
    
    self.containerView.frame = CGRectMake(0, 0, (CGRectGetMaxX(containerViewFrame)), (CGRectGetMaxY(containerViewFrame)) + makeMoreRoom);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
