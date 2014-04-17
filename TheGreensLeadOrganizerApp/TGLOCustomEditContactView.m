//
//  TGLOCustomEditContactView.m
//  TheGreensLeadOrganizerApp
//
//  Created by andre on 17/04/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import "TGLOCustomEditContactView.h"

static NSDictionary *contactTypes;
static NSDictionary *contactMethods;
static NSDictionary *contactStatuses;



@implementation TGLOCustomEditContactView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        
        contactTypes = @{ @"1": @"Event debrief", @"2": @"Event confirmation", @"3":@"Inbox response", @"4":@"Donation thank-you", @"5":@"Donation request", @"6":@"Volunteer recruitment", @"7": @"Meeting 1:1", @"8": @"Volunteer intake",@"9": @"Voter outreach election",@"10": @"Voter outreach issue",@"11": @"Voter persuasion",@"12": @"diggity"};
        
        
        contactMethods = @{@"delivery":@"Delivery",@"door_knock":@"Door knock",@"email":@"Email",@"email_blast":@"Email blast",@"face_to_face":@"Face to face",@"facebook":@"Facebook",@"meeting":@"Meeting",@"phone_call":@"Phone call",@"robocall":@"Robocall",@"snail_mail":@"Snail mail",@"text":@"Text",@"text_blast":@"Text blast",@"tweet":@"Tweet",@"video_call":@"Video call",@"webinar":@"Webinar",@"other":@"Other"};
        
        contactStatuses = @{@"answered":@"Answered",@"bad_info":@"Bad info",@"inaccessible":@"Inaccessible",@"left_message":@"Left message",@"meaningful_interaction":@"Meaningful interaction",@"not_interested":@"Not interested",@"no_answer":@"No answer",@"refused":@"Refused",@"send_information":@"Send information",@"other":@"Other"};
        
        
        UILabel *typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
        UILabel *methodLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 35, 80, 30)];
        UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 70, 80, 30)];
        UILabel *noteLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 105, 320, 30)];
        
        typeLabel.text =   @"Type";
        methodLabel.text = @"Method";
        statusLabel.text = @"Status";
        noteLabel.text =   @"Note";
        
        //set the font
        typeLabel.font = [UIFont boldSystemFontOfSize:14];
        methodLabel.font = [UIFont boldSystemFontOfSize:14];
        statusLabel.font = [UIFont boldSystemFontOfSize:14];
        noteLabel.font = [UIFont boldSystemFontOfSize:14];
        
        
        
        
        UITextField *typeValue = [[UITextField alloc] initWithFrame:CGRectMake(85, 0, 200, 30)];
        UITextField *methodValue = [[UITextField alloc] initWithFrame:CGRectMake(85, 35, 200, 30)];
        UITextField *statusValue = [[UITextField alloc] initWithFrame:CGRectMake(85, 70, 200, 30)];
        UITextView *noteValue = [[UITextView alloc] initWithFrame:CGRectMake(0, 140, 320, 100)];
        
        //add tags to these. used in other classes to get a ref
        //to them
        self.tag =        300;
        typeLabel.tag =   301;
        methodLabel.tag = 302;
        statusLabel.tag = 303;
        noteLabel.tag =   304;
        typeValue.tag =   305;
        methodValue.tag = 306;
        statusValue.tag = 307;
        noteValue.tag =   308;
        
        //default editing is OFF
        typeValue.userInteractionEnabled = NO;
        methodValue.userInteractionEnabled = NO;
        statusValue.userInteractionEnabled = NO;
        noteValue.editable = NO;
        noteValue.scrollEnabled = NO;
        
        
        //customize textview a bit more
        noteValue.text = @"Add note content";
        
        //set the font
        UIFont *font_ = [UIFont systemFontOfSize:14];
        UIColor *backgroundDark = [UIColor colorWithRed:220/255.0f green:220/255.0f blue:220/255.0f alpha:1.0f];
        UIColor *backgroundLabel = [UIColor colorWithRed:230/255.0f green:230/255.0f blue:230/255.0f alpha:1.0f];
        
        typeValue.font = font_;
        methodValue.font = font_;
        statusValue.font = font_;
        
        //colors
        //default to all grey as editing is disabled by default
        self.backgroundColor = backgroundDark;
        typeLabel.backgroundColor = backgroundLabel;
        methodLabel.backgroundColor = backgroundLabel;
        statusLabel.backgroundColor = backgroundLabel;
        noteLabel.backgroundColor = backgroundLabel;
        typeValue.backgroundColor = backgroundLabel;
        methodValue.backgroundColor = backgroundLabel;
        statusValue.backgroundColor = backgroundLabel;
        noteValue.backgroundColor = backgroundLabel;
        
        
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