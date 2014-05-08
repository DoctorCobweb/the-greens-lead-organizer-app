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

//agv.nationbuilder.com/api/v1/sites/agv/pages/events/328?access_token=102fe210786667df8a04708a471e549738cc4e72506c66bf44ddccf7c280794a



@interface TGLOEventDetailsViewController () {
    NSString *token;
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
    static NSString *eventUrl= @"https://%@.nationbuilder.com/api/v1/sites/%@/pages/events/%@?access_token=%@";
    
    NSString * eventUrl_ = [NSString stringWithFormat:eventUrl, nationBuilderSlugValue, nationBuilderSlugValue, self.selectedEventId, token];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager GET:eventUrl_ parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"EVENT DETAILS VIEW CONTROLLER and response: %@", responseObject);
        
        NSSet *event_set = [responseObject objectForKey:@"event"];
        NSLog(@"event_set: %@", event_set);
        
        TGLOEvent *parsedEvent = [TGLOEvent eventFieldsForObject:event_set];
        
        
        [self fillOutEventFields:parsedEvent];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}


- (void)fillOutEventFields:(TGLOEvent *)event
{
    if (event.name != nil) {
        self.nameTextField.text = event.name;
    }
    
    //no date formatting for now
    if (event.dateString != nil) {
        self.dateTextField.text = event.dateString;
    }
    
    //only address1 for now
    if (!([event.venue objectForKey:@"address"] == [NSNull null]) && !([[event.venue objectForKey:@"address"]objectForKey:@"address1"] == [NSNull null])) {
        NSLog(@"should NOT BE HERE");
        self.venueTextField.text = [[event.venue objectForKey:@"address"] objectForKey:@"address1"];
    }
    
    
    if (event.details != nil) {
        self.detailsTextView.text = event.details;
    }
    
    //only name for now
    if ([event.contactDetails objectForKey:@"name"] != nil) {
        self.contactTextField.text = [event.contactDetails objectForKey:@"name"];
    }
    
    //only first tag for now
    if (!![event.tags count]) {
        self.tagsTextField.text = event.tags[0];
    }
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
