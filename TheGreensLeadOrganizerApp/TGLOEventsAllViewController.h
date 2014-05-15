//
//  TGLOEventsAllViewController.h
//  Vic Greens
//
//  Created by andre on 8/05/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TGLOEventsAllViewController : UIViewController<UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

typedef void (^allEventsCompletionHandler)(NSError *error);



- (void)loadAllEventEntities;
- (void)saveAllEventEntities:(NSMutableArray *)results;
- (void)getAllEvents: (allEventsCompletionHandler)completionBlock;
- (void)displayErrorAlert:(NSString *)errorTitle message:(NSString *)message;



- (NSMutableIndexSet *)getIndexSetOfMatches:(NSString *)searchTerm;

@end