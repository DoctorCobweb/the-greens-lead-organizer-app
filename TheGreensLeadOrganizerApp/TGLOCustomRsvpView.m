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
    
    
    
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.defaultColor = [UIColor colorWithRed:115/255.0f green:89/255.0f blue:162/255.0f alpha:1.0f];
        
        //setup the button
        self.rsvpButton =[UIButton buttonWithType:UIButtonTypeSystem];
        self.rsvpButton.frame = CGRectMake(0,0,280, 35);
        [self.rsvpButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.rsvpButton setBackgroundColor:self.defaultColor];
        
        self.attendedImageView =[[UIImageView alloc] initWithFrame:CGRectMake(245, 0, 35, 35)];
        
        
        
        NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
        //NSLog(@"bundlePath: %@", bundlePath);
        NSString *imageLocation = [[NSString alloc] initWithFormat:@"%@/appIcon120x120.png", bundlePath ];
        //NSString *imageLocation = [[NSString alloc] initWithFormat:@"%@/checkerMark60x60.png", bundlePath ];
        UIImage *backgroundImage = [[UIImage alloc] initWithContentsOfFile:imageLocation];
        //NSLog(@"backgroundImage: %@", backgroundImage);
        
        [self.attendedImageView setImage:backgroundImage];

        
        [self addSubview:self.rsvpButton];
        [self addSubview:self.attendedImageView];
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
