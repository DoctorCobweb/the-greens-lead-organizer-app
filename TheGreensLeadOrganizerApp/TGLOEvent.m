//
//  TGLOEvent.m
//  Vic Greens
//
//  Created by andre on 8/05/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import "TGLOEvent.h"

@implementation TGLOEvent



@synthesize eventId;
@synthesize name;
@synthesize dateString;
@synthesize venue;
@synthesize details;
@synthesize contactDetails;
@synthesize tags;
@synthesize autoresponse;


//get arbitrary fields from each person.
+ (TGLOEvent *)eventFieldsForObject:(NSSet *)event
{
    //create a temp person to which we will
    //return the reference to to caller
    TGLOEvent *_event = [[TGLOEvent alloc] init];
    
    
    NSMutableDictionary *contactDic = [[NSMutableDictionary alloc] initWithDictionary:[event valueForKey:@"contact"]];
    NSMutableDictionary *venueDic = [[NSMutableDictionary alloc] initWithDictionary:[event valueForKey:@"venue"]];
    
    
    //*note because setting a key to nil value in a literal dic rids it of the key, here
    //we set blank values to @"" instead of nil
    
    [contactDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        //NSLog(@"in block");
        if (obj == [NSNull null]) {
            //NSLog(@"obj for key %@ is <null>", key);
            [contactDic setValue:@"" forKey:(NSString *)key];
        }
    }];
    
    //add in the sanitized contactDetails
    _event.contactDetails = contactDic;
    

    if ([venueDic objectForKey:@"name"] == [NSNull null]) {
        [venueDic setObject:@"" forKey:@"name"];
    }
    
    
    NSMutableDictionary *venueAddressDic;
    
    if ([[venueDic objectForKey:@"address"] isEqual:[NSNull null]]) {
        //NSLog(@"venueAddressDic is equal to <null>...setting blank dic");
        NSDictionary *blankDic = @{@"address1":    @"",
                                   @"address2":    @"",
                                   @"address3":    @"",
                                   @"city":        @"",
                                   @"county_code": @"",
                                   @"lat":         @"",
                                   @"lng":         @"",
                                   @"state":       @"",
                                   @"zip":         @"",
                                   };
        
        venueAddressDic = [[NSMutableDictionary alloc] initWithDictionary:blankDic];
        
    } else {
        venueAddressDic = [[NSMutableDictionary alloc] initWithDictionary:[venueDic valueForKey:@"address"]];
        //NSLog(@"venueAddressDic BEFORE: %@", venueAddressDic);
        [venueAddressDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
            if (obj == [NSNull null]) {
                //NSLog(@"obj for key %@ is <null>", key);
                [venueAddressDic setValue:@"" forKey:(NSString *)key];
            }
        }];
        //NSLog(@"venueAddressDic AFTER: %@", venueAddressDic);
    }
    
    //set the sanitized address dic for address key
    [venueDic setValue:venueAddressDic forKey:@"address"];
    
    //add in the sanitized venue details
    _event.venue = venueDic;
    
    
    //simple key/val NSString/NSString fields
    if ([event  valueForKey:@"id"] == [NSNull null]) {
        _event.eventId = nil;
    } else {
        _event.eventId = [event valueForKey:@"id"];
    }
    
    
    if ([event valueForKey:@"name"] == [NSNull null]) {
        _event.name = nil;
    } else {
        _event.name = [event valueForKey:@"name"];
    }
    
    
    if ([event valueForKey:@"start_time"] == [NSNull null]) {
        _event.dateString= nil;
    } else {
        _event.dateString = [event valueForKey:@"start_time"];
    }
    
    
    if ([event valueForKey:@"intro"] == [NSNull null]) {
        _event.details = nil;
    } else {
        
        _event.details = [self parseOutHtml:[event valueForKey:@"intro"]];
        //_event.details = [event valueForKey:@"intro"];
    }
    
    
    
    if ([event valueForKey:@"tags"] == [NSNull null]) {
        _event.tags = nil;
    } else {
        _event.tags = [event valueForKey:@"tags"];
    }
    
    
    
    if ( ([event valueForKey:@"autoresponse"] ==[NSNull null]) || ([[event valueForKey:@"autoresponse"] objectForKey:@"body"] == [NSNull null])) {
        _event.autoresponse = nil;
    } else {
        _event.autoresponse = [[event valueForKey:@"autoresponse"] objectForKey:@"body"];
    }
    
    
    /*
    NSLog(@"_event.eventId: %@", _event.eventId);
    NSLog(@"_event.name: %@", _event.name);
    NSLog(@"_event.dateString: %@", _event.dateString);
    NSLog(@"_event.details: %@", _event.details);
    NSLog(@"_event.tags: %@", _event.tags);
    NSLog(@"_event.contactDetails: %@", _event.contactDetails);
    NSLog(@"_event.venue: %@", _event.venue);
    NSLog(@"_event.autoresponse: %@", _event.autoresponse);
     */
    
    return _event;
}

+ (NSString *)parseOutHtml:(NSString *)info
{
    NSUInteger infoLength = [info length];
    NSMutableString *filteredInfo = [[NSMutableString alloc] init];
    BOOL htmlTag = NO;
    
    
    for (int i = 0; i < infoLength; i++) {
        unichar c = [info characterAtIndex:i];
        
        NSString *charAtIString = [[NSString alloc] initWithFormat:@"%c", c];
        
        if ([charAtIString isEqualToString:@"<"]) {
            //start of opening html tag.
            htmlTag = YES;
            continue;
        }
        if ([charAtIString isEqualToString:@">"]) {
            //ending an html tag
            htmlTag = NO;
            continue;
        }
        if (!htmlTag) {
            //we have proper text content that we want to keep
            [filteredInfo appendString:charAtIString];
        }
    }
    
    
    
    NSString *finalFilteredString = [NSString stringWithString:filteredInfo];
    
    //NSLog(@"UNFILTEREDSTRING info: %@", info);
    //NSLog(@"finalFilteredString: %@", finalFilteredString);
    
    return finalFilteredString;
}


@end
