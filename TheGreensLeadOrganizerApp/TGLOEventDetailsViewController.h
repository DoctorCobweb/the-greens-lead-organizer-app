//
//  TGLOEventDetailsViewController.h
//  Vic Greens
//
//  Created by andre on 8/05/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TGLOEvent.h"

@interface TGLOEventDetailsViewController : UIViewController<UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *venue;
@property (weak, nonatomic) IBOutlet UILabel *contactLabel;
@property (weak, nonatomic) IBOutlet UITextView  *detailsTextView;
//@property (weak, nonatomic) IBOutlet UITextField *contactTextField;
@property (weak, nonatomic) IBOutlet UITextField *tagsTextField;

@property (weak, nonatomic) NSString  *selectedEventId;
@property (weak, nonatomic) TGLOEvent *theEvent;

- (void)getEvent;
- (void)getAllRsvps;
- (void)fillOutEventFields:(TGLOEvent *)event;
- (void) addRsvpsLabel;
- (void) translateRsvpIdsToNames:(NSSet *)rsvps;
- (void)addRsvpsToUI;
- (id) fabricateANewView:(NSString *)viewType width:(CGFloat)viewWidth height:(CGFloat)viewHeight spacing: (CGFloat)viewSpacing;
- (void)rsvpButtonHit:(id)sender;
- (void)updateRsvpDetails:(NSDictionary *)matchedJoinedRsvp;
- (void)updateTheRsvpOnNationBuilder;
- (void)updateScrollAndContainerViewSize:(CGFloat)makeMoreRoom;

@end
