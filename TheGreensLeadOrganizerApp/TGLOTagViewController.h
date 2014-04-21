//
//  TGLOTagViewController.h
//  TheGreensLeadOrganizerApp
//
//  Created by andre on 9/04/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TGLOPerson.h"


@interface TGLOTagViewController : UITableViewController

@property (strong, nonatomic) NSString *tag;
@property (strong, nonatomic) NSMutableArray *searchResults;
@property NSInteger lastPersonSelected;

-(void)getPeopleInTag;

@end
