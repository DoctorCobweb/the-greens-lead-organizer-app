//
//  TGLOCustomContactView.m
//  TheGreensLeadOrganizerApp
//
//  Created by andre on 14/04/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import "TGLOCustomContactView.h"

@implementation TGLOCustomContactView



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        
        UILabel *typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
        UILabel *methodLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 35, 80, 30)];
        UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 70, 80, 30)];
        UILabel *noteLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 105, 320, 30)];
        
        typeLabel.text =   @"Type: ";
        methodLabel.text = @"Method: ";
        statusLabel.text = @"Status: ";
        noteLabel.text =   @"Note: ";
        
        //set the font
        typeLabel.font = [UIFont boldSystemFontOfSize:14];
        methodLabel.font = [UIFont boldSystemFontOfSize:14];
        statusLabel.font = [UIFont boldSystemFontOfSize:14];
        noteLabel.font = [UIFont boldSystemFontOfSize:14];
        
        
        
        
        UILabel *typeValue = [[UILabel alloc] initWithFrame:CGRectMake(85, 0, 200, 30)];
        UILabel *methodValue = [[UILabel alloc] initWithFrame:CGRectMake(85, 35, 200, 30)];
        UILabel *statusValue = [[UILabel alloc] initWithFrame:CGRectMake(85, 70, 200, 30)];
        UITextView *noteValue = [[UITextView alloc] initWithFrame:CGRectMake(0, 130, 320, 100)];
        
        //customize textview a bit more
        noteValue.text = @"CUSTON VIEW YAYAY";
        noteValue.editable = NO;
        noteValue.scrollEnabled = NO;
        
        //set the font
        UIFont *font_ = [UIFont systemFontOfSize:14];
        UIColor *backgroundValue = [UIColor colorWithRed:255/255.0f green:237/255.0f blue:74/255.0f alpha:1.0f];
        UIColor *backgroundLabel = [UIColor colorWithRed:255/255.0f green:130/255.0f blue:44/255.0f alpha:1.0f];
        
        typeValue.font = font_;
        methodValue.font = font_;
        statusValue.font = font_;
        
        //colors
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
