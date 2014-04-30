//
//  TGLOAccountLoginViewController.m
//  TheGreensLeadOrganizerApp
//
//  Created by andre on 24/04/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import "TGLOAccountLoginViewController.h"
#import "AFNetworking.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "TGLOAppDelegate.h"
#import "FXBlurView.h"



static NSString *loginEndpoint =@"https://cryptic-tundra-9564.herokuapp.com/logthedawgin";
static NSString *myNationBuilderId = @"my_nation_builder_id";

@interface TGLOAccountLoginViewController ()

@property (nonatomic, weak) IBOutlet FXBlurView *blurView;

@end

@implementation TGLOAccountLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    NSLog(@"in ACCOUT LOGIN view controller");
    
    //setup the burring of the background image
    self.blurView.dynamic = NO;
    self.blurView.blurRadius =100;
    self.blurView.tintColor = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:1.0f];
    
    if ([self.email respondsToSelector:@selector(setAttributedPlaceholder:)] && [self.password respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [UIColor whiteColor];
        self.email.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{NSForegroundColorAttributeName: color}];
        self.password.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: color}];
    } else {
        NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
        // TODO: Add fall-back code to set placeholder color.
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)login:(id)sender {
    NSLog(@"in login action handler");
    NSLog(@"self.email.text: %@", self.email.text);
    NSLog(@"self.password.text: %@", self.password.text);
    
    //hide any keyboards if showing
    [self.email resignFirstResponder];
    [self.password resignFirstResponder];
    
    NSDictionary *loginDetails = @{ @"email": self.email.text, @"password":self.password.text };
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Logging you in." message:@"Please wait for your details to be authenticated. " delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    
    [alert show];
    
    //need to get notes on the person from a different api, namely
    // the contacts api
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    //must set request serializer to application/json. otherwise 406
    //is responded
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    NSLog(@"manager.requestSerializer: %@", manager.requestSerializer);
    
    [manager POST:loginEndpoint parameters:loginDetails success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [alert dismissWithClickedButtonIndex:0 animated:NO];
        
        NSLog(@" POST loggin the  user in => %@",responseObject);
        
        NSString *access_token = [responseObject objectForKey:@"access_token"];
        NSLog(@"access_token: %@", access_token);
        NSString *error = [responseObject objectForKey:@"error"];
        NSLog(@"error: %@", error);
        NSString *myNBId = [responseObject objectForKey:@"myNBId"];
        NSLog(@"myNBId: %@", myNBId);
        
        if(!!access_token && !!myNBId && !error) {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
       
            //put access_token key/val into UserDefaults obj
            [userDefaults setObject:access_token forKey:@"access_token"];
            
            //put myNBId into UserDefaults obj
            [userDefaults setObject:myNBId forKey:myNationBuilderId];
            [userDefaults synchronize];
        
            NSString *token = [userDefaults valueForKey:@"access_token"];
            NSLog(@"TOKEN FROM UserDefaults: %@", token);
        
            // now load main part of application
            dispatch_async(dispatch_get_main_queue(), ^{
            
            
                NSString *segueId = @"signedIn";
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                UIViewController *initViewController = [storyboard instantiateViewControllerWithIdentifier:segueId];
            
                TGLOAppDelegate *delegate = (TGLOAppDelegate *)[[UIApplication sharedApplication] delegate];;
            
                UINavigationController *nav = (UINavigationController *) delegate.window.rootViewController;
                nav.navigationBar.hidden = YES;
                [nav pushViewController:initViewController animated:YES];
            });
            
        } else {
            self.email.text = @"";
            self.password.text = @"";
            // show alert view saying we are getting token
            UIAlertView *tokenAlert = [[UIAlertView alloc] initWithTitle:@"Login failed"
                                                     message:@"Please try again."
                                                    delegate:nil
                                           cancelButtonTitle:@"Okay"
                                           otherButtonTitles:nil];
            [tokenAlert show];
        }
        
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

#pragma UITextFieldDelegate methods

//hide keyboard if enter key is pressed
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{

    if ([string isEqualToString:@"\n"] && [textField isEqual:self.password]) {
        [textField resignFirstResponder];
    }

    return YES;
}


@end
