//
//  TGLOAppDelegate.m
//  TheGreensLeadOrganizerApp
//
//  Created by andre on 8/04/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import "TGLOAppDelegate.h"
#import "NationBuilder.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "TGLOAccountLoginViewController.h"
#import "SWRevealViewController.h"


//app wide identifier used to construct urls for api calls
//stored in UserDefaults object
NSString * const nationBuilderSlugKey = @"nationBuilderSlug";
NSString * const nationBuilderSlugValue = @"agv";


@implementation TGLOAppDelegate
{
    NSUserDefaults *userDefaults;
}

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //enable afnetworking to show spinner in top bar
    [self initAppearance];
    
    //testing extern variable stuff
    NSLog(@"EXTERN: nationBuilderRequestToken: %@", nationBuilderRequestToken);
    NSLog(@"EXTERN: nationBuilderAccessToken: %@", nationBuilderAccessToken);
   
    
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    // Override point for customization after application launch.
    
    userDefaults = [NSUserDefaults standardUserDefaults];
    

    NSString *token = [userDefaults valueForKey:@"access_token"];
    NSLog(@"APP DELEGATE didFinishLaunchingWithOptions");
    
    //NSString *controllerId = token ? @"signedIn" : @"login";
    NSString *controllerId = token ? @"signedIn" : @"accountLogin";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *initViewController = [storyboard instantiateViewControllerWithIdentifier:controllerId];
    
    
    // always assumes token is valid - should probably check in a real app
    if (token) {
        //SWRevealViewController will be rootViewController
        [self.window setRootViewController:initViewController];
    } else {
        //UINavigationController will be rootViewController
        [(UINavigationController *)self.window.rootViewController pushViewController:initViewController animated:NO];
        
        [((UINavigationController *)[initViewController navigationController]).navigationBar setHidden:YES];
    }
    
    return YES;
}

- (void)initAppearance
{
    UIColor * theGreens = [UIColor colorWithRed:129/255.0f green:183/255.0f blue:87/255.0f alpha:1.0f];
    // Set appearance info
    [[UITabBar appearance] setBarTintColor:theGreens];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlackOpaque];
    [[UINavigationBar appearance] setBarTintColor:theGreens];
    
    [[UIToolbar appearance] setBarStyle:UIBarStyleBlackOpaque];
    [[UIToolbar appearance] setBarTintColor:theGreens];
    
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    NSLog(@"APP DELEGATE, applicationWillResignActive:");
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"APP DELEGATE, applicationDidEnterBackground:");
    NSLog(@"self.window.rootViewController: %@", self.window.rootViewController);
    
    //if access_token is null it means user has idicated they want
    //to log out OR have not yet logged in.
    //need to handle both scenarios
    if (![userDefaults valueForKey:@"access_token"]) {
        //this gets rid off all view controllers except to the first
        //one which should be of class TGLOAccountLoginViewController
        
        //1. user has already been logged in and has logged out then
        // clicked home button to get out of app
        //replace root view controller with a uinav controller to
        //reset the app to open with login screen
        if ([self.window.rootViewController class] == [SWRevealViewController class]) {
            NSLog(@"SWRevealViewController is rootViewController");
            NSLog(@"=> we need to replace it with a NavCont...");

            //got to get back to accountLoginViewController
            //1. make root be uinavigationcontroller
            //2. create accountLoginViewController the push to stack
            self.window.rootViewController = [[UINavigationController alloc] init];
            // now load login view controller, thus resetting nav
            //stack
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *segueId = @"accountLogin";
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                UIViewController *initViewController = [storyboard instantiateViewControllerWithIdentifier:segueId];
                UINavigationController *nav = (UINavigationController *) self.window.rootViewController;
                
                nav.navigationBar.hidden = YES;
                [nav pushViewController:initViewController animated:YES];
            });
                
            return;
        }
        
        //if user has NOT yet logged in (=> token is nil)
        //and closed app then UINavigationController is root
        //=> DONT need to reset any contollers/roots
        if ([self.window.rootViewController class] == [UINavigationController class]) {
            NSLog(@"UINavigationController is rootViewController");
            
            return;
        }
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    //Called as part of the transition from the background to the
    //inactive state; here you can undo many of the changes made on
    //entering the background.
    NSLog(@"applicationWillEnterForeground:");
    //UINavigationController *naver = (UINavigationController *)self.window.rootViewController;
    NSLog(@"APP DELEGATEIE willEnterForeground=> rootViewC: %@", self.window.rootViewController);
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"applicationDidBecomeActive:");
    //UINavigationController *naver = (UINavigationController *)self.window.rootViewController;
    NSLog(@"APP DELEGATEIE didBecomeActive=> rootViewC: %@", self.window.rootViewController);
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    NSLog(@"in applicationWillTerminate");
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"TheGreensLeadOrganizerApp" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"TheGreensLeadOrganizerApp.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}





#pragma mark - OAuth login flow and url scheme handling
// this method is invoked as a result of the heroku hosted 'cryptic-tundra-9564'
// app redirecting backing this app, all inside the mobile safari browser.
// had to use an external heroku app in order to get the code=... vale returned from
// nationbuilder to a VALIDE redirect_uri. i.e. nation builder does not allow for
// redirect_uris other than https for the uri scheme! => cannot use leadorganizerapp as
// scheme directly during oauth2 but instead need a hack like this redirect heroku app!
-(BOOL)application:(UIApplication *)application
           openURL:(NSURL *)url
 sourceApplication:(NSString *)sourceApplication
        annotation:(id)annotation
{
    NSLog(@"IN APP DELEGATE AND CHECKING SCHEME");
    if ([[url scheme] isEqualToString:@"leadorganizerapp"]) {
        NSLog(@"sourceApplication: %@", sourceApplication);
        NSLog(@"annotation: %@", annotation);
        //NSLog(@"url: %@", url);
        
        //need to put code=.... value into UserDefaults for later OAuth2 process
        NSString * queryString = [url query];
        //NSLog(@"query string of url: %@", queryString);
        
        NSArray *tokens = [queryString componentsSeparatedByString:@"&"];
        NSLog(@"%@", tokens);
        NSMutableDictionary *oAuth2Dict = [[NSMutableDictionary alloc] initWithCapacity:5];
        
        for(NSString *t in tokens) {
            NSArray *entry = [t componentsSeparatedByString:@"="];
            NSString *key = entry[0];
            NSString *val = entry[1];
            [oAuth2Dict setValue:val forKey:key];
        }
        
        NSDictionary * params = [NSDictionary dictionaryWithDictionary:oAuth2Dict];
        //NSLog(@"params dic: %@", params);
        
        //put code key/val into UserDefaults obj
        [userDefaults setObject:oAuth2Dict[@"code"] forKey:@"code"];
        [userDefaults synchronize];
        
        [self exchangeRequestTokenForAccessToken];
    }
    return NO;
}

- (void)exchangeRequestTokenForAccessToken
{
    // OAUTH Step 2 - exchange request token for user access token
    [NationBuilder exchangeTokenForUserAccessTokenURLWithCompletionHandler:^(NSData *data,NSURLResponse *response,NSError *error) {
        if (!error) {
            NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
            
            //NSLog(@"token response: %@", httpResp);
            if (httpResp.statusCode == 200) {
                NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                
                NSError *error;
                NSDictionary *dict_resp = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:NSUTF8StringEncoding error:&error];
                //NSLog(@"dict_resp[access_token]: %@",[dict_resp objectForKey:@"access_token"]);
                
                //response is JSON format
                //NSLog(@"response: %@",response);
                
                
                //put code key/val into UserDefaults obj
                [userDefaults setObject:dict_resp[@"access_token"] forKey:@"access_token"];
                [userDefaults synchronize];
                
                NSString *token = [userDefaults valueForKey:@"access_token"];
                //NSLog(@"TOKEN FROM UserDefaults: %@", token);
                
                // now load main part of application
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    
                    NSString *segueId = @"signedIn";
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    UIViewController *initViewController = [storyboard instantiateViewControllerWithIdentifier:segueId];
                    
                    UINavigationController *nav = (UINavigationController *) self.window.rootViewController;
                    nav.navigationBar.hidden = NO;
                    [nav pushViewController:initViewController animated:NO];
                });
                
            } else {
                // HANDLE BAD RESPONSE //
                NSLog(@"exchange request for access token unexpected response %@",
                      [NSHTTPURLResponse localizedStringForStatusCode:httpResp.statusCode]);
            }
        } else {
            // ALWAYS HANDLE ERRORS :-] //
            NSLog(@"ERROR in app delegate.m exchangeRequestTokenForAccessToken method");
        }
    }];
}


@end
