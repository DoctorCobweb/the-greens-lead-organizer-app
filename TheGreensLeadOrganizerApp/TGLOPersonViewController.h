//
//  TGLOPersonViewController.h
//  TheGreensLeadOrganizerApp
//
//  Created by andre on 9/04/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TGLOPerson.h"

@interface TGLOPersonViewController : UIViewController


@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UITextField *firstName;
@property (weak, nonatomic) IBOutlet UITextField *lastName;
@property (weak, nonatomic) IBOutlet UIButton *email;
@property (weak, nonatomic) IBOutlet UIButton *phone;
@property (weak, nonatomic) IBOutlet UIButton *mobile;
@property (weak, nonatomic) IBOutlet UITextField *supportLevel;

@property (strong, nonatomic) TGLOPerson *person;



- (void)setUpAppearance;
- (void)getAllMyContacts;
- (void)addTagViews;
- (void)addASingleTag:(NSString *)tag;
- (void)addContactsLabel;
- (id) fabricateANewView:(NSString *)viewType width:(CGFloat)viewWidth height:(CGFloat)viewHeight spacing: (CGFloat)viewSpacing;
- (void)updateScrollAndContainerViewSize:(CGFloat)makeMoreRoom;

- (IBAction)makeCall:(id)sender;
- (IBAction)writeEmail:(id)sender;

@end
