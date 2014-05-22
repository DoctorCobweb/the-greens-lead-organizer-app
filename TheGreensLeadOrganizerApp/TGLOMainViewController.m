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


// *** IMPORTANT ***
//view with tag = 654 is Tags label. needed when updating UI after person is updated

NSString * const meUrl= @"https://%@.nationbuilder.com/api/v1/people/%@?access_token=%@";
NSString * const myContactsUrl = @"https://%@.nationbuilder.com/api/v1/people/%@/contacts?page=1&per_page=1000&access_token=%@";
static NSString *translateIdsToNamesUrl = @"https://cryptic-tundra-9564.herokuapp.com/namesForIds/%@/%@";

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
    
    NSMutableArray *contactIds = [[NSMutableArray alloc] init];
    
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
        
        //NSMutableArray *contactsMutable = [[NSMutableArray alloc] initWithArray:contacts_];
        NSMutableArray *contactsMutable = [[NSMutableArray alloc] init];
        
        
        [contacts_ enumerateObjectsUsingBlock:^(id obj, NSUInteger i, BOOL *stop) {
            NSMutableDictionary *aMutableContact = [[NSMutableDictionary alloc] initWithDictionary:(NSDictionary *)obj];
        
            [contactsMutable addObject:aMutableContact];
            
            if (i == ([contacts_ count] - 1)) {
                
                
                contacts = [[NSMutableArray alloc] initWithArray:contactsMutable];
                //contacts = [[NSMutableArray alloc] initWithArray:contacts_];
                
                //NSLog(@"====> contacts: %@", contacts);
                
                [contacts_set enumerateObjectsUsingBlock: ^(id obj, BOOL *stop) {
                    
                    [contactIds addObject:[obj valueForKey:@"sender_id"]];
                    [contactIds addObject:[obj valueForKey:@"recipient_id"]];
                    
                }];
                
                
                NSSet *contactIdsSet = [[NSSet alloc] initWithArray:contactIds];
                NSArray *filteredContactIds = [contactIdsSet allObjects];
                
                //NSLog(@"====> contactIds: %@", contactIds);
                //NSLog(@"====> contactIdsSet: %@", contactIdsSet);
                //NSLog(@"====> filteredContactIds: %@", filteredContactIds);
                
                [self translateContactIdsToNames: (NSArray *)filteredContactIds];
            }
        }];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void) translateContactIdsToNames:(NSArray *)filteredContactIds
{
    //translate ids to names by
    //1. looking at ios app db with People Entity
    //2. POST /namesForIds/:myNBId/:access_token route to heroku backend
    
    NSString * translateIdsToNamesUrl_ = [NSString stringWithFormat:translateIdsToNamesUrl, [TGLOUtils getUserNationBuilderId], token];
    
    NSDictionary *postBody = @{ @"peopleIds": filteredContactIds};
    
    //need to get notes on the person from a different api, namely
    // the contacts api
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    //must set request serializer to application/json. otherwise 406
    //is responded
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager POST:translateIdsToNamesUrl_ parameters:postBody success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"=> CONTACT ids to names translation response %@",responseObject);
        
        NSSet *peopleSet = [responseObject objectForKey:@"translatedPeople"];
        NSArray *peopleSetArray = [peopleSet allObjects];
        NSNumber *personId = [[NSNumber alloc] init];
        NSString *personFullName = [[NSString alloc] init];
        NSNumber *senderId = [[NSNumber alloc] init];
        NSNumber *recipientId = [[NSNumber alloc] init];
        
        
        #warning TODO: prefill contacts senderFullName, recipientFullName with nils
        //fill out contacts array with blank values for keys
        //senderFullName and recipientFullName
        
        
        
        for (int j = 0; j < [peopleSetArray count]; j++) {
            personId = [peopleSetArray[j] valueForKey:@"personId"];
            personFullName = [peopleSetArray[j] valueForKey:@"fullName"];
            
            for (int k = 0; k < [contacts count]; k++) {
                senderId = [contacts[k] valueForKey:@"sender_id"];
                recipientId = [contacts[k] valueForKey:@"recipient_id"];
                
                //[contacts[k] setValue:[NSNull null] forKey:@"senderFullName"];
                //[contacts[k] setValue:[NSNull null] forKey:@"recipientFullName"];
                
                if ([senderId isEqual:personId]) {
                    //NSLog(@"senderId isEqual to personId");
                    [contacts[k] setValue:personFullName forKey:@"senderFullName"];
                    NSLog(@"%@", [contacts[k] valueForKey:@"senderFullName"]);
                }
                
                if ([recipientId isEqual:personId]) {
                    //NSLog(@"recipientId isEqual to personId");
                    [contacts[k] setValue:personFullName forKey:@"recipientFullName"];
                    NSLog(@"%@", [contacts[k] valueForKey:@"recipientFullName"]);
                }
            }
        }
        
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
    
    NSString *senderIdString = [[NSString alloc] initWithFormat:@"%@", [contacts[index] objectForKey:@"sender_id"]];
    
    NSString *recipientIdString = [[NSString alloc] initWithFormat:@"%@", [contacts[index] objectForKey:@"recipient_id"]];
    
    NSString *typeString;
    NSString *methodString;
    NSString *statusString;
    NSString *dateString;
    NSString *noteString;
    NSString *contactSentenceLabelString;
    NSString *noteLabelString;
    
    NSString *senderFullName;
    NSString *recipientFullName;
    
    
    
    
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
    
    
    
    //NSLog(@"senderFullName obj: %@",[contacts[index] objectForKey:@"senderFullName"] );
    if ([contacts[index] objectForKey:@"senderFullName"] != null) {
        NSLog(@"1");
    
        senderFullName = [contacts[index] objectForKey:@"senderFullName"];
    } else {
        NSLog(@"2");
        senderFullName = @"";
    }
    
    //NSLog(@"recipientFullName obj: %@",[contacts[index] objectForKey:@"recipientFullName"] );
    if ([contacts[index] objectForKey:@"recipientFullName"] != null) {
        NSLog(@"3");
        recipientFullName = [contacts[index] objectForKey:@"recipientFullName"];
    } else {
        NSLog(@"4");
        recipientFullName = @"";
    }
    
    
    //contactSentenceLabelString = [[NSString alloc] initWithFormat:@"%@ contacted %@ for  %@ via %@. Status is: %@.", senderIdString, recipientIdString, typeString, methodString, statusString];
    contactSentenceLabelString = [[NSString alloc] initWithFormat:@"%@ contacted %@ for  %@ via %@. Status is: %@.", senderFullName, recipientFullName, typeString, methodString, statusString];
    
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
    } else if([viewType isEqualToString:@"TGLOCustomContactSmallView"]) {
        return [[TGLOCustomContactSmallView alloc] initWithFrame:viewRect];
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
