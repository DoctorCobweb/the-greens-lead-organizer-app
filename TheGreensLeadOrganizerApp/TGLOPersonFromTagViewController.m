//
//  TGLOPersonFromTagViewController.m
//  TheGreensLeadOrganizerApp
//
//  Created by andre on 16/04/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//
#import "TGLOPersonFromTagViewController.h"
#import "TGLOAppDelegate.h"
#import "TGLOCustomContactSmallView.h"
#import "AFNetworking.h"
#import "TGLOTagViewController.h"
#import "TGLOEditPersonFromTagViewController.h"
#import "TGLOUtils.h"


// *** IMPORTANT ***
//view with tag = 654 is Tags label. needed when updating UI after person is updated

#warning TODO: handle proper pagination!!!! set to 1000 results. eeek.
static NSString * myContactsUrl = @"https://%@.nationbuilder.com/api/v1/people/%@/contacts?page=1&per_page=1000&access_token=%@";



@interface TGLOPersonFromTagViewController ()
{
    NSString *token;
    NSInteger tagCount;
    NSInteger rowNumber;
    CGFloat finalXPos;
    CGFloat finalYPos;
}

@property (strong, nonatomic) UIAlertView *tokenAlert;

@end


@implementation TGLOPersonFromTagViewController
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
    
    token = [TGLOUtils getUserAccessToken];
    [self setUpAppearance];
}


- (void)setUpAppearance
{
    self.title = @"Person";
    
    
    //NSLog(@"[self navigationItem]: %@", [self navigationItem]);
    //NSLog(@"[self navigationItem] rightBarButton]: %@", [[self navigationItem] rightBarButtonItem]);
    //NSLog(@"permissionlevel: %@", [TGLOUtils getUserPermissionLevel]);
    
    //NSLog(@"admin: %d", [TGLOUtils isAdminPermissionLevel]);
    //NSLog(@"volunteer: %d", [TGLOUtils isVolunteerPermissionLevel]);
    if ([TGLOUtils isAdminPermissionLevel]) {
        [([[self navigationItem] rightBarButtonItem]) setEnabled:YES];
        ([[self navigationItem] rightBarButtonItem]).title = @"Edit";
    }
    
    if ([TGLOUtils isVolunteerPermissionLevel]) {
        [([[self navigationItem] rightBarButtonItem]) setEnabled:NO];
        ([[self navigationItem] rightBarButtonItem]).title = @"";
    }
    
    //UIColor * white_color = [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1.0f];
    
    
    //set an initial scroll view size
    self.scrollView.contentSize =CGSizeMake(320, 550);
    
    //set the initial container view to be equal
    //to scroll view size
    self.containerView.frame = CGRectMake(0, 0, 320, 550);
    
    if(self.person){
        //get the person object passed through from segue
        //self.firstName.text = self.person.firstName;
        //self.lastName.text = self.person.lastName;
        self.fullName.text = [[NSString alloc] initWithFormat:@"%@ %@", self.person.firstName, self.person.lastName];
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
    rowNumber = -1;
    
    for (NSString *tag in self.person.tags) {
        [self addASingleTag:tag];
    }
    
    rowNumber = -1;
    
    [self getAllMyContacts];
    
    
}


- (void)addASingleTag:(NSString *)tag
{
    CGFloat labelSpacing = 10; //spacing between the views
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
    NSLog(@"in getAllMyContacts");
    
    //this method is always called after all
    //the tags have rendered. therefore, before
    //going off to call the contacts api, create
    //the contact label and add it to ui
    [self addContactsLabel];
    
    
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
            
            //make latest contact appear first in contacts array
            NSArray *contacts_ = [self reverseArray:[contacts_set allObjects]];
            contacts = [[NSMutableArray alloc] initWithArray:contacts_];
            [self addContactViews];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
    } else {
        NSLog(@"ERROR in TGLOPersonViewController.m. access_token is nil OR person.recordID is nil");
    }
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
    NSNull *null = [NSNull null];
    
    NSNumber *typeValue = [contacts[index] objectForKey:@"type_id"];
    if ([contacts[index] objectForKey:@"type_id"] != null) {
        
        
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
    
    CGFloat padding = 15;
    CGFloat contactWidth = 280;
    
    contactSentenceLabel.frame =
    CGRectMake(0,
               0,
               contactWidth,
               contactSentenceParagraphRect.size.height + padding);
    
    dateLabel.frame =
    CGRectMake(0,
               contactSentenceParagraphRect.size.height + padding,
               contactWidth,
               dateParagraphRect.size.height + (padding/2));
    
    noteLabel.frame =
    CGRectMake(0,
               dateParagraphRect.size.height + contactSentenceParagraphRect.size.height + (1.5 * padding),
               contactWidth,
               noteParagraphRect.size.height + 35);
    
    
    
    
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
    } else if ([viewType isEqualToString:@"TGLOCustomContactSmallView"]) {
        return [[TGLOCustomContactSmallView alloc] initWithFrame:viewRect];
    } else {
        return @"ERROR";
    }
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







-(void)makeCall:(id)sender
{
    
    NSLog(@"makeCall method called, sender is: %@", sender);
    NSString *title = [((UIButton *) sender) currentTitle];
    //NSLog(@"currentTitle: %@", title);
    
    NSArray *title_split =  [title componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" -+()"]];
    
    NSString *title_cleaned= [title_split componentsJoinedByString:@""];
    //NSLog(@"title_split: %@", title_split);
    //NSLog(@"title_joined: %@", title_cleaned);
    
    NSString *theCall = [NSString stringWithFormat:@"telprompt://%@", title_cleaned];
    //NSLog(@"theCall: %@", theCall);
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
    //NSLog(@"currentTitle: %@", title);
    
    NSString *theEmail = [NSString stringWithFormat:@"mailTo://%@", title];
    //NSLog(@"theEmail: %@", theEmail);
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

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showEditPersonFromTag"]) {
        
        TGLOEditPersonFromTagViewController *destViewController = (TGLOEditPersonFromTagViewController *) segue.destinationViewController;
        destViewController.person = self.person;
        destViewController.contacts= self.contacts;
        
        //set self as delegate for <TGLOUpdatePersonDelegate> protocol
        destViewController.delegate = self;
    }
    
}

-(void) didUpdatePerson:(TGLOPerson *)updatedPerson
{
    NSLog(@"...didUpdatePerson called!!!");
    //NSLog(@"updated person is: %@", updatedPerson);
    //NSLog(@"updated person.lastName is: %@", updatedPerson.lastName);
    //NSLog(@"updated person.supportLevel: %@", updatedPerson.supportLevel);
    
    //**update person**
    //set person to be the newly saved/updated person
    self.person = updatedPerson;
    
    //reset the parameters used for adding tags at proper locations
    finalXPos = 20;
    
    //find the bottom of the Tags label
    finalYPos = CGRectGetMaxY(((UILabel *)[self.containerView viewWithTag:654]).frame);
    tagCount = 0;
    
    #warning TODO: find better way to update UI instead of completely nil ing the view
    //rerender all the ui now
    //1. get rid of all subviews
    self.view = nil;
    
}

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
    
    TGLOTagViewController *lastViewController = [viewControllers lastObject];
    NSLog(@"lastViewController class: %@", [lastViewController class]);
    
    //check to see if we are going back instead of drilling down
    //further into the app.
    //if we are drilling down further i.e. selecting to edit the
    //person then the last view controller will be
    //TGLOEditPersonFromSearchViewController instead of
    //TGLOSearchResultsViewController
    if ([lastViewController class] == [TGLOTagViewController class]) {
        NSLog(@"we have a match for TGLOTagViewController");
        
        [lastViewController.searchResults replaceObjectAtIndex:lastViewController.lastPersonSelected withObject:self.person];
        
        //tell the table to reload its data
        [lastViewController.tableView reloadData];
        
    }
}


@end