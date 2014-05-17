//
//  TGLOEventsViewController.m
//  Vic Greens
//
//  Created by andre on 5/05/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import "TGLOEventsViewController.h"
#import "SWRevealViewController.h"
#import "FXBlurView.h"

@interface TGLOEventsViewController ()
@property (weak, nonatomic) IBOutlet FXBlurView *blurView;
@end

@implementation TGLOEventsViewController

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
    //since Lists tab hides our app wide nav bar
    //make sure it is NOT hidden before displaying
    //this view controllers' view
    [[[self navigationController] navigationBar] setHidden:NO];
    
    
    // Do any additional setup after loading the view.
    //setup the burring of the background image
    self.blurView.dynamic = NO;
    self.blurView.blurRadius =15;
    self.blurView.tintColor = [UIColor colorWithRed:20/255.0f green:0/255.0f blue:80/255.0f alpha:1.0f];
    
    NSLog(@"TGLOEventsViewController");
    [self setUpAppearance];
}



- (void)setUpAppearance
{
    self.title = @"Events";
    
    // Change button color
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
