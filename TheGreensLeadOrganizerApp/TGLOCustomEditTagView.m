//
//  TGLOCustomEditTagView.m
//  TheGreensLeadOrganizerApp
//
//  Created by andre on 16/04/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import "TGLOCustomEditTagView.h"

@implementation TGLOCustomEditTagView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIColor * blackColor = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:1.0f];
        UIColor * greenColor = [UIColor colorWithRed:129/255.0f green:193/255.0f blue:87/255.0f alpha:1.0f];
        
        
        //setup the button
        UIButton *tagButton =[UIButton buttonWithType:UIButtonTypeSystem];
        tagButton.frame = CGRectMake(0,0,200, 35);
        [tagButton setTitleColor:blackColor forState:UIControlStateNormal];
        
        [tagButton setTitle:@"TESTING" forState:UIControlStateNormal];
        //NSLog(@"tagButton currentTitle: %@", [tagButton currentTitle]);
        
        
        NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
        //NSLog(@"bundlePath: %@", bundlePath);
        NSString *imageLocation = [[NSString alloc] initWithFormat:@"%@/appIcon120x120.png", bundlePath ];
        UIImage *backgroundImage = [[UIImage alloc] initWithContentsOfFile:imageLocation];
        //NSLog(@"backgroundImage: %@", backgroundImage);
        
        [tagButton setBackgroundImage:backgroundImage forState:UIControlStateNormal];
        
        
        //setup the switch now
        UISwitch *tagSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(220,0, 70, 35)];
        
        tagSwitch.on = YES;
        tagSwitch.onTintColor = greenColor;
        
        [self addSubview:tagButton];
        [self addSubview:tagSwitch];
        
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
