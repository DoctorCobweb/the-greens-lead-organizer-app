//
//  TGLOListsTabBarController.m
//  Vic Greens
//
//  Created by andre on 17/05/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import "TGLOListsTabBarController.h"

@interface TGLOListsTabBarController ()

@end

@implementation TGLOListsTabBarController

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
    [[[self navigationController] navigationBar] setHidden:YES];
    
    self.tabBar.tintColor = [UIColor blackColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"in viewWillDisapper");
    //[[[self navigationController] navigationBar] setHidden:NO];


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
