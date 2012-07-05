//
//  MoufouResouce.h
//  Moe FM
//
//  Created by Greg Wang on 12-7-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MFMDataFetcher.h"

extern NSString * const MoefouResourceNotification;

@interface MoefouResource : NSObject <MFMDataFetcherDelegate>

@property (readonly, retain, nonatomic) NSDictionary *resouce;
@property (readonly, retain, nonatomic) NSError *error;

- (MoefouResource *) initWithURL:(NSURL *)url;

@end
