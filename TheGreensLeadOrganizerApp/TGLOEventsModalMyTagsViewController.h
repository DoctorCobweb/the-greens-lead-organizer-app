//
//  TGLOEventsModalMyTagsViewController.h
//  Vic Greens
//
//  Created by andre on 14/05/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TGLOEditPersonFromTagViewController.h"


@interface TGLOEventsModalMyTagsViewController : UIViewController<UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

//passed in from TGLOEditPersonFromTagViewController
@property (strong, nonatomic) NSNumber *personIdFromList;

@property (strong, nonatomic) TGLOEditPersonFromTagViewController *delegate;

- (IBAction)cancelModal:(id)sender;

- (void)getAllEvents;
- (NSMutableIndexSet *)getIndexSetOfMatches:(NSString *)searchTerm;
- (void)handleRsvp:(NSString *)status selectedRowAtIndexPath: (NSIndexPath *)indexPath matchedRsvpId:(NSString *)matchedRsvpId alreadyCanceledRsvp:(BOOL)alreadyCanceledRsvp;
- (void)chooseHowManyGuests;
- (void)cancelRsvpOrChooseGuestsNumber;

@end
