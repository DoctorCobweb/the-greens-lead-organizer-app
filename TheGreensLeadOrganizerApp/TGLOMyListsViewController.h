//
//  TGLOMyListsViewController.h
//  TheGreensLeadOrganizerApp
//
//  Created by andre on 13/04/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TGLOMyListsViewController : UITableViewController

@property (nonatomic, strong) IBOutlet UIBarButtonItem *sidebarButton;

- (void)setUpAppearance;
- (void)getMyNationBuilderDetails;
- (void)getAllMyLists;

@end
