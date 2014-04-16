//
//  TGLOSearchViewController.m
//  TheGreensLeadOrganizerApp
//
//  Created by andre on 9/04/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import "TGLOSearchViewController.h"
#import "SWRevealViewController.h"
//#import "AFNetworking.h"
#import "TGLOSearchResultsViewController.h"
#import "TGLOAppDelegate.h"

static NSString *NBSlug = @"agtest";
static NSString *accessToken = @"access_token";
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
    
    token = [[NSUserDefaults standardUserDefaults] objectForKey:accessToken];

}

- (void) setUpAppearance
{
    // Change button color
    //self.sidebarButton.tintColor = [UIColor colorWithWhite:0.04f alpha:0.9f];
    self.sidebarButton.tintColor = [UIColor colorWithWhite:0.05f alpha:1.0f];
    
    self.scrollView.contentSize =CGSizeMake(320, 800);
    
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
    
    NSString *firstName_ = [self percentEncodeString:self.firstName.text];
    NSString *lastName_  = [self percentEncodeString:self.lastName.text ];
    NSString *city_      = [self percentEncodeString:self.city.text];
    NSString *state_     = [self percentEncodeString:self.state.text];
    NSString *mobile_    = [self percentEncodeString:self.mobile.text];
    
    
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
    
    NSLog(@"querystring: %@", queryString_);
    
    searchUrl_ = [[NSString alloc] initWithFormat:searchUrl, nationBuilderSlugValue, queryString_, token];
    
    //NSLog(@"searchUrl is: %@", searchUrl_);
    
    return searchUrl_;
}


//percent encode all the search terms before calling search enpoint
- (NSString *)percentEncodeString:(NSString *)unencodedString
{
    NSUInteger stringLength = [unencodedString length];
    NSMutableString *encodedString = [[NSMutableString alloc] init];
    
    
    //characters used in percent escaping:
    //space!#$&'()*+,/:;=?@[]"%-.<>\^_`{|}~
    NSDictionary *reservedCharacters = @{ @" ": @"%20", @"!":@"%21",@"#":@"%23",@"$":@"%24",@"&":@"%26",@"'":@"%27",@"(":@"%28",@")":@"%29",@"*":@"%2A",@"+":@"%2B",@",":@"%2C",@"/":@"%2F",@":":@"%3A",@";":@"%3B",@"=":@"%3D",@"?":@"%3F",@"hack@":@"%40",@"[":@"%5B",@"]":@"%5D",@"%":@"%25", @"\"":@"%22",@"%":@"%25",@"-":@"%2D",@".":@"%2E",@"<":@"%3C",@">":@"%3E",@"\\":@"%5C",@"^":@"%5E",@"_":@"%5F",@"`":@"%60",@"{":@"%7B",@"|":@"%7C",@"}":@"%7D",@"~":@"%7E"};
    
    
    for (int i = 0; i < stringLength; i++) {
        unichar c = [unencodedString characterAtIndex:i];
        
        NSString *characterAtIString = [[NSString alloc] initWithFormat:@"%c", c];
        NSLog(@"%@",characterAtIString);
        
        //handle @ character separately
        //there has to be a less hacky way to do this.
        //but for now just do this
        if([characterAtIString isEqualToString:@"@"]){
            //handler @ differently @"@" -> @"hack@" as a key
            //we have a reserved character
            //NSLog(@"reserved char as string: %@", characterAtIString);
            NSString *encodingValue = [reservedCharacters valueForKey:@"hack@"];
            [encodedString appendString:encodingValue];
            continue;
        }
        
        
        //all other characters are handled here
        if (!![reservedCharacters valueForKey:characterAtIString]) {
            //we have a reserved character
            //NSLog(@"reserved char as string: %@", characterAtIString);
            NSString *encodingValue = [reservedCharacters valueForKey:characterAtIString];
            [encodedString appendString:encodingValue];
            continue;
        }
        //NSLog(@"unreserved char: %@", characterAtIString);
            [encodedString appendString:characterAtIString];
    }
    NSLog(@"unecoded string: %@", unencodedString);
    NSLog(@"Percent encodedString: %@", encodedString);
    
    NSString * finalEncodedString = [NSString stringWithString:encodedString];
    
    return finalEncodedString;
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
