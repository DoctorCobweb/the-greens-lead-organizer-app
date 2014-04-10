//
//  TGLOMainViewController.h
//  TheGreensLeadOrganizerApp
//
//  Created by andre on 8/04/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TGLOPerson.h"

@interface TGLOMainViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *firstName;
@property (weak, nonatomic) IBOutlet UITextField *lastName;
@property (weak, nonatomic) IBOutlet UIButton *email;
@property (weak, nonatomic) IBOutlet UIButton *phone;
@property (weak, nonatomic) IBOutlet UIButton *mobile;
@property (weak, nonatomic) IBOutlet UITextField *supportLevel;

@property (strong, nonatomic) TGLOPerson *person;


- (void)getMyNationBuilderDetails;
- (void)setUpAppearance;
- (void)setMyNBId:(NSString *)myNBId;
- (void)setupPerson:(NSDictionary *)me_dic;
- (TGLOPerson *)personFieldsForObject:(NSDictionary*)person;
- (void)populateTheUIWith:(TGLOPerson *)me;
@end
