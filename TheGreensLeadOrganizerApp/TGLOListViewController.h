//
//  TGLOListViewController.h
//  TheGreensLeadOrganizerApp
//
//  Created by andre on 13/04/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TGLOListViewController : UITableViewController

@property (strong, nonatomic) NSDictionary *list;
@property (strong, nonatomic) NSMutableArray *searchResults;
@property NSInteger lastPersonSelected;

- (void) getPeopleInList;

@end
