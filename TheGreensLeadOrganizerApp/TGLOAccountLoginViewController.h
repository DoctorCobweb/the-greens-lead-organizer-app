//
//  TGLOAccountLoginViewController.h
//  TheGreensLeadOrganizerApp
//
//  Created by andre on 24/04/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TGLOAccountLoginViewController :UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *password;

- (IBAction)login:(id)sender;
@end
