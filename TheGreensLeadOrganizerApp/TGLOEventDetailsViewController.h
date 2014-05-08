//
//  TGLOEventDetailsViewController.h
//  Vic Greens
//
//  Created by andre on 8/05/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TGLOEvent.h"

@interface TGLOEventDetailsViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *dateTextField;
@property (weak, nonatomic) IBOutlet UITextField *venueTextField;
@property (weak, nonatomic) IBOutlet UITextView  *detailsTextView;
@property (weak, nonatomic) IBOutlet UITextField *contactTextField;
@property (weak, nonatomic) IBOutlet UITextField *tagsTextField;




@property (weak, nonatomic) NSString  *selectedEventId;
@property (weak, nonatomic) TGLOEvent *theEvent;

- (void)getEvent;
- (void)fillOutEventFields:(TGLOEvent *)event;

@end