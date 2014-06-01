//
//  TGLOUtils.m
//  TheGreensLeadOrganizerApp
//
//  Created by andre on 22/04/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import "TGLOUtils.h"

static NSString *nationBuilderAccessTokenKey = @"access_token";
static NSString *myNationBuilderIdKey = @"my_nation_builder_id";
static NSString *permissionLevelKey = @"permission_level";
static NSString *permissionLevelAdmin = @"admin";
static NSString *permissionLevelVolunteer = @"volunteer";

@implementation TGLOUtils


//percent encode all the search terms before calling search enpoint
+ (NSString *)percentEncodeString:(NSString *)unencodedString
{
    NSUInteger stringLength = [unencodedString length];
    NSMutableString *encodedString = [[NSMutableString alloc] init];
    
    //characters used in percent escaping:
    //space!#$&'()*+,/:;=?@[]"%-.<>\^_`{|}~
    NSDictionary *reservedCharacters =
        @{ @" ": @"%20",
           @"!":@"%21",
           @"#":@"%23",
           @"$":@"%24",
           @"&":@"%26",
           @"'":@"%27",
           @"(":@"%28",
           @")":@"%29",
           @"*":@"%2A",
           @"+":@"%2B",
           @",":@"%2C",
           @"/":@"%2F",
           @":":@"%3A",
           @";":@"%3B",
           @"=":@"%3D",
           @"?":@"%3F",
           @"hack@":@"%40",
           @"[":@"%5B",
           @"]":@"%5D",
           @"%":@"%25",
           @"\"":@"%22",
           @"%":@"%25",
           @"-":@"%2D",
           @".":@"%2E",
           @"<":@"%3C",
           @">":@"%3E",
           @"\\":@"%5C",
           @"^":@"%5E",
           @"_":@"%5F",
           @"`":@"%60",
           @"{":@"%7B",
           @"|":@"%7C",
           @"}":@"%7D",
           @"~":@"%7E"};
    
    for (int i = 0; i < stringLength; i++) {
        unichar c = [unencodedString characterAtIndex:i];
        
        NSString *characterAtIString = [[NSString alloc] initWithFormat:@"%c", c];
        //NSLog(@"%@",characterAtIString);
        
        //handle @ character separately
        //there has to be a less hacky way to do this.
        //but for now just do this
        if([characterAtIString isEqualToString:@"@"]){
            //handler @ differently @"@" -> @"hack@" as a key
            //we have a reserved character
            //NSLog(@"reserved char as string: %@", characterAtIString);
            NSString *encodingValue = [reservedCharacters valueForKey:@"hack@"];
            [encodedString appendString:encodingValue];
            continue;
        }
        
        //all other characters are handled here
        if (!![reservedCharacters valueForKey:characterAtIString]) {
            //we have a reserved character
            //NSLog(@"reserved char as string: %@", characterAtIString);
            NSString *encodingValue = [reservedCharacters valueForKey:characterAtIString];
            [encodedString appendString:encodingValue];
            continue;
        }
        //NSLog(@"unreserved char: %@", characterAtIString);
        [encodedString appendString:characterAtIString];
    }
    //NSLog(@"unecoded string: %@", unencodedString);
    //NSLog(@"Percent encodedString: %@", encodedString);
    
    NSString * finalEncodedString = [NSString stringWithString:encodedString];
    
    return finalEncodedString;
}


+ (NSString *)trimWhiteSpace:(NSString *)someString
{
    return [someString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet ]];
}


+ (BOOL)isAdminPermissionLevel
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:permissionLevelKey] isEqualToString:permissionLevelAdmin];
}


+ (BOOL)isVolunteerPermissionLevel
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:permissionLevelKey] isEqualToString:permissionLevelVolunteer];
}


+ (void)setUserPermissionLevel:(NSString *)level
{
    //NSLog(@"setUserPermissionLevel, level: %@", level);
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    //quick validation
    if (![level isEqualToString:permissionLevelAdmin] && ![level isEqualToString:permissionLevelVolunteer]) {
        NSLog(@"FAIL permission level validation");
        return;
    }
    [userDefaults setObject:level forKey:permissionLevelKey];
    [userDefaults synchronize];
}


+ (NSString *)getUserPermissionLevel
{
    NSUserDefaults *uDef = [NSUserDefaults standardUserDefaults];
    NSString *pLevel = [uDef objectForKey:permissionLevelKey];
    //NSLog(@"getUserPermissionLevel: level is: %@", pLevel);
    return  pLevel;
}


+ (NSString *)getUserAccessToken
{
    NSUserDefaults *uDef = [NSUserDefaults standardUserDefaults];
    NSString *accessToken = [uDef objectForKey:nationBuilderAccessTokenKey];
    //NSLog(@"getUserAccessToken, accessToken: %@", accessToken);
    return  accessToken;
}


+ (NSString *)getUserNationBuilderId
{
    NSUserDefaults *uDef = [NSUserDefaults standardUserDefaults];
    NSString *myNBId = [uDef objectForKey:myNationBuilderIdKey];
    //NSLog(@"getUserNationBuilderId, myNBId: %@", myNBId);
    return  myNBId;
}


+ (void)setAccessTokenInUserDefaults:(NSString *)token
{
    //NSLog(@"setAccessTokenInUserDefaults, token: %@", token);
    NSUserDefaults *uDef = [NSUserDefaults standardUserDefaults];
    [uDef setObject:token forKey:nationBuilderAccessTokenKey];
    [uDef synchronize];
}


+ (void)setMyNationBuilderIdInUserDefaults:(NSString *)myNBId
{
    //NSLog(@"setMyNationBuilderIdInUserDefaults, myNBId: %@", myNBId);
    NSUserDefaults *uDef = [NSUserDefaults standardUserDefaults];
    [uDef setObject:myNBId forKey:myNationBuilderIdKey];
    [uDef synchronize];
}


+ (BOOL)clearOutUserSession
{
    NSLog(@"clearing out all session data...");
    NSUserDefaults *uDef = [NSUserDefaults standardUserDefaults];
    //delete the access_token
    [uDef setObject:nil forKey:nationBuilderAccessTokenKey];
    [uDef setObject:nil forKey:myNationBuilderIdKey];
    [uDef setObject:nil forKey:permissionLevelKey];
    return [uDef synchronize];
}




+ (NSString *)formatTheDate:(NSString *)dateString withCustomFormat:(NSString *)customFormat
{
    //need to format the startTime to display better
    //create a date formatter
    //create a custom date format string & use to format the startTime sent from NB
    //change the date formatter to make date have less detail
    //create the string version of the date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    //custom date format string
    [dateFormatter setDateFormat:customFormat];
    
    NSDate *date =[dateFormatter dateFromString:dateString];
    
    //now set the format to a simpler detail form for date
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    //return the string from simpler date format
    return[dateFormatter stringFromDate:date];
}

// need 2 different kinds of custom date formatting
+ (NSDate *)formattedDateFromString:(NSString *)dateString
{
    //we get a string of date formate
    //2014-05-04T19:13:34+10:00

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ssZZZZ"];
    
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:10]];
    
    NSDate *date =[dateFormatter dateFromString:dateString];
    
    return date;
}

+ (NSString *)formattedDateStringFromDate:(NSDate *)date
{

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //now set the format to a simpler detail form for date
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    NSString *dateString = [dateFormatter stringFromDate:date];


    return dateString;
}


+ (NSArray *)sortResultsOnDate:(NSMutableArray *)searchResults
{
    return [searchResults sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        
        NSDate *dateA = [self formattedDateFromString:[a objectForKey:@"created_at"]];
        NSDate *dateB = [self formattedDateFromString:[b objectForKey:@"created_at"]];
        //NSLog(@"dateA: %@", dateA);
        //NSLog(@"dateB: %@", dateB);
        
        NSComparisonResult comparison = [dateA compare:dateB];
        
        //determine how to order
        if (comparison == NSOrderedDescending) {
            //NSLog(@"1: older first");
            return NSOrderedAscending;
        } else if (comparison == NSOrderedAscending) {
            //NSLog(@"2: younger first");
            return NSOrderedDescending;
        } else {
            //NSLog(@"3: in else block");
            return NSOrderedDescending;
        }
    }];
}


@end
