
#import "OAuthLoginViewController.h"
#import "NationBuilder.h"

@interface OAuthLoginViewController ()
@property (weak, nonatomic) IBOutlet UITextView *loginView;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (nonatomic, strong) UIAlertView *tokenAlert;

@end

@implementation OAuthLoginViewController


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
}


- (IBAction)signIn:(id)sender
{
    
    // show alert view saying we are getting token
    _tokenAlert = [[UIAlertView alloc] initWithTitle:@"Getting token"
                                                            message:@"Logging into Nation Builder"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:nil];
    [_tokenAlert show];

    [self getOAuthRequestToken];
}

# pragma mark - OAUTH 2 STEP 1
-(void)getOAuthRequestToken
{
    // OAUTH Step 1. Get request token. need this to to access token later
    [NationBuilder requestTokenWithCompletionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            
            NSLog(@"in getOAuthRequestToken method");
            NSLog(@"%@", response);
            NSLog(@"%@", [response URL]);
            NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
            if (httpResp.statusCode == 200) {
                
                
                /*
                 oauth_token The request token that was just authorized. The request token secret isn't sent back.
                 If the user chooses not to authorize the application,
                 they will get redirected to the oauth_callback URL with the additional URL query parameter not_approved=true.
                 */
                
                
                [_tokenAlert dismissWithClickedButtonIndex:0 animated:NO];
                
                //NSString * authorize_url = @"https://agtest.nationbuilder.com/oauth/authorize?response_type=code&client_id=ecc44472c84d126f006ccad6485f5dc127ae1400f0f937cf0167a60a12cfabc6&redirect_uri=https://cryptic-tundra-9564.herokuapp.com/oauth2callback";
                
                NSString * authorize_url = [NationBuilder constructNationBuilderAuthorizeUri];
                
                //opens to user auth page in safari
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:authorize_url]];

            } else {
                // HANDLE BAD RESPONSE //
                NSLog(@"unexpected response getting token %@",[NSHTTPURLResponse localizedStringForStatusCode:httpResp.statusCode]);
            }
        } else {
            // ALWAYS HANDLE ERRORS :-] //
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end