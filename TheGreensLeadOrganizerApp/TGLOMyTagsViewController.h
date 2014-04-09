//
//  TGLOMyTagsViewController.h
//  TheGreensLeadOrganizerApp
//
//  Created by andre on 9/04/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TGLOMyTagsViewController : UITableViewController

@property (nonatomic, strong) IBOutlet UIBarButtonItem *sidebarButton;

- (void)setUpAppearance;
- (void)getMyNationBuilderDetails;
- (void)getAllMyTags;
@end
