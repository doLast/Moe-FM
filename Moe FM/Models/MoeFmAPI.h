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

@end

@interface MoeFmAPI : NSObject <NSURLConnectionDelegate>

- (MoeFmAPI *) initWithApiKey:(NSString *)apiKey 
					 delegate:(NSObject <MoeFmAPIDelegate> *)delegate;

- (BOOL)requestListenPlaylistWithPage:(NSInteger)page;
- (BOOL)requestListenPlaylistWithFav:(NSString *)fav 
								page:(NSInteger)page;
- (BOOL)requestListenPlaylistWithMusic:(NSString *)music 
								  song:(NSString *)song
								 radio:(NSString *)radio 
								  page:(NSInteger)page;

- (BOOL)requestJsonWithURL:(NSURL *)url;
- (BOOL)requestImageWithURL:(NSURL *)url;



@end
