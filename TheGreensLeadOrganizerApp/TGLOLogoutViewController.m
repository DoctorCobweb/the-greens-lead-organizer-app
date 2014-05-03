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
#import "TGLOUtils.h"

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
    self.blurView.blurRadius = 15;
    self.blurView.tintColor = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:1.0f];
    
    [((UINavigationController *)[self navigationController]).navigationBar setHidden:YES];
    
    //log out user using a utility method
    //clear out access token, myNBId and permissionLevel data
    BOOL successfulLogout = [TGLOUtils clearOutUserSession];
    
    if (successfulLogout) {
        self.logoutTextView.text = @"Thankyou.";
    } else {
        self.logoutTextView.text = @"Ooops, please try again.";
    
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
