//
//  TGLOPerson.m
//  TheGreensLeadOrganizerApp
//
//  Created by andre on 10/04/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import "TGLOPerson.h"

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
    NSDictionary *supportLevel = @{ @"1":@"Strong support", @"2":@"Weak support", @"3":@"Undecided", @"4":@"Weak oppose", @"5":@"Strong oppose"};

    return [supportLevel objectForKey:[level stringValue]];

}

@end
