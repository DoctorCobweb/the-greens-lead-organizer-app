//
//  TGLOCustomEditContactHeaderView.m
//  TheGreensLeadOrganizerApp
//
//  Created by andre on 17/04/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import "TGLOCustomEditContactHeaderView.h"

@implementation TGLOCustomEditContactHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //UIColor * blackColor = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:1.0f];
        UIColor * greenColor = [UIColor colorWithRed:129/255.0f green:193/255.0f blue:87/255.0f alpha:1.0f];
        
        
        //setup the button
        UILabel *contactLabel =[[UILabel alloc] init];
        contactLabel.frame = CGRectMake(0,0,200, 35);
        
        contactLabel.text = @"Log a new CONTACT";
        contactLabel.font = [UIFont boldSystemFontOfSize:13];
        
        //setup the switch now
        UISwitch *contactSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(220,0, 70, 35)];
        
        contactSwitch.on = NO;
        contactSwitch.onTintColor = greenColor;
        
        
        contactSwitch.tag = 1;
        contactLabel.tag = 2;
        
        [self addSubview:contactLabel];
        [self addSubview:contactSwitch];
        
        
        
    }
    return self;
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
