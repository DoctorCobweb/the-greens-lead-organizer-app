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
#import "TGLOUtils.h"

static NSString *loginEndpoint =@"https://cryptic-tundra-9564.herokuapp.com/logthedawgin";


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
    self.blurView.tintColor = [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1.0f];
    
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
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Logging you in." message:@"Please wait for your details to be authenticated." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    
    [alert show];
    
    //need to get notes on the person from a different api, namely
    // the contacts api
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    //must set request serializer to application/json. otherwise 406
    //is responded
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    //NSLog(@"manager.requestSerializer: %@", manager.requestSerializer); //<AFJSONRequestSerializer>
    
    [manager POST:loginEndpoint parameters:loginDetails success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@" POST loggin the  user in, responseObeject => %@",responseObject);
        
        [alert dismissWithClickedButtonIndex:0 animated:NO];
        
        NSString *accessToken = [responseObject objectForKey:@"access_token"];
        NSString *error = [responseObject objectForKey:@"error"];
        NSLog(@"error: %@", error);
        NSString *myNBId = [responseObject objectForKey:@"myNBId"];
        NSString *returnedPermissionLevel = [responseObject objectForKey:@"permissionLevel"];
        
        if (!([responseObject objectForKey:@"error"] == [NSNull null])) {
            //log in FAILURE
            self.email.text = @"";
            self.password.text = @"";
            NSLog(@"ERROR from login procedure: %@", error)
            ;
            
            // show alert view saying we are getting token
            UIAlertView *tokenAlert =
                [[UIAlertView alloc] initWithTitle:@"Login failed"
                                                message:@"Please try again."
                                                                delegate:nil
                                                       cancelButtonTitle:@"Okay"
                                                       otherButtonTitles:nil];
            [tokenAlert show];
        
            //we MUST jump out of login: method!
            return;
        }
        
        if(!!accessToken && !!myNBId && !!returnedPermissionLevel) {
            //log in SUCCESS
            [TGLOUtils setAccessTokenInUserDefaults:accessToken];
            [TGLOUtils setMyNationBuilderIdInUserDefaults:myNBId];
            [TGLOUtils setUserPermissionLevel:returnedPermissionLevel];
            
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
            //weird log in FAILURE: no error but accessToken, myNBId
            //or permissionLevel was nil. just display an alert and
            //get them to try again.
            self.email.text = @"";
            self.password.text = @"";
            NSLog(@"ERROR from login procedure. accessToken, myNDId or permissionLevel was nil. Weird error. ");
            ;
            
            // show alert view saying we are getting token
            UIAlertView *tokenAlert = [[UIAlertView alloc] initWithTitle:@"Login failed"
                                                     message:@"Please try again."
                                                    delegate:nil
                                           cancelButtonTitle:@"Okay"
                                           otherButtonTitles:nil];
            [tokenAlert show];
        }
       
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //http ERROR
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
