//
//  TGLOCustomEditContactView.h
//  TheGreensLeadOrganizerApp
//
//  Created by andre on 17/04/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TGLOCustomEditContactView : UIView


@property (strong, nonatomic) IBOutlet UILabel *typeLabel;
@property (strong, nonatomic) IBOutlet UILabel *methodLabel;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UILabel *noteLabel;

- (NSString *)getFormattedTypeValue:(NSString *)typeValue;
- (NSString *)getFormattedMethodValue:(NSString *)methodValue;
- (NSString *)getFormattedStatusesValue:(NSString *)statusValue;




@end
