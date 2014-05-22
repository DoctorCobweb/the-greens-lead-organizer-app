//
//  TGLOCustomContactSmallView.m
//  Vic Greens
//
//  Created by andre on 21/05/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import "TGLOCustomContactSmallView.h"
#import "TGLOAppDelegate.h"


static NSDictionary *contactTypes;
static NSDictionary *contactMethods;
static NSDictionary *contactStatuses;



@implementation TGLOCustomContactSmallView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        //agtest and agv have different contact TYPES
        if([nationBuilderSlugValue isEqualToString:@"agtest"]) {
            contactTypes = @{ @"1": @"Event debrief",
                              @"2": @"Event confirmation",
                              @"3":@"Inbox response",
                              @"4":@"Donation thank-you",
                              @"5":@"Donation request",
                              @"6":@"Volunteer recruitment",
                              @"7": @"Meeting 1:1",
                              @"8": @"Volunteer intake",
                              @"9": @"Voter outreach election",
                              @"10": @"Voter outreach issue",
                              @"11": @"Voter persuasion",
                              @"12": @"diggity"};
        }
        
        if ([nationBuilderSlugValue isEqualToString:@"agv"]) {
            contactTypes = @{ @"6": @"Volunteer recruitment",
                              @"21": @"Supporter Event Invitation",
                              @"14":@"Voter persuasion",
                              @"2":@"Volunteer intake",
                              @"15": @"Donation thank-you",
                              @"16": @"Donation request",
                              @"17": @"Event confirmation",
                              @"18": @"Event debrief",
                              @"19": @"Meeting 1:1",
                              @"1": @"Inbox response",
                              @"13": @"Voter outreach election",
                              @"4": @"Voter outreach issue"};
        }
        
        contactMethods = @{@"delivery":@"Delivery",
                           @"door_knock":@"Door knock",
                           @"email":@"Email",
                           @"email_blast":@"Email blast",
                           @"face_to_face":@"Face to face",
                           @"facebook":@"Facebook",
                           @"meeting":@"Meeting",
                           @"phone_call":@"Phone call",
                           @"robocall":@"Robocall",
                           @"snail_mail":@"Snail mail",
                           @"text":@"Text",
                           @"text_blast":@"Text blast",
                           @"tweet":@"Tweet",
                           @"video_call":@"Video call",
                           @"webinar":@"Webinar",
                           @"other":@"Other"};
        
        contactStatuses = @{@"answered":@"Answered",
                            @"bad_info":@"Bad info",
                            @"inaccessible":@"Inaccessible",
                            @"left_message":@"Left message",
                            @"meaningful_interaction":@"Meaningful interaction",
                            @"not_interested":@"Not interested",
                            @"no_answer":@"No answer",
                            @"refused":@"Refused",
                            @"send_information":@"Send information",
                            @"other":@"Other"};
        
        
        UIColor *sentenceColor = [UIColor colorWithRed:242/255.0f green:178/255.0f blue:210/255.0f alpha:1.0f];
        
        UIColor *dateColor = [UIColor colorWithRed:197/255.0f green:72/255.0f blue:148/255.0f alpha:1.0f];;
 
        
        self.frame = frame;
        
        
        UILabel *contactSentence = [[UILabel alloc] init];
        UILabel *date = [[UILabel alloc] init];
        UILabel *note = [[UILabel alloc] init];
        
        
        contactSentence.font = [UIFont systemFontOfSize:14];
        date.font = [UIFont systemFontOfSize:12];
        note.font = [UIFont systemFontOfSize:14];
        
        
        //this makes labels use as many lines as needed to fit all the text in
        contactSentence.numberOfLines = 0;
        date.numberOfLines = 1;
        note.numberOfLines = 0;
        
        contactSentence.lineBreakMode = NSLineBreakByWordWrapping;
        note.lineBreakMode = NSLineBreakByWordWrapping;
        
        contactSentence.tag = 1;
        date.tag = 2;
        note.tag = 3;
        
        self.backgroundColor = [UIColor whiteColor];
        contactSentence.backgroundColor = dateColor;
        date.backgroundColor = sentenceColor;
        note.backgroundColor = [UIColor colorWithWhite:0.894 alpha:1.000];
        
        
        contactSentence.textColor = [UIColor whiteColor];
        date.textColor = [UIColor colorWithWhite:0.215 alpha:1.000];
        note.textColor = [UIColor colorWithWhite:0.215 alpha:1.000];
        
        [self addSubview:contactSentence];
        [self addSubview:date];
        [self addSubview:note];
        
    }
    return self;
}



+ (NSString *)getFormattedTypeValue:(NSString *)typeValue
{
    if (!![contactTypes valueForKey:typeValue]) {
        return [contactTypes valueForKey:typeValue];
    } else {
        return @"Type not found";
    }
}

+ (NSString *)getFormattedMethodValue:(NSString *)methodValue
{
    if (!![contactMethods valueForKey:methodValue]) {
        return [contactMethods valueForKey:methodValue];
    } else {
        return @"Method not found";
    }
}


+ (NSString *)getFormattedStatusesValue:(NSString *)statusValue
{
    if (!![contactStatuses valueForKey:statusValue]) {
        return [contactStatuses valueForKey:statusValue];
    } else {
        return @"Status not found";
    }
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
