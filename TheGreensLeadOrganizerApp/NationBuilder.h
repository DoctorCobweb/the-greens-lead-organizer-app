//
//  NationBuilder.h
//  ByteClub
//
//  Created by andre on 30/03/2014.
//  Copyright (c) 2014 Razeware. All rights reserved.
//

#import <Foundation/Foundation.h>

// OAuth Stuff
extern NSString * const nationBuilderRequestToken;
extern NSString * const nationBuilderAccessToken;

typedef void (^NationBuilderRequestTokenCompletionHandler)(NSData *data, NSURLResponse *response, NSError *error);


@interface NationBuilder : NSObject

+ (void)requestTokenWithCompletionHandler:(NationBuilderRequestTokenCompletionHandler)completionBlock;
+ (void)exchangeTokenForUserAccessTokenURLWithCompletionHandler:(NationBuilderRequestTokenCompletionHandler)completionBlock;

+(NSString *)constructNationBuilderAuthorizeUri;
@end
