//
//  TGLOEvent.h
//  Vic Greens
//
//  Created by andre on 8/05/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TGLOEvent : NSObject

@property (nonatomic, strong) NSString        *eventId;
@property (nonatomic, strong) NSString        *name;
@property (nonatomic, strong) NSString        *dateString;
@property (nonatomic, strong) NSDictionary    *venue;
@property (nonatomic, strong) NSString        *details;
@property (nonatomic, strong) NSDictionary    *contactDetails;
@property (nonatomic, strong) NSMutableArray  *tags;

+ (TGLOEvent *) eventFieldsForObject:(NSSet *)event;

@end
