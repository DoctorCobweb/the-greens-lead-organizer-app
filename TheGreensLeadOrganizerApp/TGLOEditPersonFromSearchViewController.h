//
//  TGLOEditPersonFromSearchViewController.h
//  TheGreensLeadOrganizerApp
//
//  Created by andre on 16/04/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TGLOPerson.h"
#import "TGLOUpdatePersonDelegate.h"

@interface TGLOEditPersonFromSearchViewController : UIViewController<UITextFieldDelegate, UIActionSheetDelegate>


@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UITextField *firstName;
@property (weak, nonatomic) IBOutlet UITextField *lastName;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *phone;
@property (weak, nonatomic) IBOutlet UITextField *mobile;
@property (weak, nonatomic) IBOutlet UIButton *supportLevel;
@property (weak, nonatomic) IBOutlet UITextField *addANewTag;

@property (strong ,nonatomic) TGLOPerson *person;
@property (strong, nonatomic) NSMutableArray *contacts;
@property (strong, nonatomic) NSMutableDictionary *rsvpDetails;
@property (strong, nonatomic) NSMutableDictionary *listDetails;
@property BOOL sendInRSVP;
@property BOOL sendInAddToList;

@property (nonatomic, weak) id<TGLOUpdatePersonDelegate>delegate;

- (void)setUpAppearance;
- (void)addTagViews;
- (void)addASingleTag:(NSString *)tag;
- (id) fabricateANewView:(NSString *)viewType width:(CGFloat)viewWidth height:(CGFloat)viewHeight spacing: (CGFloat)viewSpacing;
- (void)updateScrollAndContainerViewSize:(CGFloat)makeMoreRoom;
- (void)setupTagsToDeleteArray;
- (void)addContactsLabel;
- (void)makeABlankContactView;

- (void)saveTheNewContact;
- (void)displaySuccessAlert;
- (void)reRenderUI;
- (void)reRenderPreviousControllerUI;

- (void)typeValueHit:(id)sender;
- (void)methodValueHit:(id)sender;
- (void)statusValueHit:(id)sender;
- (void)supportLevelButtonHit:(id)sender;


- (IBAction)saveChanges:(id)sender;
- (void)toggleTag:(id)sender;
- (void)toggleContact:(id)sender;

- (NSString *)translateSupportLevel:(NSInteger)index;
- (void)parseTagString:(NSMutableDictionary *)tagsToKeep;
- (void)resignAllFirstResponders;

- (IBAction)chooseEventToRsvp:(id)sender;
- (void)saveTheRsvp;

- (void)saveToList;

- (IBAction)chooseListToAddTo:(id)sender;

@end
