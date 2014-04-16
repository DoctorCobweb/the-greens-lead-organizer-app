//
//  TGLOSearchViewController.h
//  TheGreensLeadOrganizerApp
//
//  Created by andre on 9/04/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TGLOSearchViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;


@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *firstName;
@property (weak, nonatomic) IBOutlet UITextField *lastName;
@property (weak, nonatomic) IBOutlet UITextField *mobile;
@property (weak, nonatomic) IBOutlet UITextField *city;
@property (weak, nonatomic) IBOutlet UITextField *state;

- (void)setUpAppearance;
- (NSString *)makeSearchUrl;
- (NSString *)percentEncodeString:(NSString *)unencodedString;
@end
