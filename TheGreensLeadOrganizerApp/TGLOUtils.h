//
//  TGLOUtils.h
//  TheGreensLeadOrganizerApp
//
//  Created by andre on 22/04/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TGLOUtils : NSObject

+ (NSString *)percentEncodeString:(NSString *)unencodedString;
+ (NSString *)trimWhiteSpace:(NSString *)someString;



+ (BOOL)isAdminPermissionLevel;
+ (BOOL)isVolunteerPermissionLevel;
+ (void)setUserPermissionLevel:(NSString *)level;
+ (NSString *)getUserPermissionLevel;
+ (void)setAccessTokenInUserDefaults:(NSString *)token;
+ (void)setMyNationBuilderIdInUserDefaults:(NSString *)myNBId;


@end
