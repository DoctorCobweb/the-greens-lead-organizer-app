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
    UIColor * white_color = [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1.0f];
    self.title = @"Person";
    
    self.scrollView.contentSize =CGSizeMake(320, 800);
    
    if(self.person){
      //get the person object passed through from segue
      self.firstName.text = self.person.firstName;
      self.lastName.text = self.person.lastName;
      self.supportLevel.text = [self.person.supportLevel stringValue];
        
      
    
      [self.email setTitle:self.person.email forState:UIControlStateNormal];
      [self.email setTitleColor:white_color forState:UIControlStateNormal];
        
      [self.phone setTitleColor:white_color forState:UIControlStateNormal];
      [self.phone setTitle:self.person.phone forState:UIControlStateNormal];
        
      [self.mobile setTitle:self.person.mobile forState:UIControlStateNormal];
      [self.mobile setTitleColor:white_color forState:UIControlStateNormal];
    }
    
    
}

-(void)makeCall:(id)sender
{

    //NSString *number = [[NSString alloc] initWithFormat:"%@", (UITextField *)sender.labelText.text];
    NSLog(@"makeCall method called, sender is: %@", sender);
}

- (IBAction)writeEmail:(id)sender
{
    NSLog(@"writeEmail method called, sender is: %@", sender);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
