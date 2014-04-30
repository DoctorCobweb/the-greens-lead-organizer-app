//
//  TGLOLogoutViewController.m
//  TheGreensLeadOrganizerApp
//
//  Created by andre on 27/04/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import "TGLOLogoutViewController.h"
#import "TGLOAppDelegate.h"
#import "FXBlurView.h"

static NSString *accessToken= @"access_token";

@interface TGLOLogoutViewController ()

@property (nonatomic, weak) IBOutlet FXBlurView *blurView;

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
    self.blurView.dynamic = NO;
    self.blurView.blurRadius = 100;
    self.blurView.tintColor = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:1.0f];
    
    [((UINavigationController *)[self navigationController]).navigationBar setHidden:YES];
    
    
    //delete the access_token
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nil forKey:accessToken];
    [defaults synchronize];
    
    if (![defaults valueForKey:accessToken]) {
        self.logoutTextView.text = @"Thankyou.";
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
