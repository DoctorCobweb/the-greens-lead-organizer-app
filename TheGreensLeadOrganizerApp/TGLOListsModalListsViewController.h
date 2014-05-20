//
//  TGLOListsModalListsViewController.h
//  Vic Greens
//
//  Created by andre on 20/05/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TGLOEditPersonFromListViewController.h"

@interface TGLOListsModalListsViewController : UIViewController<UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>


@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) TGLOEditPersonFromListViewController *delegate;



typedef void (^allListsCompletionHandler)(NSError *error);


- (void)setUpAppearance;
- (void) loadAllListEntities;
- (void) saveAllListEntities:(NSMutableArray *)results;
- (void)getAllLists:(allListsCompletionHandler)completionBlock;
- (void)displayErrorAlert:(NSString *)errorTitle message:(NSString *)message;

- (IBAction)cancelModal:(id)sender;




@end
