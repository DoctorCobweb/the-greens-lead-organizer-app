//
//  TGLOCustomRsvpView.h
//  Vic Greens
//
//  Created by andre on 15/05/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TGLOCustomRsvpView : UIView

@property (strong, nonatomic) NSNumber *personId;
@property (strong, nonatomic) NSString *fullName;
@property (strong, nonatomic) UIButton *rsvpButton;
@property (strong, nonatomic) UIImageView *attendedImageView;
@property (strong, nonatomic) UIColor *defaultColor;

@end
