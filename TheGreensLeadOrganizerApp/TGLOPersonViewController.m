//
//  TGLOPersonViewController.m
//  TheGreensLeadOrganizerApp
//
//  Created by andre on 9/04/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import "TGLOPersonViewController.h"


@interface TGLOPersonViewController ()
@property (nonatomic, strong) UIAlertView *tokenAlert;

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
        
      NSLog(@"button contentEdgeInsets: %@", [self.mobile contentEdgeInsets]);
        
      NSLog(@"button type: %d", [self.mobile buttonType ]);
    }
    
    
}

-(void)makeCall:(id)sender
{

    //NSString *number = [[NSString alloc] initWithFormat:"%@", (UITextField *)sender.labelText.text];
    NSLog(@"makeCall method called, sender is: %@", sender);
    NSString *title = [((UIButton *) sender) currentTitle];
    NSLog(@"currentTitle: %@", title);
    
    NSArray *title_split =  [title componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" -+()"]];
    
    NSString *title_cleaned= [title_split componentsJoinedByString:@""];
    NSLog(@"title_split: %@", title_split);
    NSLog(@"title_joined: %@", title_cleaned);
    
    NSString *theCall = [NSString stringWithFormat:@"telprompt://%@", title_cleaned];
    NSLog(@"theCall: %@", theCall);
    UIApplication *myApp = [UIApplication sharedApplication];
    
    NSURL *theCallUrl = [NSURL URLWithString:theCall];
    
    //check to see if the app can make calls before making the call
    if ([myApp canOpenURL:theCallUrl]) {
        NSLog(@"this app can open the url %@", theCallUrl);
       [myApp openURL:theCallUrl];
    } else {
        NSLog(@"ERROR: this app can NOT open the url: %@", theCallUrl);
        
        NSString *message = @"This device cannot make call. Try to find a phone booth.";
        
        // show alert view saying we are getting token
        _tokenAlert = [[UIAlertView alloc] initWithTitle:@"Whoopsies"
                                                 message:message
                                                delegate:nil
                                       cancelButtonTitle:@"Cancel"
                                       otherButtonTitles:nil];
        [_tokenAlert show];
    }
}

- (IBAction)writeEmail:(id)sender
{
    NSLog(@"writeEmail method called, sender is: %@", sender);
    NSString *title = [((UIButton *) sender) currentTitle];
    NSLog(@"currentTitle: %@", title);
    
    NSString *theEmail = [NSString stringWithFormat:@"mailTo://%@", title];
    NSLog(@"theEmail: %@", theEmail);
    UIApplication *myApp = [UIApplication sharedApplication];
    
    NSURL *theEmailUrl = [NSURL URLWithString:theEmail];
    
    //check to see if the app can make calls before making the call
    if ([myApp canOpenURL:theEmailUrl]) {
        NSLog(@"this app can open the url %@", theEmailUrl);
       [myApp openURL:theEmailUrl];
    } else {
        NSLog(@"ERROR: this app can NOT open the url: %@", theEmailUrl);
        
        NSString *message = @"This device cannot send emails. Go find an internet cafe.";
        
        // show alert view saying we are getting token
        _tokenAlert = [[UIAlertView alloc] initWithTitle:@"Whoopsies"
                                                 message:message
                                                delegate:nil
                                       cancelButtonTitle:@"Cancel"
                                       otherButtonTitles:nil];
        [_tokenAlert show];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
