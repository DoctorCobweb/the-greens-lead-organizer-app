//
//  TGLOLogoutViewController.m
//  TheGreensLeadOrganizerApp
//
//  Created by andre on 27/04/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import "TGLOLogoutViewController.h"
#import "TGLOAppDelegate.h"

static NSString *accessToken= @"access_token";

@interface TGLOLogoutViewController ()

@end

@implementation TGLOLogoutViewController
@synthesize logoutTextView;

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
    
    //delete the access_token
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nil forKey:accessToken];
    [defaults synchronize];
    
    if (![defaults valueForKey:accessToken]) {
        self.logoutTextView.text = @"Thankyou, you're now logged out.";
        NSLog(@"access_token should be null: %@", [defaults valueForKey:accessToken]);
    } else {
        self.logoutTextView.text = @"Ooops, please try again.";
    
    }
    
    
    /*
    // now load main part of application
    dispatch_async(dispatch_get_main_queue(), ^{
        
        
        NSString *segueId = @"accountLogin";
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *initViewController = [storyboard instantiateViewControllerWithIdentifier:segueId];
        
        TGLOAppDelegate *delegate = (TGLOAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        UINavigationController *nav = (UINavigationController *) delegate.window.rootViewController;
        nav.navigationBar.hidden = NO;
        [nav pushViewController:initViewController animated:YES];
        
    });
     */
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
