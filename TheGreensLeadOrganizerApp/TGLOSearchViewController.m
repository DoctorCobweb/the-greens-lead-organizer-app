//
//  TGLOSearchViewController.m
//  TheGreensLeadOrganizerApp
//
//  Created by andre on 9/04/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import "TGLOSearchViewController.h"
#import "SWRevealViewController.h"
#import "TGLOSearchResultsViewController.h"
#import "TGLOAppDelegate.h"
#import "TGLOUtils.h"

static NSString *searchUrl = @"https://%@.nationbuilder.com/api/v1/people/search?%@page=1&per_page=100&access_token=%@";


@interface TGLOSearchViewController ()
{
    NSString *token;
}
@end

@implementation TGLOSearchViewController

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
    self.title = @"Search";
    
    [self setUpAppearance];
    
    token = [TGLOUtils getUserAccessToken];

}

- (void) setUpAppearance
{
    // Change button color
    //self.sidebarButton.tintColor = [UIColor colorWithWhite:0.04f alpha:0.9f];
    self.sidebarButton.tintColor = [UIColor colorWithWhite:0.05f alpha:1.0f];
    
    self.scrollView.contentSize =CGSizeMake(320, 700);
    
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


- (NSString *)makeSearchUrl
{
    NSLog(@"startSearch button hit");
    NSMutableString *queryString_ = [[NSMutableString alloc] init];
    
    NSString *searchUrl_ = [[NSString alloc] init];
    
    //trim whitespace and percent encode parameters
    NSString *firstName_ = [TGLOUtils percentEncodeString:[TGLOUtils trimWhiteSpace:self.firstName.text]];
    NSString *lastName_  = [TGLOUtils percentEncodeString:[TGLOUtils trimWhiteSpace:self.lastName.text]];
    NSString *city_      = [TGLOUtils percentEncodeString:[TGLOUtils trimWhiteSpace:self.city.text]];
    NSString *state_     = [TGLOUtils percentEncodeString:[TGLOUtils trimWhiteSpace:self.state.text]];
    NSString *mobile_    = [TGLOUtils percentEncodeString:[TGLOUtils trimWhiteSpace:self.mobile.text]];
    
    
    if (![firstName_ isEqualToString:@""]) {
        NSLog(@"firstName_ != empyty String");
        [queryString_ appendFormat:@"first_name=%@&", firstName_ ];
    
    }
    
    if (![lastName_ isEqualToString:@""]) {
        NSLog(@"lastName_ != empyty String");
        [queryString_ appendFormat:@"last_name=%@&", lastName_];
        
    }
    
    if (![city_ isEqualToString:@""]) {
        NSLog(@"city_ != empyty String");
        [queryString_ appendFormat:@"city=%@&", city_];
    
    }
    
    if (![state_ isEqualToString:@""]) {
        NSLog(@"state_ != empyty String");
        [queryString_ appendFormat:@"state=%@&", state_];
    
    }
    
    if (![mobile_ isEqualToString:@""]) {
        NSLog(@"mobile_ != empyty String");
        [queryString_ appendFormat:@"with_mobile=%@&", mobile_];
    }
    
    //NSLog(@"querystring: %@", queryString_);
    
    searchUrl_ = [[NSString alloc] initWithFormat:searchUrl, nationBuilderSlugValue, queryString_, token];
    
    //NSLog(@"searchUrl is: %@", searchUrl_);
    
    return searchUrl_;
}




#pragma UITextFieldDelegate methods

//hide keyboard if enter key is pressed
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
    }
    
    return YES;
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"preparing for segue...");
    
    //first we must construct the searchUrl to
    //pass to next view controller
    NSString *searchUrl_ = [self makeSearchUrl];
    NSLog(@"searchUrl_: %@", searchUrl_);
    
    if ([segue.identifier isEqualToString:@"showSearchResults"]) {
        
        TGLOSearchResultsViewController *destViewController = (TGLOSearchResultsViewController *) segue.destinationViewController;
        destViewController.searchUrl= searchUrl_;
    }
}

@end
