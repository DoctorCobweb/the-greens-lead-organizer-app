//
//  TGLOEditPersonFromSearchViewController.m
//  TheGreensLeadOrganizerApp
//
//  Created by andre on 16/04/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//



//IMPORTANT INFO on Views
//1.views with tag = 123 are the tags to_be_removed when save button
//is hit
//2. the edit contact view has tag = 300 which allows us to get at
//the text input when save button is hit
//3. the label "Current Tags" has tag = 50. set in storyboard.
//we need this to rerender add/remove tags in ui after saving

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


@interface TGLOEditPersonFromSearchViewController ()
{
    NSString *token;
    NSMutableDictionary *tagsToDelete;
    TGLOPerson *oldPersonDetails;
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
    
    //UIColor * white_color = [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1.0f];
    
    
    //set an initial scroll view size
    self.scrollView.contentSize =CGSizeMake(320, 750);
    
    //set the initial container view to be equal
    //to scroll view size
    self.containerView.frame = CGRectMake(0, 0, 320, 750);
    
    if(self.person){
        //get the person object passed through from segue
        self.firstName.text = self.person.firstName;
        self.lastName.text = self.person.lastName;
        self.supportLevel.text = [TGLOPerson formattedSupportLevel:self.person.supportLevel];
        self.email.text = self.person.email;
        self.phone.text = self.person.phone;
        self.mobile.text = self.person.mobile;
        
        
        //also store the details in oldPersonDetails as an undo
        oldPersonDetails = [[TGLOPerson alloc] init];
        oldPersonDetails.firstName = self.person.firstName;
        oldPersonDetails.lastName = self.person.lastName;
        oldPersonDetails.email = self.person.email;
        oldPersonDetails.phone = self.person.phone;
        oldPersonDetails.mobile = self.person.mobile;
        oldPersonDetails.supportLevel = self.person.supportLevel;
        oldPersonDetails.tags = self.person.tags;
    }
    
    [self addTagViews];
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
    
    //finally add the new view to as last subview
    [self.containerView addSubview:newContactHeader];
}


- (void)toggleContact:(id)sender
{
    NSLog(@"in toggleContactTag");
    
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
    
    //setup listeners
    [typeValue addTarget:self action:@selector(typeValueHit:) forControlEvents:UIControlEventTouchUpInside];
    
    [methodValue addTarget:self action:@selector(methodValueHit:) forControlEvents:UIControlEventTouchUpInside];
    [statusValue addTarget:self action:@selector(statusValueHit:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UITextView *noteValue = ((UITextView *)[theContact viewWithTag:308]);
    
    
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


- (void)makeABlankContactView
{
    CGFloat labelSpacing = 20; //spacing between the views
    CGFloat makeMoreRoom = 250; //additional room on end of scroll/container view
    CGFloat labelWidth = 280;  //new label width
    CGFloat labelHeight= 230;   //new label height
    
    
    TGLOCustomEditContactView *customView = (TGLOCustomEditContactView*)[self fabricateANewView:@"TGLOCustomEditContactView" width:labelWidth height:labelHeight spacing:labelSpacing];
    
    customView.clipsToBounds = YES;
    customView.opaque = NO;
    
    //NSLog(@"customView.frame: %@",NSStringFromCGRect(customView.frame));
    
    [self updateScrollAndContainerViewSize:makeMoreRoom];
    
    //finally add the new custom contact view
    [self.containerView addSubview:customView];

    
 
}


- (void)addASingleTag:(NSString *)tag
{
    CGFloat labelSpacing = 10; //spacing between the views
    CGFloat makeMoreRoom = 45; //additional room on end of scroll/container view
    CGFloat labelWidth = 280;  //new label width
    CGFloat labelHeight= 35;   //new label height
    
    
    //UIButton *newButton= (UIButton*)[self fabricateANewView:@"UIButton" width:labelWidth height:labelHeight spacing:labelSpacing];
    //[newButton setTitle:tag forState:UIControlStateNormal];
    //NSLog(@"newButton currentTitle: %@", [newButton currentTitle]);
    //newButton.clipsToBounds = YES;
    //NSLog(@"buttons current backgroundImage: %@", [newButton currentBackgroundImage]);
    
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
        //NSLog(@"bundlePath: %@", bundlePath);
        NSString *imageLocation = [[NSString alloc] initWithFormat:@"%@/appIcon120x120.png", bundlePath ];
        UIImage *backgroundImage = [[UIImage alloc] initWithContentsOfFile:imageLocation];
        //NSLog(@"backgroundImage: %@", backgroundImage);
        
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
        
        NSString *imageLocation = [[NSString alloc] initWithFormat:@"%@/grey120x120.png", bundlePath ];
        UIImage *backgroundImage = [[UIImage alloc] initWithContentsOfFile:imageLocation];
        //NSLog(@"backgroundImage: %@", backgroundImage);
       
        //tag the parent view to say delete it. 1 == 'delete'
        //have to tag it here as it signifies the tag should
        //be deleted
        superView.tag = 123;
        
        
        [correspondingButton setBackgroundImage:backgroundImage forState:UIControlStateNormal];
        
        [tagsToDelete setObject:@"0" forKey:correspondingButton.titleLabel.text];
        
    } else {
        //user wants to keep the corresponding tag
        //NSLog(@"KEEP corresponding tag");
        NSString *imageLocation = [[NSString alloc] initWithFormat:@"%@/appIcon120x120.png", bundlePath ];
        UIImage *backgroundImage = [[UIImage alloc] initWithContentsOfFile:imageLocation];
        //NSLog(@"backgroundImage: %@", backgroundImage);
        
        [correspondingButton setBackgroundImage:backgroundImage forState:UIControlStateNormal];
        
        //reset the tag to defualt value of 0
        superView.tag = 0;
        
        [tagsToDelete setObject:@"1" forKey:correspondingButton.titleLabel.text];
    }
    
    NSLog(@"tagsToDelete is now: %@", tagsToDelete);

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

- (IBAction)saveChanges:(id)sender {
    NSLog(@"saveChanges button hit");
    
    
    //1.
    //create an updated person
    NSNumber *supportLevelTranslatedToNumber = [TGLOPerson inverseFormattedSupportLevel:self.supportLevel.text];
    NSString *supportLevelTranslated = [[NSString alloc] initWithFormat:@"%@", supportLevelTranslatedToNumber];
    NSLog(@"supportLevelNumber: %@", supportLevelTranslatedToNumber );
    
    TGLOPerson *updatedPerson = [[TGLOPerson alloc] init];
    updatedPerson.firstName = self.firstName.text;
    updatedPerson.lastName = self.lastName.text;
    updatedPerson.email = self.email.text;
    updatedPerson.phone = self.phone.text;
    updatedPerson.mobile = self.mobile.text;
    updatedPerson.supportLevel = supportLevelTranslatedToNumber;
    updatedPerson.recordID = self.person.recordID;  //dont change the recordID => copy it over!
    
    
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
    NSDictionary *updateBody =@{@"person":@{@"tags":[tagsToKeep allKeys], @"first_name":updatedPerson.firstName, @"last_name":updatedPerson.lastName, @"email1":updatedPerson.email, @"phone":updatedPerson.phone, @"mobile":updatedPerson.mobile, @"support_level":supportLevelTranslated}};
    
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
        
        //also set the person.tags mutable array to updated tags
        //[self.person.tags removeAllObjects];
        //NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:[tagsToKeep allKeys]];
        //self.person.tags = tempArray;
        
        
        //[self addTagViews];
        
        
        //NSSet * contacts_set = [responseObject objectForKey:@"results"];
        //NSArray *contacts_ = [contacts_set allObjects];
        
        //contacts = [[NSMutableArray alloc] initWithArray:contacts_];
        
        //NSLog(@"contacts: %@", contacts);
        //NSLog(@"%d contact records returned", [contacts count]);
        
        //[self addContactViews];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    
}


- (void) saveTheNewContact
{
    TGLOCustomEditContactView *newContact = (TGLOCustomEditContactView *)[self.containerView viewWithTag:300];

    
    NSString *contactType = ((UIButton *)[newContact viewWithTag:305]).titleLabel.text;
    NSString *methodType =  ((UIButton *)[newContact viewWithTag:306]).titleLabel.text;
    NSString *statusType =  ((UIButton *)[newContact viewWithTag:307]).titleLabel.text;
    NSString *noteType =    ((UITextField *)[newContact viewWithTag:308]).text;
    
    NSLog(@"contactType: %@", contactType);
    NSLog(@"methodType: %@", methodType);
    NSLog(@"statusType: %@", statusType);
    NSLog(@"noteType: %@", noteType);
    
    NSString *myNBId = [[NSUserDefaults standardUserDefaults] objectForKey:myNationBuilderId];

    //semantics:
    //*sender_id" as *broadcaster_id* contacted *recipient_id* for *contact_type* via *method*.
    //*note*
    //
    //if there's no id associated for *broadcaster_id* then broadcaster is left out of semantic string
    NSDictionary *contactBody = @{ @"contact": @{@"note": noteType, @"type_id":contactType, @"method":methodType, @"sender_id":myNBId, @"status":statusType, @"broadcaster_id": @"1", @"recipient_id": self.person.recordID}  };

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
        
        //also set the person.tags mutable array to updated tags
        //[self.person.tags removeAllObjects];
        //NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:[tagsToKeep allKeys]];
        //self.person.tags = tempArray;
        
        
        //[self addTagViews];
        
        
        //NSSet * contacts_set = [responseObject objectForKey:@"results"];
        //NSArray *contacts_ = [contacts_set allObjects];
        
        //contacts = [[NSMutableArray alloc] initWithArray:contacts_];
        
        //NSLog(@"contacts: %@", contacts);
        //NSLog(@"%d contact records returned", [contacts count]);
        
        //[self addContactViews];
        
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

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    TGLOCustomEditContactView *newContact = (TGLOCustomEditContactView *)[self.containerView viewWithTag:300];
    UIButton *contactType = ((UIButton *)[newContact viewWithTag:305]);
    UIButton *methodType =  ((UIButton *)[newContact viewWithTag:306]);
    UIButton *statusType =  ((UIButton *)[newContact viewWithTag:307]);
    NSString *typeValue_;
    NSString *methodValue_;
    NSString *statusValue_;
    
    if ([actionSheet.title isEqualToString:@"Choose type"]) {
        NSLog(@"actionSheet.title: %@", actionSheet.title);
        if (buttonIndex == [actionSheet cancelButtonIndex]) {
            // User pressed cancel -- abort
            typeValue_ = @"";
            [contactType setTitle:typeValue_ forState:UIControlStateNormal];
            return;
        }
        typeValue_ = [self translateContactType:buttonIndex];
        NSLog(@"translated typeValue_: %@", typeValue_);
        [contactType setTitle:typeValue_ forState:UIControlStateNormal];
        
    }
    
    if ([actionSheet.title isEqualToString:@"Choose method"]) {
        NSLog(@"actionSheet.title: %@", actionSheet.title);
        if (buttonIndex == [actionSheet cancelButtonIndex]) {
            // User pressed cancel -- abort
            methodValue_ = @"";
            return;
        }
        methodValue_ = [self translateContactMethod:buttonIndex];
        NSLog(@"translated methodValue_: %@", methodValue_);
        [methodType setTitle:methodValue_ forState:UIControlStateNormal];
        
        
    } if ([actionSheet.title isEqualToString:@"Choose status"]) {
        NSLog(@"actionSheet.title: %@", actionSheet.title);
        if (buttonIndex == [actionSheet cancelButtonIndex]) {
            // User pressed cancel -- abort
            statusValue_ = @"";
            return;
        }
        statusValue_ = [self translateContactStatus:buttonIndex];
        NSLog(@"translated statusValue_: %@", statusValue_);
        [statusType setTitle:statusValue_ forState:UIControlStateNormal];
    }
}


- (NSString *)translateContactType:(NSInteger)index
{
    NSDictionary *contactTypes = @{ @"1": @"Event debrief", @"2": @"Event confirmation", @"3":@"Inbox response", @"4":@"Donation thank-you", @"5":@"Donation request", @"6":@"Volunteer recruitment", @"7": @"Meeting 1:1", @"8": @"Volunteer intake",@"9": @"Voter outreach election",@"10": @"Voter outreach issue",@"11": @"Voter persuasion",@"12": @"diggity"};


    return [contactTypes valueForKey:[[NSString alloc] initWithFormat:@"%d", index + 1]];
}

- (NSString *)translateContactMethod:(NSInteger)index
{
    
    NSDictionary *contactMethods = @{@"0":@"Delivery",@"1":@"Door knock",@"2":@"Email",@"3":@"Email blast",@"4":@"Face to face",@"5":@"Facebook",@"6":@"Meeting",@"7":@"Phone call",@"8":@"Robocall",@"9":@"Snail mail",@"10":@"Text",@"11":@"Text blast",@"12":@"Tweet",@"13":@"Video call",@"14":@"Webinar",@"15":@"Other"};

    
    return [contactMethods objectForKey:[[NSString alloc] initWithFormat:@"%d", index]];
    
}

- (NSString *)translateContactStatus:(NSInteger)index
{
    NSDictionary *contactStatuses = @{@"0":@"Answered",@"1":@"Bad info",@"2":@"Inaccessible",@"3":@"Left message",@"4":@"Meaningful interaction",@"5":@"Not interested",@"6":@"No answer",@"7":@"Refused",@"8":@"Send information",@"9":@"Other"};
    
    return [contactStatuses objectForKey:[[NSString alloc] initWithFormat:@"%d", index]];


}
@end
