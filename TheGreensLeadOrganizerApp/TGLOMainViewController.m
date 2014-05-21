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
#import "TGLOCustomContactSmallView.h"
#import "TGLOEditMyProfileViewController.h"
#import "TGLOUtils.h"


NSString * const meUrl= @"https://%@.nationbuilder.com/api/v1/people/%@?access_token=%@";
NSString * const myContactsUrl = @"https://%@.nationbuilder.com/api/v1/people/%@/contacts?page=1&per_page=100&access_token=%@";

@interface TGLOMainViewController ()
{
    NSString *token;
    NSInteger tagCount;
    NSInteger rowNumber;
    CGFloat finalXPos;
    CGFloat finalYPos;
}

@property (strong, nonatomic) UIAlertView *tokenAlert;

@end

@implementation TGLOMainViewController
@synthesize contacts;

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
    
    //since Lists tab hides our app wide nav bar
    //make sure it is NOT hidden before displaying
    //this view controllers' view
    [[[self navigationController] navigationBar] setHidden:NO];
    
    token = [TGLOUtils getUserAccessToken];
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
    
    UINavigationBar *navbar = [[self navigationController] navigationBar];
    
    //NSLog(@"navigation bar: %@", navbar);
    UIColor * black_color = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:1.0f];
    
    //this will set the 'back button' to be black
    navbar.tintColor = black_color;
    
    // Change button color
    self.sidebarButton.tintColor = [UIColor colorWithWhite:0.05f alpha:1.0f];
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    self.sidebarButton.target = self.revealViewController;
    self.sidebarButton.action = @selector(revealToggle:);
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
}


- (void)getMyNationBuilderDetails
{
    NSString *_myNBId = [TGLOUtils getUserNationBuilderId];
    
    NSString * meUrl_ = [NSString stringWithFormat:meUrl, nationBuilderSlugValue, _myNBId, token];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:meUrl_ parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"in MAIN VIEW CONTROLLER and response: %@", responseObject);
         
        NSDictionary * me_dic = [responseObject objectForKey:@"person"];
        
        NSLog(@"me_dic[id] SET: %@", [me_dic valueForKey:@"id"]);
        
        
        //start setting up the ui stuff
        [self setupPerson: me_dic];
        
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
     }];
}



- (void)setupPerson:(NSDictionary *)me_dic
{
    NSLog(@"Setting up the person obj, fields...");
    
    
    //TGLOPerson *me = [self personFieldsForObject:me_dic];
    self.person = [TGLOPerson personFieldsForObject:me_dic];
    
    //UIColor * white_color = [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1.0f];
    

    self.fullName.text = [[NSString alloc] initWithFormat:@"%@ %@", self.person.firstName, self.person.lastName];
    
    self.supportLevel.text = [TGLOPerson formattedSupportLevel:self.person.supportLevel];
    
    [self.email setTitle:self.person.email forState:UIControlStateNormal];
    //[self.email setTitleColor:white_color forState:UIControlStateNormal];
    
    [self.phone setTitle:self.person.phone forState:UIControlStateNormal];
    //[self.phone setTitleColor:white_color forState:UIControlStateNormal];
    
    [self.mobile setTitle:self.person.mobile forState:UIControlStateNormal];
    //[self.mobile setTitleColor:white_color forState:UIControlStateNormal];
    
    //now we can be sure that we have myNBId in
    //user defaults. onwards to getting tags and
    //contacts API calls, which rely on having
    //myNBId non-nil.
    [self addTagViews];
}


- (void)addTagViews
{
    NSLog(@"SETTING UP ALL MY TAGS");
    rowNumber = -1;
    
    //for (NSString *tag in taggings) {
    for (NSString *tag in self.person.tags) {
        [self addASingleTag:tag];
    }
    
    //reset rowNumber
    rowNumber = -1;
    
    [self getAllMyContacts];
}


- (void) addASingleTag:(NSString*)tag
{
    CGFloat labelSpacing = 5; //spacing between the views
    CGFloat makeMoreRoom = 20; //additional room on end of scroll/container view
    CGFloat labelHeight= 15;   //new label height
    
    UIColor *lightGrey = [UIColor colorWithRed:240/255.0f green:240/255.0f blue:240/255.0f alpha:1.0f];
    
    CGFloat tagWidth = (320 - (2 * 20) - (2 * 8))/3;
    
    //special fabrication method
    UILabel *newLabel = (UILabel *)[self fabricateANewTagWithWidth:tagWidth height:labelHeight spacing:labelSpacing];
    
    newLabel.text = tag;
    newLabel.font = [UIFont systemFontOfSize:12];
    newLabel.backgroundColor = lightGrey;
    newLabel.textColor = [UIColor blackColor];

    //update the scroll and container view to fit/display new content
    [self updateScrollAndContainerViewSize:makeMoreRoom];
    
    //finally add the new view to as last subview
    [self.containerView addSubview:newLabel];
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
    NSString *myNBId = [TGLOUtils getUserNationBuilderId];
    NSString * myContactsUrl_ = [NSString stringWithFormat:myContactsUrl, nationBuilderSlugValue, myNBId , token];

    
    //need to get notes on the person from a different api, namely
    // the contacts api
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    
    [manager GET:myContactsUrl_ parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@" got contacts in MAIN DETAIL VIEW CONTROLLER and CONTACTS response: %@", responseObject);
        
        NSSet * contacts_set = [responseObject objectForKey:@"results"];
        //make latest contact appear first in contacts array
        NSArray *contacts_ = [self reverseArray:[contacts_set allObjects]];
        
        contacts = [[NSMutableArray alloc] initWithArray:contacts_];
        [self addContactViews];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}


- (NSArray *)reverseArray:(NSArray *)array
{
    int no_of_contacts = [array count];
    NSMutableArray *reversed_contacts_ = [[NSMutableArray alloc] initWithCapacity:no_of_contacts];
    for (int i = no_of_contacts - 1; i >= 0; i--) {
        [reversed_contacts_ addObject:array[i]];
    }
        
    return [[NSArray alloc] initWithArray:reversed_contacts_];
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
    CGFloat labelSpacing = 15; //spacing between the views
    CGFloat labelWidth = 280;  //new label width
    
    //CGFloat makeMoreRoom = 250; //additional room on end of scroll/container view
    //CGFloat labelHeight= 300;   //new label height
    
    NSString *senderIdString = [[NSString alloc] initWithFormat:@"%@", [contacts[index] objectForKey:@"sender_id"]];
    
    NSString *recipientIdString = [[NSString alloc] initWithFormat:@"%@", [contacts[index] objectForKey:@"recipient_id"]];
    
    NSString *typeString;
    NSString *methodString;
    NSString *statusString;
    NSString *dateString;
    NSString *noteString;
    NSString *contactSentenceLabelString;
    NSString *noteLabelString;
    
    
    
    
    //make sure we dont try to assign null to
    //text property of a view
    //using view.tag to find respective views of
    //TGLOCustomContactView
    NSNull *null = [NSNull null];
    
    NSNumber *typeValue = [contacts[index] objectForKey:@"type_id"];
    //NSLog(@"typeValue: %@", typeValue);
    if ([contacts[index] objectForKey:@"type_id"] != null) {
        
        //((UILabel *)[customView viewWithTag:1]).text = [customView getFormattedTypeValue:[typeValue stringValue]];
        
        typeString = [TGLOCustomContactSmallView getFormattedTypeValue:[typeValue stringValue]];
    }
    
    NSString *methodValue = [contacts[index] objectForKey:@"method"];
    if ([contacts[index] objectForKey:@"method"] != null) {
        
        methodString = [TGLOCustomContactSmallView getFormattedMethodValue:methodValue];
    }
    
    NSString *statusValue = [contacts[index] objectForKey:@"status"];
    if ([contacts[index] objectForKey:@"status"] != null) {
        
        statusString = [TGLOCustomContactSmallView getFormattedStatusesValue:statusValue];
    }
    
    if ([contacts[index] objectForKey:@"note"] != null) {
        
        noteString =[contacts[index] objectForKey:@"note"];
    }
    
    NSString *dateValue = [contacts[index] objectForKey:@"created_at"];
    if ([contacts[index] objectForKey:@""] != null) {
        
        dateString = [TGLOUtils formattedDateStringFromDate:[TGLOUtils formattedDateFromString:dateValue]];
        
    }
    
    
    contactSentenceLabelString = [[NSString alloc] initWithFormat:@"%@ contacted %@ for  %@ via %@. Status is: %@.", senderIdString, recipientIdString, typeString, methodString, statusString];
    noteLabelString = noteString;
    
    
    
    
    NSAttributedString *noteAttributedString = [[NSAttributedString alloc] initWithString:noteLabelString];
    
    NSAttributedString *dateAttributedString = [[NSAttributedString alloc] initWithString:dateString];
    
    NSAttributedString *contactSentenceAttributedString = [[NSAttributedString alloc] initWithString:contactSentenceLabelString];
    
    CGRect noteParagraphRect = [noteAttributedString boundingRectWithSize:CGSizeMake(200.f, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) context:nil];
    
    
    CGRect dateParagraphRect = [dateAttributedString boundingRectWithSize:CGSizeMake(200.f, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) context:nil];
    
    CGRect contactSentenceParagraphRect = [contactSentenceAttributedString boundingRectWithSize:CGSizeMake(200.f, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) context:nil];
    
    
    CGFloat customHeight = ceil(contactSentenceParagraphRect.size.height + 30 + noteParagraphRect.size.height + dateParagraphRect.size.height + 30);
    
    
    TGLOCustomContactSmallView *customView = (TGLOCustomContactSmallView*)[self fabricateANewView:@"TGLOCustomContactSmallView" width:labelWidth height:customHeight spacing:labelSpacing];
    
    customView.clipsToBounds = YES;
    customView.opaque = NO;
    
    
    UILabel *contactSentenceLabel = (UILabel *)[customView viewWithTag:1];
    UILabel *dateLabel = (UILabel *)[customView viewWithTag:2];
    UILabel *noteLabel = (UILabel *)[customView viewWithTag:3];
    
    contactSentenceLabel.frame =  CGRectMake(0, 0, 280, contactSentenceParagraphRect.size.height + 20);
    
    dateLabel.frame = CGRectMake(0, contactSentenceParagraphRect.size.height + 20, 280, dateParagraphRect.size.height + 5);
    
    noteLabel.frame = CGRectMake(0, dateParagraphRect.size.height + contactSentenceParagraphRect.size.height + 25, 280, noteParagraphRect.size.height + 35);
    
    
    
    contactSentenceLabel.attributedText = contactSentenceAttributedString;
    dateLabel.attributedText = dateAttributedString;
    noteLabel.attributedText = noteAttributedString;
    
    
    [self updateScrollAndContainerViewSize:customHeight + 10];
    
    //finally add the new custom contact view
    [self.containerView addSubview:customView];
}



// utility method for construct different types of views
- (UILabel *) fabricateANewTagWithWidth:(CGFloat)viewWidth height:(CGFloat)viewHeight spacing: (CGFloat)viewSpacing
{
    NSInteger mod = tagCount % 3;
    tagCount++;
    //NSLog(@"mod: %d", mod);
    
    if (mod == 0) {
        //NSLog(@"mod == 0");
        rowNumber++;
        finalXPos = 20;
        
        NSArray *containerSubviews = [self.containerView subviews];
        CGRect lastViewFrame = ((UILabel *)[containerSubviews lastObject]).frame;
        finalYPos = CGRectGetMaxY(lastViewFrame) + 5;
        
    } else {
        //NSLog(@"mod != 0");
        finalXPos = 20 + (mod * (viewWidth + 5));
    }
    
    
    //now create a new rect, taking into account
    //location of last subview
    CGRect viewRect = CGRectMake(finalXPos + 5, finalYPos, viewWidth, viewHeight);
    
    //NSLog(@"(finalXPos, finalYPos) = (%f, %f)", finalXPos, finalYPos);
    //NSLog(@"viewRect: %@", NSStringFromCGRect(viewRect));
    
    
    return [[UILabel alloc] initWithFrame:viewRect];
}



// utility method for construct different types of views
- (id) fabricateANewView:(NSString *)viewType width:(CGFloat)viewWidth height:(CGFloat)viewHeight spacing: (CGFloat)viewSpacing
{
    
    NSArray *containerSubviews = [self.containerView subviews];
    CGRect lastViewFrame = ((UILabel *)[containerSubviews lastObject]).frame;
    
    //get dimensions of the lower left corner of
    //last subview of containerView
    CGFloat lastViewYLocation = CGRectGetMaxY(lastViewFrame);
    CGFloat lastViewXLocation ;
    
    if (rowNumber == -1) {
        lastViewXLocation = 20;
    } else {
        lastViewXLocation = CGRectGetMinX(lastViewFrame);
    }
    
    
    //now create a new rect, taking into account
    //location of last subview
    CGRect viewRect = CGRectMake(lastViewXLocation, lastViewYLocation + viewSpacing, viewWidth, viewHeight);
    
    
    if ([viewType  isEqualToString:@"UILabel"]){
        return [[UILabel alloc] initWithFrame:viewRect];
    } else if ([viewType isEqualToString:@"UITextField"]) {
        return [[UITextField alloc] initWithFrame:viewRect];
    } else if ([viewType isEqualToString:@"TGLOCustomContactView"]) {
        return [[TGLOCustomContactView alloc] initWithFrame:viewRect];
    } else if([viewType isEqualToString:@"TGLOCustomContactSmallView"]) {
        
        
        return [[TGLOCustomContactSmallView alloc] initWithFrame:viewRect];
        //return [[TGLOCustomContactSmallView alloc] init];
    } else {
        return @"ERROR";
    }
}




//adding in more room to the scroll and container view to fit in newly added content
- (void)updateScrollAndContainerViewSize:(CGFloat)makeMoreRoom
{
    //update the scroll height to accomodate for
    //new added view
    CGSize contentSize = self.scrollView.contentSize;
    CGFloat scrollHeight = contentSize.height;
    
    self.scrollView.contentSize =CGSizeMake(320, scrollHeight + makeMoreRoom);
    
    //must also update the containerView height
    CGRect containerViewFrame = self.containerView.frame;
    
    self.containerView.frame = CGRectMake(0, 0, (CGRectGetMaxX(containerViewFrame)), (CGRectGetMaxY(containerViewFrame)) + makeMoreRoom);
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showEditMyProfile"]) {
        
        TGLOEditMyProfileViewController *destViewController = (TGLOEditMyProfileViewController *) segue.destinationViewController;
        destViewController.person = self.person;
        destViewController.contacts= self.contacts;
        
        //set self as delegate for <TGLOUpdatePersonDelegate> protocol
        destViewController.delegate = self;
    }
    
}

-(void) didUpdatePerson:(TGLOPerson *)updatedPerson
{
    NSLog(@"...didUpdatePerson called!!!");
    NSLog(@"updated person is: %@", updatedPerson);
    NSLog(@"updated person.lastName is: %@", updatedPerson.lastName);
    NSLog(@"updated person.supportLevel: %@", updatedPerson.supportLevel);
    
    //**update person**
    //set person to be the newly saved/updated person
    self.person = updatedPerson;
    
    //rerender all the ui now
    //1. get rid of all subviews
    self.view = nil;
    
    //2. populate the ui
    //[self viewDidLoad];
    
}

/*
- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"viewWillDisappear");
    //get reference to previous view controller from the nav stack
    //NAVIGATION STUFF
    //view controller stuff. get the navigation stack. get the
    //previous view controller etc
    
    NSLog(@"self.parentViewController: %@",self.parentViewController);
    UINavigationController *navController = (UINavigationController *)self.parentViewController;
    NSArray *viewControllers = [navController viewControllers];
    NSLog(@"viewControllers: %@", viewControllers);
    
    // output array
    //["<TGLOSearchViewController: 0x8e0a770>",
    //"<TGLOSearchResultsViewController: 0x8c62580>"]
    TGLOSearchResultsViewController *lastViewController = [viewControllers lastObject];
    NSLog(@"lastViewController class: %@", [lastViewController class]);
    
    //check to see if we are going back instead of drilling down
    //further into the app.
    //if we are drilling down further i.e. selecting to edit the
    //person then the last view controller will be
    //TGLOEditPersonFromSearchViewController instead of
    //TGLOSearchResultsViewController
    if ([lastViewController class] == [TGLOSearchResultsViewController class]) {
        NSLog(@"we have a match for TGLOSearchResultsViewController");
        
        [lastViewController.searchResults replaceObjectAtIndex:lastViewController.lastPersonSelected withObject:self.person];
        
        //tell the table to reload its data
        [lastViewController.tableView reloadData];
        
    }
}
 */

@end
