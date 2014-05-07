//
//  TGLOEventsViewController.h
//  Vic Greens
//
//  Created by andre on 5/05/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TGLOEditMyProfileViewController.h"

@interface TGLOEventsViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIBarButtonItem *sidebarButton;
@property (nonatomic, strong) TGLOEditMyProfileViewController *delegate;

- (void)setUpAppearance;

@end