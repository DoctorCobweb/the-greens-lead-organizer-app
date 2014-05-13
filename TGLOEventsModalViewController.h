//
//  TGLOEventsModalViewController.h
//  Vic Greens
//
//  Created by andre on 7/05/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TGLOEditMyProfileViewController.h"

@interface TGLOEventsModalViewController : UIViewController<UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) TGLOEditMyProfileViewController *delegate;

- (IBAction)cancelModal:(id)sender;

- (void)getAllEvents;
- (NSMutableIndexSet *)getIndexSetOfMatches:(NSString *)searchTerm;
- (void)handleRsvp:(NSString *)status selectedRowAtIndexPath: (NSIndexPath *)indexPath matchedRsvpId:(NSString *)matchedRsvpId alreadyCanceledRsvp:(BOOL)alreadyCanceledRsvp;
- (void)chooseHowManyGuests;
- (void)cancelRsvpOrChooseGuestsNumber;

@end
