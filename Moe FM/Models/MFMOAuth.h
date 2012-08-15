//
//  MFMOAuth.h
//  Moe FM
//
//  Created by Greg Wang on 12-8-15.
//
//

#import <Foundation/Foundation.h>

@interface MFMOAuth : NSObject

@property (readonly) BOOL canAuthorize;

+ (MFMOAuth *)sharedOAuth;
- (void)signInWithNavigationController:(UINavigationController *)controller;
- (BOOL)authorizeRequest:(NSMutableURLRequest *)urlRequest;
- (void)signOut;

@end
