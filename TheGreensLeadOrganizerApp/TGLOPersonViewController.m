//
//  TGLOPersonViewController.m
//  TheGreensLeadOrganizerApp
//
//  Created by andre on 9/04/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import "TGLOPersonViewController.h"

@interface TGLOPersonViewController ()

@end

@implementation TGLOPersonViewController

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
    self.title = @"Person";
    
    self.scrollView.contentSize =CGSizeMake(320, 800);
    
    //get the person object passed through from segue
    self.firstName.text = @"firstName";
    self.lastName.text = @"lastName";
    self.supportLevel.text = @"3";
    self.email.text = @"email";
    self.phone.text = @"phone";
    self.mobile.text = @"mobile";
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
