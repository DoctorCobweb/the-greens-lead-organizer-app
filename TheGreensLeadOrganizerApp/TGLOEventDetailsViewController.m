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
#import "TGLOCustomRsvpView.h"
#import "TGLOEventDetailsModalPersonViewController.h"

//default to get 1000 (max) people for a list. not making multiple
//page calls to get all people as yet.
static NSString *eventUrl= @"https://%@.nationbuilder.com/api/v1/sites/%@/pages/events/%@?access_token=%@";
static NSString *rsvpsUrl = @"https://%@.nationbuilder.com/api/v1/sites/%@/pages/events/%@/rsvps?page=1&per_page=1000&access_token=%@";
static NSString * putRsvpUrl = @"https://%@.nationbuilder.com/api/v1/sites/%@/pages/events/%@/rsvps/%@?access_token=%@";
static NSString *translateIdsToNamesUrl = @"https://cryptic-tundra-9564.herokuapp.com/namesForIds/%@/%@";



@interface TGLOEventDetailsViewController () {
    NSString *token;
    TGLOEvent *parsedEvent;
    NSMutableArray *joinedRsvps;
    NSMutableDictionary *aRsvpToUpdate;
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
    
    joinedRsvps = [[NSMutableArray alloc] init];
    aRsvpToUpdate = [[NSMutableDictionary alloc] init];
    
    
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
        [self addRsvpsLabel];
        [self getAllRsvps];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}


- (void)fillOutEventFields:(TGLOEvent *)event
{
    NSString *address1 = [[event.venue objectForKey:@"address"] objectForKey:@"address1"];
    NSString *city = [[event.venue objectForKey:@"address"] objectForKey:@"city"];
    UIColor *lightOrange = [UIColor colorWithRed:0.918 green:0.472 blue:0.247 alpha:1.000];
    
    self.nameLabel.text = event.name;
    self.nameLabel.backgroundColor = lightOrange;
    
    
    NSLog(@"event.dateString: %@", event.dateString);
    NSDate *startDate = [TGLOUtils formattedDateFromString:event.dateString];
    self.dateLabel.text = [TGLOUtils formattedDateStringFromDate:startDate];
    
    self.venue.text = [[NSString alloc] initWithFormat:@"%@, %@",address1, city];
    self.detailsTextView.text = event.details;
    
    NSString *contactName = [event.contactDetails objectForKey:@"name"];
    NSString *contactNumber = [event.contactDetails objectForKey:@"phone"];
    self.contactLabel.text = [[NSString alloc] initWithFormat:@"%@ %@", contactName, contactNumber];
    
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
    
    #warning TODO: better newLable.text string literal
    newLabel.text = @"RSVPS                                              Attended";
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
    
    NSDictionary *postBody = @{ @"peopleIds": idsArray};
    
    //need to get notes on the person from a different api, namely
    // the contacts api
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager POST:translateIdsToNamesUrl_ parameters:postBody success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"=> RSVPS ids to names translation response %@",responseObject);
        
        NSSet *translatedPeopleSet = [responseObject objectForKey:@"translatedPeople"];
        
        //need to add in person names to rsvp set matched by person_id
        [rsvps enumerateObjectsUsingBlock:^(id outerObj, BOOL *stop) {
            
            NSNumber *personIdFromRsvpNum = [outerObj valueForKey:@"person_id" ];
            NSString *personIdFromRsvp = [[NSString alloc] initWithFormat:@"%@", personIdFromRsvpNum ];
        
            
            [translatedPeopleSet enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
                
                NSNumber *personIdFromTranslationNum = [obj valueForKey:@"personId"];
                NSString *personIdFromTranslation = [[NSString alloc] initWithFormat:@"%@",personIdFromTranslationNum];
                
                
                if ([personIdFromRsvp isEqualToString:personIdFromTranslation]) {
                    //NSLog(@"found match to personIds");
                    
                    //add first, last names to that specific rsvp
                    NSString *fullName = [obj valueForKey:@"fullName"];
                    NSMutableDictionary *singleJoinedRsvp = [[NSMutableDictionary alloc] initWithDictionary:outerObj];
                    //NSLog(@"singleJoinedRsvp: %@", singleJoinedRsvp);
                    [singleJoinedRsvp setObject:fullName forKey:@"fullName"];
                
                    [joinedRsvps addObject:singleJoinedRsvp];
                }
            }];
        }];
        
        NSLog(@"joinedRsvps: %@", joinedRsvps);
        
        [self addRsvpsToUI];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}




- (void)addRsvpsToUI
{
    NSLog(@"adding in RSVPS to UI...");
    
    int rsvpsCount = [joinedRsvps count];
    CGFloat labelSpacing = 15; //spacing between the views
    CGFloat makeMoreRoom = 50; //additional room on end of scroll/container view
    CGFloat labelWidth = 280;  //new label width
    CGFloat labelHeight= 30;   //new label height
    
    //add each rsvp individually
    for (int i = 0; i < rsvpsCount; i++) {
        NSString *fullName = [joinedRsvps[i] objectForKey:@"fullName"];
        NSNumber *guestsCount= [joinedRsvps[i] objectForKey:@"guests_count"];
        NSString *canceled = [[NSString alloc] init];
        NSString *rsvpButtonTitle;
        NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
        NSString *imageLocation;
        UIImage *backgroundImage;
        
        TGLOCustomRsvpView *newRsvpView = (TGLOCustomRsvpView *)[self fabricateANewView:@"TGLOCustomRsvpView" width:labelWidth height:labelHeight spacing:labelSpacing];
        
        newRsvpView.personId = [joinedRsvps[i] objectForKey:@"person_id"];
        newRsvpView.fullName = [joinedRsvps[i] objectForKey:@"fullName"];
        
        [newRsvpView.attendedButton addTarget:self action:@selector(attendedButtonHit:) forControlEvents:UIControlEventTouchUpInside];
        
        [newRsvpView.rsvpButton addTarget:self action:@selector(rsvpButtonHit:) forControlEvents:UIControlEventTouchUpInside];
        
        
        
        //check if canceled
        if ([[joinedRsvps[i] objectForKey:@"canceled"] isEqual:@1]) {
            canceled = @"CANCELED";
            //[newRsvpView.rsvpButton setBackgroundColor:[UIColor darkGrayColor]];
            
            //cant have a checker mark sayin they attended if they cancelled.
            imageLocation = [[NSString alloc] initWithFormat:@"%@/grey120x120.png", bundlePath ];
            backgroundImage = [[UIImage alloc] initWithContentsOfFile:imageLocation];
            //[newRsvpView.attendedImageView setImage:backgroundImage];
            
            [newRsvpView.attendedButton setBackgroundImage:backgroundImage forState:UIControlStateNormal];
            
        } else {
            canceled = @"";
            //must also check for attended
            if ([[joinedRsvps[i] objectForKey:@"attended"] isEqual:@1]) {
                //person has attended
                imageLocation = [[NSString alloc] initWithFormat:@"%@/checkerMark60x60.png", bundlePath ];
                backgroundImage = [[UIImage alloc] initWithContentsOfFile:imageLocation];
                //[newRsvpView.attendedImageView setImage:backgroundImage];
                
                [newRsvpView.attendedButton setBackgroundImage:backgroundImage forState:UIControlStateNormal];
            }
        }
        
        
        //check guests_count
        if ([guestsCount isEqual:@0]) {
            rsvpButtonTitle = [[NSString alloc] initWithFormat:@"%@ %@", fullName, canceled];
        } else {
            rsvpButtonTitle = [[NSString alloc] initWithFormat:@"%@ + %@ %@", fullName, guestsCount, canceled];
        }
        
        
        [newRsvpView.rsvpButton setTitle:rsvpButtonTitle forState:UIControlStateNormal];
        [self updateScrollAndContainerViewSize:makeMoreRoom];
        [self.containerView addSubview:newRsvpView];
    }
    
}


- (void)rsvpButtonHit:(id)sender
{
    TGLOCustomRsvpView *theCustomView = (TGLOCustomRsvpView *)[sender superview];
    NSLog(@"rsvpButtonHit, fullName: %@", theCustomView.fullName);
    NSLog(@"rsvpButtonHit, fullName: %@", theCustomView.personId);
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    TGLOEventDetailsModalPersonViewController *personVC = [storyboard instantiateViewControllerWithIdentifier:@"eventDetailsModalPersonVC"];
    
    personVC.delegate = self;
    personVC.modalPresentationStyle = UIModalPresentationFullScreen;
    personVC.personId = theCustomView.personId;
    
    UINavigationController *navigationController =
    [[UINavigationController alloc]
     initWithRootViewController:personVC];
    [navigationController navigationBar].topItem.title = @"Rsvp Person";
    
    //finally, present the events model VC
    [self presentViewController:navigationController animated:YES completion: nil];
}


- (void)attendedButtonHit:(id)sender
{
    NSLog(@"attendedButtonHit, sender => %@", sender);
    
    NSNumber *personId = ((TGLOCustomRsvpView *)[sender superview]).personId;
    
    //find specific joined person record using personId
    [joinedRsvps enumerateObjectsUsingBlock:^(id obj, NSUInteger i, BOOL *stop) {
        NSNumber *runningPersonId = [obj valueForKey:@"person_id"];
        
        if ([runningPersonId isEqual:personId]) {
            NSLog(@"hit person, matched personId record: %@", joinedRsvps[i]);
            
            
            //we need to keep a ref to the hit rsvp button because later we will need to
            //update the button title to reflect rsvp state change
            [aRsvpToUpdate setObject:(UIButton *)sender forKey:@"hitRsvp"];
            
            [self updateRsvpDetails:joinedRsvps[i]];
            *stop = YES;
            
        }
    }];
}


- (void)updateRsvpDetails:(NSDictionary *)matchedJoinedRsvp
{
    
  
    [aRsvpToUpdate setObject:[[NSMutableDictionary alloc] init] forKey:@"rsvpDetails"];
    
    //partially fill in the aRsvpToUpdate
    [[aRsvpToUpdate objectForKey:@"rsvpDetails" ] setObject:[matchedJoinedRsvp valueForKey:@"id"] forKey:@"id"];
    [[aRsvpToUpdate objectForKey:@"rsvpDetails" ]setObject:[matchedJoinedRsvp valueForKey:@"event_id"] forKey:@"event_id"];
    [[aRsvpToUpdate objectForKey:@"rsvpDetails" ]setObject:[matchedJoinedRsvp valueForKey:@"person_id"] forKey:@"person_id"];
    [[aRsvpToUpdate objectForKey:@"rsvpDetails" ]setObject:[matchedJoinedRsvp valueForKey:@"guests_count"] forKey:@"guests_count"];
    [[aRsvpToUpdate objectForKey:@"rsvpDetails" ]setObject:[matchedJoinedRsvp valueForKey:@"private"] forKey:@"private"];
    [[aRsvpToUpdate objectForKey:@"rsvpDetails" ]setObject:[matchedJoinedRsvp valueForKey:@"volunteer"] forKey:@"volunteer"];
    [[aRsvpToUpdate objectForKey:@"rsvpDetails" ]setObject:[matchedJoinedRsvp valueForKey:@"canceled"] forKey:@"canceled"];
    [[aRsvpToUpdate objectForKey:@"rsvpDetails" ]setObject:[matchedJoinedRsvp valueForKey:@"shift_ids"] forKey:@"shift_ids"];
    
    NSLog(@"aRsvpToUpdate PARTOAL FILL: %@", aRsvpToUpdate);
    
    
    UIActionSheet *updateRsvpActionSheet =
    [[UIActionSheet alloc]
     initWithTitle:@"Did the person attend?"
     delegate:self
     cancelButtonTitle:@"Cancel"
     destructiveButtonTitle:nil
     otherButtonTitles:@"YES", @"NO", nil];
    
    [updateRsvpActionSheet showInView:self.view];
}



#pragma UIActionSheetDelegate methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if ([actionSheet.title isEqualToString:@"Did the person attend?"]) {
        if (buttonIndex == [actionSheet cancelButtonIndex]) {
            // User pressed cancel -- abort
            NSLog(@"user cancelled guest selection");
            
            //just dismiss actionsheet
            return;
        }
        
        if (buttonIndex == 0) {
            NSLog(@"YES button hit");
            
            [[aRsvpToUpdate objectForKey:@"rsvpDetails"] setObject:@"true" forKey:@"attended"];
            
            //if they attended then they didnt cancel did they.
            [[aRsvpToUpdate objectForKey:@"rsvpDetails"] setObject:@"false" forKey:@"canceled"];
            
            [self updateTheRsvpOnNationBuilder];
            return;
        }
        
        if (buttonIndex == 1) {
            NSLog(@"NO button hit");
            //just leave canceled value as it is
            
            [[aRsvpToUpdate objectForKey:@"rsvpDetails"] setObject:@"false" forKey:@"attended"];
            [self updateTheRsvpOnNationBuilder];
            return;
        }
        
        return;
    }
}


- (void)updateTheRsvpOnNationBuilder
{
    NSLog(@"THE RSVP TO UPDATE: aRsvpToUpdate: %@", aRsvpToUpdate);

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Updating rsvp" message:@"Syncing the rsvp with Nation Builder" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    [alert show];
    
    
    
    NSDictionary *rsvpBody = [[NSDictionary alloc] init];
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    NSMutableDictionary *theRsvpDetails = [aRsvpToUpdate objectForKey:@"rsvpDetails"];
    NSString *eventId = [[NSString alloc] initWithFormat:@"%@", [theRsvpDetails objectForKey:@"event_id"]];
    NSString *rsvpId = [[NSString alloc] initWithFormat:@"%@", [theRsvpDetails objectForKey:@"id"]];
    NSLog(@"eventId: %@", eventId);
    NSLog(@"rsvpId: %@", rsvpId);
    
    //post endpoint for updating rsvp for person
    NSString *putRsvpUrl_ = [NSString stringWithFormat:putRsvpUrl, nationBuilderSlugValue, nationBuilderSlugValue, eventId, rsvpId, token];
    
    /*
    //structure:
    rsvpBody =
    @{ @"rsvp": @{
               @"person_id":    [rsvpToUpdate valueForKey:@"person_id"],
               @"guests_count": [rsvpToUpdate valueForKey:@"guests_count"],
               @"private":      @"false",
               @"volunteer":    @"false",
               @"canceled":     [rsvpToUpdate valueForKey:@"canceled"],
               @"attended":     [rsvpToUpdate valueForKey:@"attended"],
               @"shift_ids":    @[]
               }};
     */
    
    
    
    
    rsvpBody = @{ @"rsvp": [aRsvpToUpdate objectForKey:@"rsvpDetails"]};
    
    NSLog(@"PUT rsvpBody: %@", rsvpBody);
    
    [manager PUT:putRsvpUrl_ parameters:rsvpBody success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@" PUT => updating RSVP with response %@",responseObject);
        NSLog(@"SUCCESSfully updated RSVP.");
        
        [alert dismissWithClickedButtonIndex:0 animated:NO];
        
        UIButton *hitButton = (UIButton *)[aRsvpToUpdate objectForKey:@"hitRsvp"];
        NSNumber *attended = [[responseObject objectForKey:@"rsvp"] valueForKey:@"attended"];
        NSNumber *canceled = [[responseObject objectForKey:@"rsvp"] valueForKey:@"canceled"];
        NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
        NSString *imageLocation;
        UIImage *backgroundImage;
        
        
        //NSLog(@"joinedRsvps BEFORE: %@", joinedRsvps);
        
        //gotta also update the rsvp in joinedRsvps
        for (int i = 0; i < [joinedRsvps count]; i++) {
            
            if ([[[responseObject valueForKey:@"rsvp"] valueForKey:@"id"] isEqual:[joinedRsvps[i] valueForKey:@"id"]]) {
                
                [joinedRsvps[i] setObject:[[responseObject valueForKey:@"rsvp"] valueForKey:@"canceled"] forKey:@"canceled"];
                [joinedRsvps[i] setObject:[[responseObject valueForKey:@"rsvp"] valueForKey:@"attended"] forKey:@"attended"];
            }
        }
        
        //NSLog(@"joinedRsvps AFTER: %@", joinedRsvps);
        
        if ([attended isEqual:@1]) {
            NSLog(@"person DID attended");
            
            imageLocation = [[NSString alloc] initWithFormat:@"%@/checkerMark60x60.png", bundlePath ];
            backgroundImage = [[UIImage alloc] initWithContentsOfFile:imageLocation];
            
            
            //also reset button title to fullName and also set background color to purple (default)
            TGLOCustomRsvpView *hitCustomRsvpView = (TGLOCustomRsvpView *)[hitButton superview];
            
            [hitCustomRsvpView.rsvpButton setTitle:hitCustomRsvpView.fullName forState:UIControlStateNormal];
            //[hitButton setTitle:((TGLOCustomRsvpView *)[hitButton superview]).fullName forState:UIControlStateNormal];
            
            [hitButton setBackgroundColor: ((TGLOCustomRsvpView *)[hitButton superview]).defaultColor];
            
        } else {
            
            if ([canceled isEqual:@1]) {
                //stay with grey for attended ui color
                imageLocation = [[NSString alloc] initWithFormat:@"%@/grey120x120.png", bundlePath ];
            } else {
                //go back to blank green
                imageLocation = [[NSString alloc] initWithFormat:@"%@/appIcon120x120.png", bundlePath ];
            }
            
            backgroundImage = [[UIImage alloc] initWithContentsOfFile:imageLocation];
        }
        
        //finally set the actaul image to be the background
        //[((TGLOCustomRsvpView *)[hitButton superview]).attendedImageView setImage:backgroundImage];
        [((TGLOCustomRsvpView *)[hitButton superview]).attendedButton setBackgroundImage:backgroundImage forState:UIControlStateNormal];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

// utility method for construct different types of views
- (id) fabricateANewView:(NSString *)viewType width:(CGFloat)viewWidth height:(CGFloat)viewHeight spacing: (CGFloat)viewSpacing
{
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
    } else if ([viewType isEqualToString:@"TGLOCustomRsvpView"]) {
        return [[TGLOCustomRsvpView alloc] initWithFrame:viewRect];
    
    } else {
        return @"ERROR";
    }
}


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

- (IBAction)viewAutoresponse:(id)sender {
    NSLog(@"viewAutoresponse");
    NSLog(@"parsedEvent.autoresponse: %@", parsedEvent.autoresponse);
    
    NSString *autoresponse;
    if (parsedEvent.autoresponse == nil) {
        autoresponse = @"No autoresponse set";
    } else {
        autoresponse = parsedEvent.autoresponse;
    }
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Autoresponse" message:autoresponse delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
    [alert show];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
