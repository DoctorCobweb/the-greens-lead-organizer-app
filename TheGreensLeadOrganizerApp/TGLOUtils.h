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
+ (NSString *)getUserAccessToken;
+ (NSString *)getUserNationBuilderId;
+ (void)setAccessTokenInUserDefaults:(NSString *)token;
+ (void)setMyNationBuilderIdInUserDefaults:(NSString *)myNBId;
+ (BOOL)clearOutUserSession;
+ (NSString *)formatTheDate:(NSString *)dateString withCustomFormat:(NSString *)customFormat;
+ (NSDate *)formattedDateFromString:(NSString *)dateString;
+ (NSString *)formattedDateStringFromDate:(NSDate *)date;
+ (NSArray *)sortResultsOnDate:(NSMutableArray *)searchResults;


@end
