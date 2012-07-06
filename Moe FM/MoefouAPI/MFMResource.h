//
//  MoufouResouce.h
//  Moe FM
//
//  Created by Greg Wang on 12-7-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MFMDataFetcher.h"

//typedef enum {
//	MFMResourceKeyWiki = 0, 
//	MFMResourceKeySub, 
//	MFMResourceKeyUser, 
//	MFMResourceKeyFav
//} MFMResourceKey;
//extern const NSString * const MFMRresourceKeyStr[];
extern NSString * const MFMAPIFormat;

extern NSString * const MFMResourceNotification;

@class MFMResourcePlaylist;

@protocol MFMResourceSubsInterface <NSObject>
@property (readonly, nonatomic) NSArray *resourceSubs;
@property (readonly, nonatomic) MFMResourcePlaylist *playlist;
@end

@protocol MFMResourceWikisInterface <NSObject>
@property (readonly, nonatomic) NSArray *resourceWikis;
@property (readonly, nonatomic) MFMResourcePlaylist *playlist;
@end

@interface MFMResource : NSObject <MFMDataFetcherDelegate>

@property (readonly, retain, nonatomic) NSDictionary *response;
@property (readonly, retain, nonatomic) NSError *error;

- (MFMResource *)initWithURL:(NSURL *)url;
- (MFMResource *)initWithURL:(NSURL *)url andStartFetch:(BOOL)inst;
- (MFMResource *)initWithResouce:(NSDictionary *)resource;
- (BOOL)startFetch;
- (void)stopFetch;
+ (NSURL *)urlWithPrefix:(NSString *)urlPrefix parameters:(NSDictionary *)parameters;

@end
