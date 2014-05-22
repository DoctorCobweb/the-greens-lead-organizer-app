//
//  TGLOPersonFromSearchViewController.h
//  TheGreensLeadOrganizerApp
//
//  Created by andre on 12/04/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TGLOPerson.h"
#import "TGLOUpdatePersonDelegate.h"


//UpdatePersonDelegate protocol is defined in
//the TGLOEditPersonFromSearchViewControlelr.h file
@interface TGLOPersonFromSearchViewController : UIViewController <TGLOUpdatePersonDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *fullName;
@property (weak, nonatomic) IBOutlet UILabel *supportLevel;
@property (weak, nonatomic) IBOutlet UIButton *email;
@property (weak, nonatomic) IBOutlet UIButton *phone;
@property (weak, nonatomic) IBOutlet UIButton *mobile;

@property (strong, nonatomic) TGLOPerson *person;
@property (strong, nonatomic) NSMutableArray *contacts;


- (void)setUpAppearance;
- (void)getAllMyContacts;
- (void) translateContactIdsToNames:(NSArray *)filteredContactIds;
- (void)addTagViews;
- (void)addASingleTag:(NSString *)tag;
- (void)addContactsLabel;

- (UILabel *) fabricateANewTagWithWidth:(CGFloat)viewWidth height:(CGFloat)viewHeight spacing: (CGFloat)viewSpacing;

- (id) fabricateANewView:(NSString *)viewType width:(CGFloat)viewWidth height:(CGFloat)viewHeight spacing: (CGFloat)viewSpacing;
- (void)updateScrollAndContainerViewSize:(CGFloat)makeMoreRoom;

- (IBAction)makeCall:(id)sender;
- (IBAction)writeEmail:(id)sender;
- (NSArray *)reverseArray:(NSArray *)array;

@end

