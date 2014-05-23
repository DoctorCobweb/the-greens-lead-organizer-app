//
//  TGLOListModel.h
//  Vic Greens
//
//  Created by andre on 23/05/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface TGLOListModel : NSManagedObject

@property (nonatomic, retain) NSNumber *authorId ;
@property (nonatomic, retain) NSNumber *count;
@property (nonatomic, retain) NSNumber *id;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *slug;
@property (nonatomic, retain) NSString *sortOrder;

@end
