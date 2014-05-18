//
//  TGLOMyListsViewController.h
//  TheGreensLeadOrganizerApp
//
//  Created by andre on 13/04/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TGLOMyListsViewController : UIViewController<UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

typedef void (^allListsCompletionHandler)(NSError *error);


- (void)setUpAppearance;
- (void)loadAllListEntities;
- (void)saveAllListEntities:(NSMutableArray *)results;
- (NSArray *)filterForMyLists;
- (void)getAllLists:(allListsCompletionHandler)completionBlock;
- (NSMutableArray *)extractLists:(NSArray *)myFetchedLists;
- (void)displayErrorAlert:(NSString *)errorTitle message:(NSString *)message;
- (IBAction)menuHit:(id)sender;

@end
