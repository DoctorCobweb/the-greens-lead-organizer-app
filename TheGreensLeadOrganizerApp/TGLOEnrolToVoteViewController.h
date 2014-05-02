//
//  TGLOEnrolToVoteViewController.h
//  TheGreensLeadOrganizerApp
//
//  Created by andre on 9/04/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TGLOEnrolToVoteViewController : UIViewController<UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
