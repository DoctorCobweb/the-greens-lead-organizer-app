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


//get arbitrary fields from each person.
+ (TGLOEvent *) eventFieldsForObject:(NSSet *)event
{
    //NSLog(@"personFieldsForObject, person: %@", person);
    
    //create a temp person to which we will
    //return the reference to to caller
    TGLOEvent *_event = [[TGLOEvent alloc] init];
    
    
    //check to see if any of the entries are equal to the
    //null singleton returned by [NSNull null]
    //from inspection some fields in the console print out to
    //"<null>" which is how [NSNull null] is printed out
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
    
    
    if ([event valueForKey:@"venue"] == [NSNull null]) {
        _event.venue = nil;
    } else {
        //NSLog(@"venue id not == nnull singleton");
        _event.venue = [event valueForKey:@"venue"];
    }
    
    
    if ([event valueForKey:@"intro"] == [NSNull null]) {
        _event.details = nil;
    } else {
        _event.details = [event valueForKey:@"intro"];
    }
    
    
    if ([event valueForKey:@"contact"] == [NSNull null]) {
        _event.contactDetails = nil;
    } else {
        _event.contactDetails = [event valueForKey:@"contact"];
    }
    
    
    if ([event valueForKey:@"tags"] == [NSNull null]) {
        _event.tags = nil;
    } else {
        _event.tags = [event valueForKey:@"tags"];
    }
    
    return _event;
}



@end
