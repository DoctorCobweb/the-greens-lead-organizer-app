//
//  TGLOCustomEditContactView.m
//  TheGreensLeadOrganizerApp
//
//  Created by andre on 17/04/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import "TGLOCustomEditContactView.h"
#import "TGLOAppDelegate.h"

static NSDictionary *contactTypes;
static NSDictionary *contactMethods;
static NSDictionary *contactStatuses;



@implementation TGLOCustomEditContactView

+ (NSString *) defaultContactType
{
    //return the first string in array of all keys
    return [contactTypes valueForKey:([contactTypes allKeys][0])];
}

+ (NSString *) defaultContactMethod
{
    //return the first string in array of all keys
    return [contactMethods valueForKey:([contactMethods allKeys][0])];
}

+ (NSString *) defaultContactStatus
{
    //return the first string in array of all keys
    return [contactStatuses valueForKey:([contactStatuses allKeys][0])];
}

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
                           @"linkedin":@"LinkedIn",
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
        
        
        
        // Initialization code
        UIColor * blackColor = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:1.0f];
        
        
        UILabel *typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
        UILabel *methodLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 35, 80, 30)];
        UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 70, 80, 30)];
        UILabel *noteLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 105, 80, 30)];
        UILabel *noteBuffer= [[UILabel alloc] initWithFrame:CGRectMake(80, 105, (320 - 80), 30)];
        
        typeLabel.text =   @"Type:";
        methodLabel.text = @"Method:";
        statusLabel.text = @"Status:";
        noteLabel.text =   @"Note:";
        
        //set the font
        typeLabel.font = [UIFont boldSystemFontOfSize:14];
        methodLabel.font = [UIFont boldSystemFontOfSize:14];
        statusLabel.font = [UIFont boldSystemFontOfSize:14];
        noteLabel.font = [UIFont boldSystemFontOfSize:14];
        
        typeLabel.textColor = [UIColor whiteColor];
        methodLabel.textColor = [UIColor whiteColor];
        statusLabel.textColor = [UIColor whiteColor];
        noteLabel.textColor = [UIColor whiteColor];
        
        typeLabel.textAlignment = NSTextAlignmentCenter;
        methodLabel.textAlignment = NSTextAlignmentCenter;
        statusLabel.textAlignment = NSTextAlignmentCenter;
        noteLabel.textAlignment = NSTextAlignmentCenter;
        
        
        //setup the button
        UIButton *typeValue =[UIButton buttonWithType:UIButtonTypeSystem];
        typeValue.frame = CGRectMake(85, 0, 200, 30);
        [typeValue setTitleColor:blackColor forState:UIControlStateNormal];
        //[typeValue setTitle:@"random TYPE text" forState:UIControlStateNormal];
        
        
        UIButton *methodValue =[UIButton buttonWithType:UIButtonTypeSystem];
        methodValue.frame = CGRectMake(85, 35, 200, 30);
        [methodValue setTitleColor:blackColor forState:UIControlStateNormal];
        //[methodValue setTitle:@"random METHOD text" forState:UIControlStateNormal];
        
        UIButton *statusValue =[UIButton buttonWithType:UIButtonTypeSystem];
        statusValue.frame = CGRectMake(85, 70, 200, 30);
        [statusValue setTitleColor:blackColor forState:UIControlStateNormal];
        //[statusValue setTitle:@"random STATUS text" forState:UIControlStateNormal];
        
        
        UITextView *noteValue = [[UITextView alloc] initWithFrame:CGRectMake(0, 140, 280, 200)];
        
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
        noteBuffer.tag =  309;
        
        //default editing is OFF
        typeValue.userInteractionEnabled = NO;
        methodValue.userInteractionEnabled = NO;
        statusValue.userInteractionEnabled = NO;
        noteValue.editable = NO;
        noteValue.scrollEnabled = NO;
        
        
        //customize textview a bit more
        //noteValue.text = @"Add note content";
        noteValue.font = [UIFont systemFontOfSize:14];
        
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
        noteBuffer.backgroundColor = backgroundLabel;
        noteValue.backgroundColor = backgroundLabel;
        
        
        [self addSubview:typeLabel];
        [self addSubview:methodLabel];
        [self addSubview:statusLabel];
        [self addSubview:noteLabel];
        [self addSubview:typeValue];
        [self addSubview:methodValue];
        [self addSubview:statusValue];
        [self addSubview:noteBuffer];
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



//called from all *Edit view controllers to change value of field
//to that expected by the api
- (NSString *)apiVersionOfContactType:(NSString *)contactType_
{
    NSMutableDictionary *switchedDic = [[NSMutableDictionary alloc] initWithCapacity:[contactTypes count]];
    
    for (NSString *key in contactTypes) {
        [switchedDic setObject:key forKey:[contactTypes valueForKey:key]];
    }
    NSLog(@"CONTACT TYPE: switchedDic: %@", switchedDic);
    return [switchedDic valueForKey:contactType_];
}

- (NSString *)apiVersionOfContactMethod:(NSString *)contactMethod_
{
    NSMutableDictionary *switchedDic = [[NSMutableDictionary alloc] initWithCapacity:[contactMethods count]];
    
    for (NSString *key in contactMethods) {
        [switchedDic setObject:key forKey:[contactMethods valueForKey:key]];
    }
    NSLog(@"CONTACT METHOD: switchedDic: %@", switchedDic);
    return [switchedDic valueForKey:contactMethod_];
    
}

- (NSString *)apiVersionOfContactStatus:(NSString *)contactStatus_
{
    NSMutableDictionary *switchedDic = [[NSMutableDictionary alloc] initWithCapacity:[contactStatuses count]];
    
    for (NSString *key in contactStatuses) {
        [switchedDic setObject:key forKey:[contactStatuses valueForKey:key]];
    }
    NSLog(@"CONTACT STATUS: switchedDic: %@", switchedDic);
    return [switchedDic valueForKey:contactStatus_];

}


//called by the action sheet views which allow you to tap select
//a value for all the contact fields when loggin a new contact
+ (NSString *)translateContactType:(NSInteger)index
{
    NSDictionary *contactTypes;
    
    if ([nationBuilderSlugValue isEqualToString:@"agtest"]) {
        contactTypes = @{ @"1": @"Event debrief", @"2": @"Event confirmation", @"3":@"Inbox response", @"4":@"Donation thank-you", @"5":@"Donation request", @"6":@"Volunteer recruitment", @"7": @"Meeting 1:1", @"8": @"Volunteer intake",@"9": @"Voter outreach election",@"10": @"Voter outreach issue",@"11": @"Voter persuasion",@"12": @"diggity"};
    }
    if ([nationBuilderSlugValue isEqualToString:@"agv"]) {
        contactTypes = @{ @"1": @"Event debrief", @"2": @"Event confirmation", @"3":@"Inbox response", @"4":@"Donation thank-you", @"5":@"Donation request", @"6":@"Volunteer recruitment", @"7": @"Meeting 1:1", @"8": @"Volunteer intake",@"9": @"Voter outreach election",@"10": @"Voter outreach issue",@"11": @"Voter persuasion",@"12": @"diggity"};
        
        
        contactTypes =@{@"1": @"Volunteer recruitment", @"2": @"Supporter Event Invitation", @"3": @"Voter persuasion", @"4": @"Volunteer intake", @"5": @"Donation thank-you", @"6": @"Donation request", @"7": @"Event confirmation", @"8": @"Event debrief", @"9": @"Meeting 1:1", @"10": @"Inbox response", @"11": @"Voter outreach election", @"12": @"Voter outreach issue"};
        
    }
    
    
    return [contactTypes valueForKey:[[NSString alloc] initWithFormat:@"%d", index + 1]];
}

+ (NSString *)translateContactMethod:(NSInteger)index
{
    
    NSDictionary *contactMethods = @{@"0":@"Delivery",@"1":@"Door knock",@"2":@"Email",@"3":@"Email blast",@"4":@"Face to face",@"5":@"Facebook",@"6":@"Meeting",@"7":@"Phone call",@"8":@"Robocall",@"9":@"Snail mail",@"10":@"Text",@"11":@"Text blast",@"12":@"Tweet",@"13":@"Video call",@"14":@"Webinar",@"15": @"LinkedIn", @"16":@"Other"};
    
    
    return [contactMethods objectForKey:[[NSString alloc] initWithFormat:@"%d", index]];
    
}

+ (NSString *)translateContactStatus:(NSInteger)index
{
    NSDictionary *contactStatuses = @{@"0":@"Answered",@"1":@"Bad info",@"2":@"Inaccessible",@"3":@"Left message",@"4":@"Meaningful interaction",@"5":@"Not interested",@"6":@"No answer",@"7":@"Refused",@"8":@"Send information",@"9":@"Other"};
    
    return [contactStatuses objectForKey:[[NSString alloc] initWithFormat:@"%d", index]];
    
    
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