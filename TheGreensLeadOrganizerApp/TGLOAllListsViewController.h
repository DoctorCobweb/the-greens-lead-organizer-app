//
//  TGLOAllListsViewController.h
//  Vic Greens
//
//  Created by andre on 16/05/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TGLOAllListsViewController : UIViewController<UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>


@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

typedef void (^allListsCompletionHandler)(NSError *error);

- (void)setUpAppearance;
- (void) loadAllListEntities;
- (void) saveAllListEntities:(NSMutableArray *)results;
- (void)getAllLists:(allListsCompletionHandler)completionBlock;
- (void)displayErrorAlert:(NSString *)errorTitle message:(NSString *)message;

@end
