//
//  TGLOAllListsViewController.h
//  Vic Greens
//
//  Created by andre on 16/05/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TGLOAllListsViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

- (void)setUpAppearance;
- (void)getAllLists;

@end
