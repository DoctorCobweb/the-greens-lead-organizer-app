//
//  TGLOEditPersonFromSearchViewController.m
//  TheGreensLeadOrganizerApp
//
//  Created by andre on 16/04/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import "TGLOEditPersonFromSearchViewController.h"
#import "TGLOCustomContactView.h"
#import "TGLOCustomEditTagView.h"
#import "AFNetworking.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "TGLOAppDelegate.h"

static NSString *accessToken= @"access_token";
static NSString * myContactsUrl = @"https://%@.nationbuilder.com/api/v1/people/%@/contacts?page=1&per_page=10&access_token=%@";
static NSString * updatePeopleUrl = @"https://%@.nationbuilder.com/api/v1/people/%@?access_token=%@";


@interface TGLOEditPersonFromSearchViewController ()
{
    NSString *token;
    NSMutableDictionary *tagsToDelete;
}

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
    }
    
    [self addTagViews];
}

-(void)addTagViews
{
    NSLog(@"SETTING UP ALL MY TAGS");
    
    for (NSString *tag in self.person.tags) {
        [self addASingleTag:tag];
    }
    
    //[self getAllMyContacts];
    //NSLog(@"self subviews: %@", [self.containerView subviews]);
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
    
    CGRect containerFrame = [self.containerView frame];
    CGFloat containerHeight = CGRectGetHeight(containerFrame);
    CGFloat containerWidth = CGRectGetWidth(containerFrame);
    
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
    } else if ([viewType isEqualToString:@"UIButton"]) {
        UIColor * blackColor = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:1.0f];

        //return [[UIButton alloc] initWithFrame:viewRect];
        UIButton *tempButton =[UIButton buttonWithType:UIButtonTypeSystem];
        tempButton.frame = viewRect;
        
        [tempButton setTitleColor:blackColor forState:UIControlStateNormal];
        
        NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
        NSLog(@"bundlePath: %@", bundlePath);
        NSString *imageLocation = [[NSString alloc] initWithFormat:@"%@/appIcon120x120.png", bundlePath ];
        UIImage *backgroundImage = [[UIImage alloc] initWithContentsOfFile:imageLocation];
        NSLog(@"backgroundImage: %@", backgroundImage);
        
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
    
    NSLog(@"the state of the swith is now: %d", switch_.on);
    
    //first, get the background and state of the button
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSLog(@"bundlePath: %@", bundlePath);
    
    if (!switch_.on) {
        //user wants to delete the corresponding tag
        NSLog(@"DELETE corresponding tag");
        
        NSString *imageLocation = [[NSString alloc] initWithFormat:@"%@/grey120x120.png", bundlePath ];
        UIImage *backgroundImage = [[UIImage alloc] initWithContentsOfFile:imageLocation];
        NSLog(@"backgroundImage: %@", backgroundImage);
       
        //tag the parent view to say delete it. 1 == 'delete'
        superView.tag = 123;
        
        
        [correspondingButton setBackgroundImage:backgroundImage forState:UIControlStateNormal];
        
        [tagsToDelete setObject:@"0" forKey:correspondingButton.titleLabel.text];
        
    } else {
        //user wants to keep the corresponding tag
        NSLog(@"KEEP corresponding tag");
        NSString *imageLocation = [[NSString alloc] initWithFormat:@"%@/appIcon120x120.png", bundlePath ];
        UIImage *backgroundImage = [[UIImage alloc] initWithContentsOfFile:imageLocation];
        NSLog(@"backgroundImage: %@", backgroundImage);
        
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveChanges:(id)sender {
    NSLog(@"saveChanges button hit");
    
    //1. personal fields update
    //TODO: check for nil ?
    NSString *firstName_ = self.firstName.text;
    NSString *lastName_ = self.lastName.text;
    NSString *email_ = self.email.text;
    NSString *phone_ = self.phone.text;
    NSString *mobile_ = self.mobile.text;
    
    NSNumber *supportLevelNumber = [TGLOPerson inverseFormattedSupportLevel:self.supportLevel.text];
    NSLog(@"supportLevelNumber: %@", supportLevelNumber );
    NSString *supportLevel_ = [[NSString alloc] initWithFormat:@"%@", supportLevelNumber];
    
    NSLog(@"supportLevel_: %@", supportLevel_);
    
    

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
    
    //tagsToDelete dic should only hold tags we want to keep
    //=> can use this tagsToDelete as body obj for PUT request below
    NSDictionary *updateBody =@{@"person":@{@"tags":[tagsToKeep allKeys], @"first_name":firstName_, @"last_name":lastName_, @"email1":email_, @"phone":phone_, @"mobile":mobile_, @"support_level":supportLevel_}};
    
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
        NSLog(@" PUT => updating tags with response %@",responseObject);
        
        NSLog(@"SUCCESSfully deleted tag.");
        
        //update UI
        //find the elements to delete using the 123 tag
        while (!![self.containerView viewWithTag:123]) {
            TGLOCustomEditTagView *oldTag = (TGLOCustomEditTagView *)[self.containerView viewWithTag:123];
            
            [oldTag removeFromSuperview];
            
#warning TODO: update self.person.tags also. get rid of removed tag
            
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
@end
