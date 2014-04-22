//
//  TGLOUtils.m
//  TheGreensLeadOrganizerApp
//
//  Created by andre on 22/04/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import "TGLOUtils.h"

@implementation TGLOUtils


//percent encode all the search terms before calling search enpoint
+ (NSString *)percentEncodeString:(NSString *)unencodedString
{
    NSUInteger stringLength = [unencodedString length];
    NSMutableString *encodedString = [[NSMutableString alloc] init];
    
    
    //characters used in percent escaping:
    //space!#$&'()*+,/:;=?@[]"%-.<>\^_`{|}~
    NSDictionary *reservedCharacters = @{ @" ": @"%20", @"!":@"%21",@"#":@"%23",@"$":@"%24",@"&":@"%26",@"'":@"%27",@"(":@"%28",@")":@"%29",@"*":@"%2A",@"+":@"%2B",@",":@"%2C",@"/":@"%2F",@":":@"%3A",@";":@"%3B",@"=":@"%3D",@"?":@"%3F",@"hack@":@"%40",@"[":@"%5B",@"]":@"%5D",@"%":@"%25", @"\"":@"%22",@"%":@"%25",@"-":@"%2D",@".":@"%2E",@"<":@"%3C",@">":@"%3E",@"\\":@"%5C",@"^":@"%5E",@"_":@"%5F",@"`":@"%60",@"{":@"%7B",@"|":@"%7C",@"}":@"%7D",@"~":@"%7E"};
    
    
    for (int i = 0; i < stringLength; i++) {
        unichar c = [unencodedString characterAtIndex:i];
        
        NSString *characterAtIString = [[NSString alloc] initWithFormat:@"%c", c];
        NSLog(@"%@",characterAtIString);
        
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
    NSLog(@"unecoded string: %@", unencodedString);
    NSLog(@"Percent encodedString: %@", encodedString);
    
    NSString * finalEncodedString = [NSString stringWithString:encodedString];
    
    return finalEncodedString;
}


+ (NSString *)trimWhiteSpace:(NSString *)someString
{
    return [someString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet ]];
}


@end
