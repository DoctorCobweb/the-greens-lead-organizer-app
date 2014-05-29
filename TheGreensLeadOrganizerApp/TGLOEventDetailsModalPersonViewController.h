//
//  TGLOEventDetailsModalPersonViewController.h
//  Vic Greens
//
//  Created by andre on 29/05/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TGLOPerson.h"
#import "TGLOEventDetailsViewController.h"

@interface TGLOEventDetailsModalPersonViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *fullName;
@property (weak, nonatomic) IBOutlet UILabel *supportLevel;
@property (weak, nonatomic) IBOutlet UIButton *email;
@property (weak, nonatomic) IBOutlet UIButton *phone;
@property (weak, nonatomic) IBOutlet UIButton *mobile;


@property (strong, nonatomic) TGLOPerson *person;
@property (strong, nonatomic) NSMutableArray *contacts;



@property (strong, nonatomic) NSNumber *personId;
@property (strong, nonatomic) TGLOEventDetailsViewController *delegate;

- (IBAction)cancelItemHit:(id)sender;


- (void)getMyNationBuilderDetails;
- (void)setupPerson:(NSDictionary *)me_dic;

- (void)setUpAppearance;
- (void)getAllMyContacts;
- (void)translateContactIdsToNames:(NSArray *)filteredContactIds;
- (void)addTagViews;
- (void)addASingleTag:(NSString *)tag;
- (void)addContactsLabel;
- (UILabel *)fabricateANewTagWithWidth:(CGFloat)viewWidth height:(CGFloat)viewHeight spacing:(CGFloat)viewSpacing;

- (id)fabricateANewView:(NSString *)viewType width:(CGFloat)width height:(CGFloat)viewHeight spacing:(CGFloat)viewSpacing;
- (void)updateScrollAndContainerViewSize:(CGFloat)makeMoreRoom;

- (void)addContactViews;
- (void)addASingleContact:(int)index;
- (NSArray *)reverseArray:(NSArray *)array;


- (IBAction)makeCall:(id)sender;
- (IBAction)writeEmail:(id)sender;

@end
