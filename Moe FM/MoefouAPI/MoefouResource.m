//
//  MoufouResouce.m
//  Moe FM
//
//  Created by Greg Wang on 12-7-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MoefouResource.h"

NSString * const MoefouResourceNotification = @"MoefouResourceNotification";

@interface MoefouResource ()

@property (retain, nonatomic) NSDictionary *resouce;
@property (retain, nonatomic) NSError *error;
@property (retain, nonatomic) MFMDataFetcher *fetcher;
//@property (assign, nonatomic) dispatch_semaphore_t sema;

@end

@implementation MoefouResource

@synthesize resouce = _resouce;
@synthesize error = _error;
@synthesize fetcher = _fetcher;
//@synthesize sema = _sema;

- (MoefouResource *)initWithURL:(NSURL *)url
{
	self = [super init];
	if (self != nil) {
		self.resouce = nil;
//		self.sema = dispatch_semaphore_create(0);
		self.fetcher = [[MFMDataFetcher alloc] initWithURL:url dataType:kMFMDataJson];
		[self.fetcher beginFetchWithDelegate:self];
	}
	return self;
}

# pragma mark - MFMDataFetcherDelegate

- (void)fetcher:(MFMDataFetcher *)dataFetcher didFinishWithJson:(NSDictionary *)json
{
	self.resouce = [json objectForKey:@"response"];
//	dispatch_semaphore_signal(self.sema);
	[[NSNotificationCenter defaultCenter] postNotificationName:MoefouResourceNotification object:self];
}

- (void)fetcher:(MFMDataFetcher *)dataFetcher didFinishWithError:(NSError *)error
{
	self.error = error;
//	dispatch_semaphore_signal(self.sema);
	[[NSNotificationCenter defaultCenter] postNotificationName:MoefouResourceNotification object:self];
}

@end
