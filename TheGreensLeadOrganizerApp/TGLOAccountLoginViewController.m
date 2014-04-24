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


static NSString *loginEndpoint =@"https://cryptic-tundra-9564.herokuapp.com/logthedawgin";

@interface TGLOAccountLoginViewController ()

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
    
    NSDictionary *loginDetails = @{ @"email": self.email.text, @"password":self.password.text };
    
    
    //need to get notes on the person from a different api, namely
    // the contacts api
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    //must set request serializer to application/json. otherwise 406
    //is responded
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    NSLog(@"manager.requestSerializer: %@", manager.requestSerializer);
    
    [manager POST:loginEndpoint parameters:loginDetails success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@" POST loggin the  user in => %@",responseObject);
        
        NSString *access_token = [responseObject objectForKey:@"access_token"];
        NSLog(@"access_token: %@", access_token);
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
       
        //put code key/val into UserDefaults obj
        [userDefaults setObject:access_token forKey:@"access_token"];
        [userDefaults synchronize];
        
        NSString *token = [userDefaults valueForKey:@"access_token"];
        NSLog(@"TOKEN FROM UserDefaults: %@", token);
        
        // now load main part of application
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            NSString *segueId = @"signedIn";
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UITabBarController *initViewController = [storyboard instantiateViewControllerWithIdentifier:segueId];
            
            TGLOAppDelegate *delegate = (TGLOAppDelegate *)[[UIApplication sharedApplication] delegate];;
            
            UINavigationController *nav = (UINavigationController *) delegate.window.rootViewController;
            nav.navigationBar.hidden = YES;
            [nav pushViewController:initViewController animated:NO];
        });
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}
@end
