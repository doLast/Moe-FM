//
//  MoeFmAPI.h
//  Moe FM
//
//  Created by Greg Wang on 12-4-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MoeFmAPI : NSObject

- (MoeFmAPI *) initWithApiKey:(NSString *)apiKey;

- (NSArray *)getListenPlaylistWithPage:(NSInteger)page;
- (NSArray *)getListenPlaylistWithFav:(NSString *)fav 
								 page:(NSInteger)page;
- (NSArray *)getListenPlaylistWithMusic:(NSString *)music 
								   song:(NSString *)song
								  radio:(NSString *)radio 
								   page:(NSInteger)page;



@end
