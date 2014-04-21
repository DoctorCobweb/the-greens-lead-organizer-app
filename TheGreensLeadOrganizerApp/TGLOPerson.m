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


#warning TODO: rename methods and error checking etc

- (NSString *) apiVersionOfSupportLevel:(NSString *)support_
{

    NSDictionary *supportDic = @{@"Strong support":@"1",@"Weak support":@"2",@"Undecided":@"3",@"Weak oppose":@"4",@"Strong oppose":@"5"};

    return [supportDic valueForKey:support_];
}

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


//get arbitrary fields from each person.
+ (TGLOPerson *) personFieldsForObject:(NSDictionary*)person
{
    //NSLog(@"personFieldsForObject, person: %@", person);
    
    //create a temp person to which we will
    //return the reference to to caller
    TGLOPerson * _person = [[TGLOPerson alloc] init];
    
    
    //check to see if any of the entries are equal to the
    //null singleton returned by [NSNull null]
    //from inspection some fields in the console print out to
    //"<null>" which is how [NSNull null] is printed out
    if ([person objectForKey:@"id"] == [NSNull null]) {
        _person.recordID = nil;
    } else {
        _person.recordID = [person objectForKey:@"id"];
    }
    
    
    if ([person objectForKey:@"first_name"] == [NSNull null]) {
        _person.firstName = nil;
    } else {
        _person.firstName = [person objectForKey:@"first_name"];
    }
    
    
    if ([person objectForKey:@"last_name"] == [NSNull null]) {
        _person.lastName = nil;
    } else {
        _person.lastName = [person objectForKey:@"last_name"];
    }
    
    
    if ([person objectForKey:@"email"] == [NSNull null]) {
        _person.email = nil;
    } else {
        _person.email = [person objectForKey:@"email"];
    }
    
    
    if ([person objectForKey:@"phone"] == [NSNull null]) {
        _person.phone = nil;
    } else {
        _person.phone = [person objectForKey:@"phone"];
    }
    
    
    if ([person objectForKey:@"mobile"] == [NSNull null]) {
        _person.mobile= nil;
    } else {
        _person.mobile= [person objectForKey:@"mobile"];
    }
    
    
    if ([person objectForKey:@"note"] == [NSNull null]) {
        _person.note= nil;
    } else {
        _person.note = [person objectForKey:@"note"];
    }
    
    
    if ([person objectForKey:@"support_level"] == [NSNull null]) {
        _person.supportLevel= nil;
    } else {
        _person.supportLevel= [person objectForKey:@"support_level"];
    }
    
    
    if ([person objectForKey:@"tags"] == [NSNull null]) {
        _person.tags= nil;
    } else {
        _person.tags = [person objectForKey:@"tags"];
    }
    
    return _person;
}


@end
