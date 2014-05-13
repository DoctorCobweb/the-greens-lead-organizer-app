//
//  TGLOTheGreensViewController.m
//  TheGreensLeadOrganizerApp
//
//  Created by andre on 9/04/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import "TGLOTheGreensViewController.h"
#import "SWRevealViewController.h"


//NSString * const theGreensAddress = @"https://greens.org.au";
NSString * const theGreensAddress = @"http://greens.org.au/vic/candidates/western-victoria";


@interface TGLOTheGreensViewController ()

@end

@implementation TGLOTheGreensViewController

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
    
    [self setUpAppearance];
    
    self.webView.delegate = self;
    
    
    NSURL *theGreensUrl = [[NSURL alloc] initWithString:theGreensAddress];
    
    NSURLRequest *theGreensRequest = [[NSURLRequest alloc] initWithURL:theGreensUrl];
    
    [self.webView loadRequest:theGreensRequest];
}

- (void)setUpAppearance
{
    self.title = @"Western Victoria candidate";
    
    // Change button color
    //self.sidebarButton.tintColor = [UIColor colorWithWhite:0.04f alpha:0.9f];
    self.sidebarButton.tintColor = [UIColor colorWithWhite:0.05f alpha:1.0f];
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    self.sidebarButton.target = self.revealViewController;
    self.sidebarButton.action = @selector(revealToggle:);
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma UIWebViewDelegate methods

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    //NSLog(@"webViewDidStartLoad");
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    //NSLog(@"webViewDidFinishLoad");
    self.activityIndicator.hidden = YES;
    [self.activityIndicator stopAnimating];

}
@end
