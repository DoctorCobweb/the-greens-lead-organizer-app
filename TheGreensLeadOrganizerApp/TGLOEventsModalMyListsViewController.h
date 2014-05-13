//
//  TGLOEventsModalMyListsViewController.h
//  Vic Greens
//
//  Created by andre on 13/05/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TGLOEditPersonFromListViewController.h"


@interface TGLOEventsModalMyListsViewController : UIViewController<UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

//passed in from TGLOEditPersonFromListViewController
@property (strong, nonatomic) NSNumber *personIdFromList;

@property (strong, nonatomic) TGLOEditPersonFromListViewController *delegate;

- (IBAction)cancelModal:(id)sender;

- (void)getAllEvents;
- (NSMutableIndexSet *)getIndexSetOfMatches:(NSString *)searchTerm;
- (void)handleRsvp:(NSString *)status selectedRowAtIndexPath: (NSIndexPath *)indexPath matchedRsvpId:(NSString *)matchedRsvpId alreadyCanceledRsvp:(BOOL)alreadyCanceledRsvp;
- (void)chooseHowManyGuests;
- (void)cancelRsvpOrChooseGuestsNumber;

@end

