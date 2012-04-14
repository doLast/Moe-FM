//
//  MoeFmAPI.h
//  Moe FM
//
//  Created by Greg Wang on 12-4-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MoeFmAPI;

@protocol MoeFmAPIDelegate

@optional
- (void)api:(MoeFmAPI *)api readyWithJson:(NSDictionary *)data;
- (void)api:(MoeFmAPI *)api readyWithPlaylist:(NSArray *)playlist;
- (void)api:(MoeFmAPI *)api readyWithImage:(UIImage *)image;
- (void)api:(MoeFmAPI *)api requestFailedWithError:(NSError *)error;
- (void)api:(MoeFmAPI *)api needNetworkAccess:(BOOL)allow;

@end


@interface MoeFmAPI : NSObject <NSURLConnectionDelegate>

@property (assign, nonatomic, readonly)BOOL isBusy;
@property (assign, nonatomic) BOOL allowNetworkAccess;

- (MoeFmAPI *) initWithApiKey:(NSString *)apiKey 
					 delegate:(NSObject <MoeFmAPIDelegate> *)delegate;

- (BOOL)requestJsonWithURL:(NSURL *)url;
- (BOOL)requestImageWithURL:(NSURL *)url;

- (BOOL)requestListenPlaylistWithPage:(NSInteger)page;
- (BOOL)requestListenPlaylistWithFav:(NSString *)fav 
								page:(NSInteger)page;
- (BOOL)requestListenPlaylistWithMusic:(NSString *)music 
								  song:(NSString *)song
								 radio:(NSString *)radio 
								  page:(NSInteger)page;

- (void)cancelRequest;

@end
