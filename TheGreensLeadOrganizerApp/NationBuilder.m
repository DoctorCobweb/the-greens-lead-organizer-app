//
//  NationBuilder.m
//  ByteClub
//
//  Created by andre on 30/03/2014.
//  Copyright (c) 2014 Razeware. All rights reserved.
//

#import "NationBuilder.h"
#import "AFNetworking.h"

// NATION BUILDER API KEY and SECRET HERE
static NSString * nationBuilderClientID = @"ecc44472c84d126f006ccad6485f5dc127ae1400f0f937cf0167a60a12cfabc6";
static NSString * nationBuilderClientSecret = @"5faca3b8f58b91696f07fc499b5674f6d12de149a0d6e9616aae42fba387701f";
static NSString * nationBuilderRedirectUri= @"https://cryptic-tundra-9564.herokuapp.com/oauth2callback";
static NSString * nationBuilderGrantType = @"authorization_code";
static NSString * nationBuilderCode = @"code";
static NSString * nationBuilderAuthorizeUri = @"https://%@.nationbuilder.com/oauth/authorize?response_type=code&client_id=%@&redirect_uri=%@";
static NSString * nationBuilderTokenUri = @"https://%@.nationbuilder.com/oauth/token";
static NSString *nationBuilderSlugKey = @"nationBuilderSlug";


#pragma mark - saved in NSUserDefaults
NSString * const nationBuilderRequestToken = @"nation_builder_request_token";
NSString * const nationBuilderAccessToken = @"nation_builder_access_token";





@implementation NationBuilder
{
    
}

+(NSString *)constructNationBuilderAuthorizeUri
{
    NSString *nationBuilderSlug = [[NSUserDefaults standardUserDefaults] objectForKey:nationBuilderSlugKey];
    
    if (!nationBuilderSlug) {
        NSLog(@"ERROR: nationBuilderSlug NOT set in user defaults");
    
        return @"ERROR: nationBuilderSlug NOT set";
    } else {
       
        NSString *authorize_string = [[NSString alloc] initWithFormat:nationBuilderAuthorizeUri, nationBuilderSlug, nationBuilderClientID, nationBuilderRedirectUri];
        
        return authorize_string;
    }
}


+(void)requestTokenWithCompletionHandler:(NationBuilderRequestTokenCompletionHandler)completionBlock
{
    NSURLSessionConfiguration *sessionConfig =
    [NSURLSessionConfiguration defaultSessionConfiguration];
    NSLog(@"%@", sessionConfig);
    
    
    NSString * authorize_url = [self constructNationBuilderAuthorizeUri];
    
    NSLog(@"authorize_url: %@", authorize_url);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:authorize_url]];
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
    [[session dataTaskWithRequest:request completionHandler:completionBlock] resume];
    
    
    /*
    //2. HTML: now try to make a request without the 'request manager'. build the url, request and use
    //   AFHTTPRequestOperation class.
    NSString *url_string = @"https://agtest.nationbuilder.com/oauth/authorize";
    AFHTTPRequestSerializer * req_ser = [AFHTTPRequestSerializer serializer];
    NSError * the_error;
    NSMutableDictionary * the_params =[NSMutableDictionary dictionary];
    
    [the_params setObject:@"code" forKey:@"response_type"];
    [the_params setObject:@"ecc44472c84d126f006ccad6485f5dc127ae1400f0f937cf0167a60a12cfabc6" forKey:@"client_id"];
    [the_params setObject:@"https://cryptic-tundra-9564.herokuapp.com/oauth2callback" forKey:@"redirect_uri"];
    
    NSMutableURLRequest * the_req = [req_ser requestWithMethod:@"GET" URLString: url_string parameters:the_params error:&the_error];
    NSLog(@"%@", [the_req allHTTPHeaderFields]);
    
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:the_req];
    
    op.responseSerializer = [AFHTTPResponseSerializer serializer]; //this by default is nil
    op.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    
    NSLog(@"op.responseSerializer.acceptableContentTypes: %@", op.responseSerializer.acceptableContentTypes);
    
    //set the blocks or which are another name for callbacks
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *the_resp = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"FROM WAY 2): TEXT/HTML successful request/response %@", the_resp);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    // start the request/response cycle
    [op start];
     */
    
    
}

+(void)exchangeTokenForUserAccessTokenURLWithCompletionHandler:(NationBuilderRequestTokenCompletionHandler)completionBlock
{
    NSString *nationBuilderSlug = [[NSUserDefaults standardUserDefaults] objectForKey:nationBuilderSlugKey];
    
    //TODO better error handling
    if (!nationBuilderSlug) {
        NSLog(@"ERROR: nation builder slug not set in user defaults");
    }
    
    NSString *tokenUri = [[NSString alloc] initWithFormat:nationBuilderTokenUri, nationBuilderSlug];
    NSURL *requestTokenURL = [NSURL URLWithString:tokenUri];
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:requestTokenURL];
    [request setHTTPMethod:@"POST"];
    
    NSString * code_val = [[NSUserDefaults standardUserDefaults] objectForKey:nationBuilderCode];
    
    if (!code_val) {
        NSLog(@"ERROR: code_val == nil");
        //if code_val is nil, AFNetworking will
        //throw an error later on after response
        //=>dont handle error here
    }
    
    NSString *body_string = [self createTokenRequestBody:code_val];
    NSLog(@"body_string of JSON: %@", body_string);
    
    NSData * body_data = [body_string dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:body_data];
    
    //you have to set these headers in order to get nation builder to accept your req
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    NSLog(@"URL: %@", [request URL]);
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
    [[session dataTaskWithRequest:request completionHandler:completionBlock] resume];
}


+ (NSString *)createTokenRequestBody:(NSString *)code_val
{
    //hard coding JSON!!!!!! for the body
    NSString *body_string = [NSString stringWithFormat:@"{\"%@\":\"%@\",\"%@\":\"%@\",\"%@\":\"%@\",\"%@\":\"%@\",\"%@\":\"%@\"}",@"client_id",nationBuilderClientID, @"redirect_uri", nationBuilderRedirectUri, @"grant_type", nationBuilderGrantType, @"client_secret", nationBuilderClientSecret, @"code", code_val];
    
    return body_string;
}

@end
