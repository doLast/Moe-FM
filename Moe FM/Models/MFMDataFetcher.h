//
//  MFMJsonFetcher.h
//  Moe FM
//
//  Created by Greg Wang on 12-7-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GTMHTTPFetcher.h"


typedef enum {
	MFMDataTypeImage = 0,
	MFMDataTypeJson, 
} MFMDataType;

@class MFMDataFetcher;

@protocol MFMDataFetcherDelegate <NSObject>

@optional
- (void)fetcher:(MFMDataFetcher *)dataFetcher didFinishWithJson:(NSDictionary *)json;
- (void)fetcher:(MFMDataFetcher *)dataFetcher didFinishWithImage:(UIImage *)image;
- (void)fetcher:(MFMDataFetcher *)dataFetcher didFinishWithError:(NSError *)error;

@end

@interface MFMDataFetcher : NSObject

@property (readonly, assign, nonatomic) BOOL didFinish;
@property (readonly, nonatomic) BOOL isFetching;

- (MFMDataFetcher *)initWithURL:(NSURL *)url dataType:(MFMDataType)type;
- (void)beginFetchWithDelegate:(id <MFMDataFetcherDelegate>)delegate;
- (void)stop;

@end
