//
//  TGLOPerson.m
//  TheGreensLeadOrganizerApp
//
//  Created by andre on 10/04/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import "TGLOPerson.h"

@interface TGLOPerson ()
{
    

}

@end

@implementation TGLOPerson

@synthesize firstName;
@synthesize lastName;
@synthesize email;
@synthesize phone;
@synthesize mobile;
@synthesize note;
@synthesize supportLevel;



+ (NSString *)formattedSupportLevel:(NSNumber *)level
{
    NSDictionary *supportLevel = [TGLOPerson getSupportLevelDic];
    return [supportLevel objectForKey:[level stringValue]];

}

+ (NSNumber *)inverseFormattedSupportLevel:(NSString *)word
{
    NSDictionary *supportLevelInverse = [TGLOPerson swapKeysAndValuesForDic:[TGLOPerson getSupportLevelDic]];

    return [supportLevelInverse objectForKey:word];
}

+ (NSDictionary *)getSupportLevelDic
{
    NSDictionary *supportLevel = @{ @"1":@"Strong support", @"2":@"Weak support", @"3":@"Undecided", @"4":@"Weak oppose", @"5":@"Strong oppose"};

    
    
    return supportLevel;
}

+ (NSDictionary *)swapKeysAndValuesForDic:(NSDictionary *)dic
{
    NSMutableDictionary *swappedDic = [[NSMutableDictionary alloc] initWithCapacity:[dic count]];
    
    for (NSString *key in dic) {
        [swappedDic setObject:key forKey:[dic valueForKey:key]];
    }
    
    NSDictionary *finalDic = [NSDictionary dictionaryWithDictionary:swappedDic];

    return finalDic;

}

@end
