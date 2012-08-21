//
//  MoufouResouce.m
//  Moe FM
//
//  Created by Greg Wang on 12-7-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MFMResource.h"
#import "MFMDataFetcher.h"

const NSString * const MFMResourceObjTypeStr[] =
{@"tv", @"ova", @"oad", @"movie", @"anime", @"comic", @"music", @"radio",  @"wiki", @"ep", @"song", @"sub"};
NSString * const MFMResourceNotification = @"MFMResourceNotification";
NSString * const MFMAPIFormat = @"json";
NSString * const kApiKey = @"302182858672af62ebf4524ee8d9a06304f7db527";

@interface MFMResource () <MFMDataFetcherDelegate>

@property (retain, nonatomic) NSDictionary *response;
@property (retain, nonatomic) NSError *error;
@property (retain, nonatomic) MFMDataFetcher *fetcher;

- (BOOL)prepareTheResource:(NSDictionary *)resource;

@end

@implementation MFMResource

@synthesize response = _response;
@synthesize error = _error;
@synthesize fetcher = _fetcher;

- (MFMResource *)initWithResouce:(NSDictionary *)resource
{
	self = [super init];
	if (self != nil) {
		self.response = resource;
		[self prepareTheResource:self.response];
		self.fetcher = nil;
	}
	return self;
}

- (BOOL)startFetchWithURL:(NSURL *)url
{
	if (self.fetcher != nil){
		return YES;
	}
	
	NSLog(@"Resource start fetching URL: %@", url);
	self.fetcher = [[MFMDataFetcher alloc] initWithURL:url dataType:MFMDataTypeJson];
	[self.fetcher beginFetchWithDelegate:self];
	
	return YES;
}

- (void)stopFetch
{
	if (self.fetcher != nil) {
		MFMDataFetcher *oldFetcher = self.fetcher;
		self.fetcher = nil;
		[oldFetcher stop];
	}
}

# pragma mark - class helpers

+ (NSURL *)urlWithPrefix:(NSString *)urlPrefix parameters:(NSDictionary *)parameters
{
	NSMutableString *urlStr = [urlPrefix mutableCopy];
	for (NSString *key in parameters.keyEnumerator) {
		[urlStr appendFormat:@"%@=%@&", key, [parameters objectForKey:key]];
	}
	[urlStr appendFormat:@"api_key=%@", kApiKey];
	
	NSURL *url = [NSURL URLWithString:urlStr];
	return url;
}

# pragma mark - Override NSObject Methods

- (NSString *)description
{
	return self.response.description;
}

# pragma mark - MFMDataFetcherDelegate

- (void)fetcher:(MFMDataFetcher *)dataFetcher didFinishWithJson:(NSDictionary *)json
{
	self.response = [json objectForKey:@"response"];
	if (self.response == nil || [self prepareTheResource:self.response] == NO) {
		return [self fetcher:dataFetcher didFinishWithError:nil];
	}
	self.fetcher = nil;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:MFMResourceNotification object:self];
}

- (void)fetcher:(MFMDataFetcher *)dataFetcher didFinishWithError:(NSError *)error
{
	self.error = error;
	self.fetcher = nil;
	[[NSNotificationCenter defaultCenter] postNotificationName:MFMResourceNotification object:self];
}

# pragma mark - subclass specified action

- (BOOL)prepareTheResource:(NSDictionary *)resource
{
	return NO; // do nil
}

@end
