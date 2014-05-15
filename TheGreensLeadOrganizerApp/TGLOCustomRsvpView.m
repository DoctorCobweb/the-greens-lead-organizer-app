//
//  TGLOCustomRsvpView.m
//  Vic Greens
//
//  Created by andre on 15/05/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import "TGLOCustomRsvpView.h"

@implementation TGLOCustomRsvpView

- (id)initWithFrame:(CGRect)frame
{
    
    UIColor * purpleColor = [UIColor colorWithRed:115/255.0f green:89/255.0f blue:162/255.0f alpha:1.0f];
    
    
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        //setup the button
        self.rsvpButton =[UIButton buttonWithType:UIButtonTypeSystem];
        self.rsvpButton.frame = CGRectMake(0,0,280, 35);
        [self.rsvpButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.rsvpButton setBackgroundColor:purpleColor];
        
        [self addSubview:self.rsvpButton];
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
