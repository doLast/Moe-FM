//
//  MoufouResouce.h
//  Moe FM
//
//  Created by Greg Wang on 12-7-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MFMDataFetcher.h"

typedef enum {
	MFMResourceObjTypeTv = 0,
	MFMResourceObjTypeOva,
	MFMResourceObjTypeOad,
	MFMResourceObjTypeMovie,
	MFMResourceObjTypeAnime,
	MFMResourceObjTypeComic,
	MFMResourceObjTypeMusic,
	MFMResourceObjTypeRadio,
	MFMResourceObjTypeWiki,
	MFMResourceObjTypeEp,
	MFMResourceObjTypeSong,
	MFMResourceObjTypeSub,
	MFMResourceObjTypeTotal
} MFMResourceObjType;
extern const NSString * const MFMResourceObjTypeStr[];

extern NSString * const MFMResourceNotification;
extern NSString * const MFMAPIFormat;

@interface MFMResource : NSObject <MFMDataFetcherDelegate>

@property (readonly, retain, nonatomic) NSError *error;

- (MFMResource *)initWithResouce:(NSDictionary *)resource;
- (BOOL)startFetchWithURL:(NSURL *)url andDataType:(MFMDataType)dataType;
- (void)stopFetch;
+ (NSURL *)urlWithPrefix:(NSString *)urlPrefix parameters:(NSDictionary *)parameters;

@end
