//
//  TGLOEventDetailsViewController.m
//  Vic Greens
//
//  Created by andre on 8/05/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import "TGLOEventDetailsViewController.h"
#import "AFNetworking.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "TGLOUtils.h"
#import "TGLOAppDelegate.h"

//default to get 1000 (max) people for a list. not making multiple
//page calls to get all people as yet.
static NSString *eventUrl= @"https://%@.nationbuilder.com/api/v1/sites/%@/pages/events/%@?access_token=%@";

static NSString *rsvpsUrl = @"https://%@.nationbuilder.com/api/v1/sites/%@/pages/events/%@/rsvps?page=1&per_page=1000&access_token=%@";

//static NSString *translateIdsToNamesUrl = @"https://cryptic-tundra-9564.herokuapp.com/namesForId/%@/%@";
static NSString *translateIdsToNamesUrl = @"http://localhost:5000/namesForId/%@/%@";



@interface TGLOEventDetailsViewController () {
    NSString *token;
    TGLOEvent *parsedEvent;
}

@end

@implementation TGLOEventDetailsViewController

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
    
    //set an initial scroll view size
    self.scrollView.contentSize =CGSizeMake(320, 550);
    
    //set the initial container view to be equal
    //to scroll view size
    self.containerView.frame = CGRectMake(0, 0, 320, 550);
    
    
    NSLog(@"eventId: %@", self.selectedEventId);
    
    //enable afnetworking to show spinner in top bar
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    token = [TGLOUtils getUserAccessToken];
    
    if (token) {
        [self getEvent];
        
    } else {
        NSLog(@"ERROR in TGLOMyTagsViewController.m. access_token is nil");
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void) getEvent
{
    NSString * eventUrl_ = [NSString stringWithFormat:eventUrl, nationBuilderSlugValue, nationBuilderSlugValue, self.selectedEventId, token];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:eventUrl_ parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"EVENT DETAILS VIEW CONTROLLER and response: %@", responseObject);
        
        NSSet *event_set = [responseObject objectForKey:@"event"];
        //NSLog(@"event_set: %@", event_set);
        
        
        parsedEvent = [TGLOEvent eventFieldsForObject:event_set];
        [self fillOutEventFields:parsedEvent];
        [self getAllRsvps];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}


- (void)fillOutEventFields:(TGLOEvent *)event
{
    self.nameTextField.text = event.name;
    self.dateTextField.text = event.dateString;
    self.venueTextField.text = [[event.venue objectForKey:@"address"] objectForKey:@"address1"];
    self.detailsTextView.text = event.details;
    
    NSString *contactName = [event.contactDetails objectForKey:@"name"];
    NSString *contactNumber = [event.contactDetails objectForKey:@"phone"];
    self.contactTextField.text = [[NSString alloc] initWithFormat:@"%@ %@", contactName, contactNumber];
    
    NSMutableString *tagsConcatenated = [[NSMutableString alloc] init];
    //only first tag for now
    if (event.tags && [event.tags count]) {
        NSLog(@"TAGS NOT EMPTY");
        [event.tags enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            NSString *addStr = [[NSString alloc] initWithFormat:@"%@, ", (NSString *)obj];
        
            [tagsConcatenated appendString:addStr];
        }];
        
        //remove trailing comma and space
        self.tagsTextField.text = [tagsConcatenated substringToIndex:([tagsConcatenated length] -2)];
       
    }
}

- (void)getAllRsvps
{
    NSString * rsvpsUrl_ = [NSString stringWithFormat:rsvpsUrl, nationBuilderSlugValue, nationBuilderSlugValue, parsedEvent.eventId, token];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:rsvpsUrl_ parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"RSVPS TO EVENT DETAILS VIEW CONTROLLER and response: %@", responseObject);
        
        NSSet *rsvpsSet = [responseObject objectForKey:@"results"];
        //NSLog(@"rsvpsSet: %@", rsvpsSet);
        
        [self addRsvpsLabel];
        [self translateRsvpIdsToNames:rsvpsSet];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void) addRsvpsLabel
{
    CGFloat labelSpacing = 10; //spacing between the views
    CGFloat makeMoreRoom = 40; //additional room scroll/containerView
    CGFloat labelWidth = 280;  //new label width
    CGFloat labelHeight= 30;   //new label height
    
    
    UILabel *newLabel = (UILabel *)[self fabricateANewView:@"UILabel" width:labelWidth height:labelHeight spacing:labelSpacing];
    
    newLabel.text = @"RSVPS";
    newLabel.font = [UIFont boldSystemFontOfSize:13];
    
    
    [self updateScrollAndContainerViewSize:makeMoreRoom];
    
    //finally add the new view to as last subview
    [self.containerView addSubview:newLabel];
}



-(void) translateRsvpIdsToNames:(NSSet *)rsvps
{
    NSLog(@"translating rsvp ids to names...");
    
    
    NSString * translateIdsToNamesUrl_ = [NSString stringWithFormat:translateIdsToNamesUrl, [TGLOUtils getUserNationBuilderId], token];
    NSMutableArray *idsArray = [[NSMutableArray alloc] init];
    
    //extract only person_ids which we want to translate
    [rsvps enumerateObjectsUsingBlock:^(id obj, BOOL *stop){
        if ([obj valueForKey:@"person_id"] != [NSNull null]) {
            [idsArray addObject:[obj valueForKey:@"person_id"]];
        }
    }];
    
    NSDictionary *postBody = @{ @"people": idsArray};
    
    //need to get notes on the person from a different api, namely
    // the contacts api
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    //must set request serializer to application/json. otherwise 406
    //is responded
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager POST:translateIdsToNamesUrl_ parameters:postBody success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"=> RSVPS ids to names translation response %@",responseObject);
        
        //remember to reset the sendInANewContact back to false
        //sendInANewContact = false;
        
        //for now just render with ids until backend is implemented
        [self addRsvpsToUI:rsvps];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}




- (void)addRsvpsToUI:(NSSet *)rsvps
{
    NSLog(@"adding in RSVPS to UI...");
    NSArray *rsvpsArray = [rsvps allObjects];
    int rsvpsCount = [rsvpsArray count];
    
    
    CGFloat labelSpacing = 10; //spacing between the views
    CGFloat makeMoreRoom = 40; //additional room on end of scroll/container view
    CGFloat labelWidth = 280;  //new label width
    CGFloat labelHeight= 30;   //new label height
    
    UIColor * purpleColor = [UIColor colorWithRed:115/255.0f green:89/255.0f blue:162/255.0f alpha:1.0f];
    
    
    //add each rsvp individually
    for (int i = 0; i < rsvpsCount; i++) {
        
        UITextField *newTextField = (UITextField *)[self fabricateANewView:@"UITextField" width:labelWidth height:labelHeight spacing:labelSpacing];
        NSString *personId= [[NSString alloc] initWithFormat:@"%@",[rsvpsArray[i] valueForKey:@"person_id"]];
    
        newTextField.borderStyle = UITextBorderStyleRoundedRect;
        newTextField.text = personId;
        newTextField.textColor = [UIColor whiteColor];
        newTextField.userInteractionEnabled = NO;
        newTextField.backgroundColor = purpleColor;
        
        
        //update the scroll and container view to fit/display new content
        [self updateScrollAndContainerViewSize:makeMoreRoom];
        
        //finally add the new view to as last subview
        [self.containerView addSubview:newTextField];
    }
    
    //NSLog(@"containerViews subviews: %@", [self.containerView subviews]);
}



// utility method for construct different types of views
- (id) fabricateANewView:(NSString *)viewType width:(CGFloat)viewWidth height:(CGFloat)viewHeight spacing: (CGFloat)viewSpacing
{
    CGRect containerFrame = [self.containerView frame];
    CGFloat containerHeight = CGRectGetHeight(containerFrame);
    CGFloat containerWidth = CGRectGetWidth(containerFrame);
    
    NSArray *containerSubviews = [self.containerView subviews];
    CGRect lastViewFrame = ((UILabel *)[containerSubviews lastObject]).frame;
    
    //get dimensions of the lower left corner of
    //last subview of containerView
    CGFloat lastViewYLocation = CGRectGetMaxY(lastViewFrame);
    CGFloat lastViewXLocation = CGRectGetMinX(lastViewFrame);
    
    //now create a new rect, taking into account
    //location of last subview
    CGRect viewRect = CGRectMake(lastViewXLocation, lastViewYLocation + viewSpacing, viewWidth, viewHeight);
    
    
    if ([viewType  isEqualToString:@"UILabel"]){
        return [[UILabel alloc] initWithFrame:viewRect];
    } else if ([viewType isEqualToString:@"UITextField"]) {
        return [[UITextField alloc] initWithFrame:viewRect];
    }  else {
        return @"ERROR";
    }
}


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



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
