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
        NSLog(@"event_set: %@", event_set);
        
        
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
    self.contactTextField.text = [event.contactDetails objectForKey:@"name"];
    
    //only first tag for now
    if (event.tags && [event.tags count]) {
        NSLog(@"TAGS NOT EMPTY");
        self.tagsTextField.text = event.tags[0];
    }
}

- (void)getAllRsvps
{
    NSString * rsvpsUrl_ = [NSString stringWithFormat:rsvpsUrl, nationBuilderSlugValue, nationBuilderSlugValue, parsedEvent.eventId, token];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:rsvpsUrl_ parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"RSVPS TO EVENT DETAILS VIEW CONTROLLER and response: %@", responseObject);
        
        NSSet *rsvpsSet = [responseObject objectForKey:@"results"];
        NSLog(@"rsvpsSet: %@", rsvpsSet);
        
        [self addRsvpsToUI:rsvpsSet];
        
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
