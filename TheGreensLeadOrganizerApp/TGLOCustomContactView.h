//
//  TGLOCustomContactView.h
//  TheGreensLeadOrganizerApp
//
//  Created by andre on 14/04/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TGLOCustomContactView : UIView

@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *methodLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *noteLabel;

- (NSString *)getFormattedTypeValue:(NSString *)typeValue;
- (NSString *)getFormattedMethodValue:(NSString *)methodValue;
- (NSString *)getFormattedStatusesValue:(NSString *)statusValue;



@end
