//
//  TGLOCustomContactView.m
//  TheGreensLeadOrganizerApp
//
//  Created by andre on 14/04/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import "TGLOCustomContactView.h"
#import "TGLOAppDelegate.h"

static NSDictionary *contactTypes;
static NSDictionary *contactMethods;
static NSDictionary *contactStatuses;



@implementation TGLOCustomContactView



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        
        //agtest and agv have different contact TYPES
        if([nationBuilderSlugValue isEqualToString:@"agtest"]) {
            contactTypes = @{ @"1": @"Event debrief", @"2": @"Event confirmation", @"3":@"Inbox response", @"4":@"Donation thank-you", @"5":@"Donation request", @"6":@"Volunteer recruitment", @"7": @"Meeting 1:1", @"8": @"Volunteer intake",@"9": @"Voter outreach election",@"10": @"Voter outreach issue",@"11": @"Voter persuasion",@"12": @"diggity"};
        }
        
        if ([nationBuilderSlugValue isEqualToString:@"agv"]) {
            contactTypes = @{ @"6": @"Volunteer recruitment", @"21": @"Supporter Event Invitation", @"14":@"Voter persuasion", @"2":@"Volunteer intake", @"15": @"Donation thank-you", @"16": @"Donation request",@"17": @"Event confirmation",@"18": @"Event debrief",@"19": @"Meeting 1:1",@"1": @"Inbox response",@"13": @"Voter outreach election",@"4": @"Voter outreach issue"};
        }
        
        contactMethods = @{@"delivery":@"Delivery",@"door_knock":@"Door knock",@"email":@"Email",@"email_blast":@"Email blast",@"face_to_face":@"Face to face",@"facebook":@"Facebook",@"meeting":@"Meeting",@"phone_call":@"Phone call",@"robocall":@"Robocall",@"snail_mail":@"Snail mail",@"text":@"Text",@"text_blast":@"Text blast",@"tweet":@"Tweet",@"video_call":@"Video call",@"webinar":@"Webinar",@"other":@"Other"};
        
        contactStatuses = @{@"answered":@"Answered",@"bad_info":@"Bad info",@"inaccessible":@"Inaccessible",@"left_message":@"Left message",@"meaningful_interaction":@"Meaningful interaction",@"not_interested":@"Not interested",@"no_answer":@"No answer",@"refused":@"Refused",@"send_information":@"Send information",@"other":@"Other"};
        
        UIColor *white = [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1.0f];
        
        UILabel *typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
        UILabel *methodLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 35, 80, 30)];
        UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 70, 80, 30)];
        UILabel *noteLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 105, 320, 30)];
        
        typeLabel.text =   @"Type";
        methodLabel.text = @"Method";
        statusLabel.text = @"Status";
        noteLabel.text =   @"Note";
        
        //set the font and color
        typeLabel.font = [UIFont boldSystemFontOfSize:14];
        typeLabel.textColor = white;
        methodLabel.font = [UIFont boldSystemFontOfSize:14];
        methodLabel.textColor = white;
        statusLabel.font = [UIFont boldSystemFontOfSize:14];
        statusLabel.textColor = white;
        noteLabel.font = [UIFont boldSystemFontOfSize:14];
        noteLabel.textColor = white;
        
        
        
        
        UILabel *typeValue = [[UILabel alloc] initWithFrame:CGRectMake(85, 0, 200, 30)];
        UILabel *methodValue = [[UILabel alloc] initWithFrame:CGRectMake(85, 35, 200, 30)];
        UILabel *statusValue = [[UILabel alloc] initWithFrame:CGRectMake(85, 70, 200, 30)];
        UITextView *noteValue = [[UITextView alloc] initWithFrame:CGRectMake(0, 140, 280, 100)];
        
        
        //add tags to these. used in other classes to get a ref
        //to them
        typeValue.tag =   1;
        methodValue.tag = 2;
        statusValue.tag = 3;
        noteValue.tag =   4;
        
        //customize textview a bit more
        noteValue.text = @"Default Custom Contact View note";
        noteValue.editable = NO;
        noteValue.scrollEnabled = NO;
        
        //set the font and colors
        UIFont *font_ = [UIFont systemFontOfSize:14];
        //UIColor *backgroundValue = [UIColor colorWithRed:255/255.0f green:237/255.0f blue:74/255.0f alpha:1.0f];
        UIColor *backgroundValue = [UIColor colorWithRed:242/255.0f green:178/255.0f blue:210/255.0f alpha:1.0f];
        UIColor *backgroundDark = [UIColor colorWithRed:235/255.0f green:230/255.0f blue:235/255.0f alpha:1.0f];;
        UIColor *backgroundLabel = [UIColor colorWithRed:197/255.0f green:72/255.0f blue:148/255.0f alpha:1.0f];;
        
        typeValue.font = font_;
        //typeValue.textColor = white;
        methodValue.font = font_;
        //methodValue.textColor = white;
        statusValue.font = font_;
        //statusValue.textColor = white;
        
        //noteValue.textColor = white;
        
        //colors
        self.backgroundColor = backgroundDark;
        typeLabel.backgroundColor = backgroundLabel;
        methodLabel.backgroundColor = backgroundLabel;
        statusLabel.backgroundColor = backgroundLabel;
        noteLabel.backgroundColor = backgroundLabel;
        typeValue.backgroundColor = backgroundValue;
        methodValue.backgroundColor = backgroundValue;
        statusValue.backgroundColor = backgroundValue;
        noteValue.backgroundColor = backgroundValue;
        
        
        [self addSubview:typeLabel];
        [self addSubview:methodLabel];
        [self addSubview:statusLabel];
        [self addSubview:noteLabel];
        [self addSubview:typeValue];
        [self addSubview:methodValue];
        [self addSubview:statusValue];
        [self addSubview:noteValue];
    }
    return self;
}



- (NSString *)getFormattedTypeValue:(NSString *)typeValue
{
    if (!![contactTypes valueForKey:typeValue]) {
        return [contactTypes valueForKey:typeValue];
    } else {
        return @"Type not found";
    }
}

- (NSString *)getFormattedMethodValue:(NSString *)methodValue
{
    if (!![contactMethods valueForKey:methodValue]) {
        return [contactMethods valueForKey:methodValue];
    } else {
        return @"Method not found";
    }
}


- (NSString *)getFormattedStatusesValue:(NSString *)statusValue
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
