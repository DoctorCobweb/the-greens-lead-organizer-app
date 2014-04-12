//
//  TGLOSearchResultsViewController.h
//  TheGreensLeadOrganizerApp
//
//  Created by andre on 10/04/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TGLOPerson.h"


@interface TGLOSearchResultsViewController : UITableViewController

@property (strong, nonatomic) NSString *searchUrl;

- (void) makeSearch;
-(TGLOPerson *) personFieldsForObject:(NSDictionary *)person;

@end
