//
//  MoufouResouce.m
//  Moe FM
//
//  Created by Greg Wang on 12-7-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MFMResource.h"

//const NSString * const MFMRresourceKeyStr[] = 
//{@"wiki", @"sub", @"user", @"fav"};
NSString * const MFMAPIFormat = @"json";

NSString * const MFMResourceNotification = @"MFMResourceNotification";

@interface MFMResource ()

@property (retain, nonatomic) NSDictionary *response;
@property (retain, nonatomic) NSError *error;
@property (retain, nonatomic) MFMDataFetcher *fetcher;

- (BOOL)prepareTheResource:(NSDictionary *)resource;

@end

@implementation MFMResource

@synthesize response = _response;
@synthesize error = _error;
@synthesize fetcher = _fetcher;

- (MFMResource *)initWithURL:(NSURL *)url
{
	return [self initWithURL:url andStartFetch:NO];
}

- (MFMResource *)initWithURL:(NSURL *)url andStartFetch:(BOOL)inst
{
	self = [super init];
	if (self != nil) {
		self.response = nil;
		self.fetcher = [[MFMDataFetcher alloc] initWithURL:url dataType:MFMDataTypeJson];
		if (inst && ![self startFetch]) {
			NSLog(@"Fail to start fetcher");
		}
		NSLog(@"Resource created with url %@", url);
	}
	return self;
}

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

- (BOOL)startFetch
{
	[self.fetcher beginFetchWithDelegate:self];
	return self.fetcher != nil;
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
	
	[[NSNotificationCenter defaultCenter] postNotificationName:MFMResourceNotification object:self];
}

- (void)fetcher:(MFMDataFetcher *)dataFetcher didFinishWithError:(NSError *)error
{
	self.error = error;
	[[NSNotificationCenter defaultCenter] postNotificationName:MFMResourceNotification object:self];
}

# pragma mark - subclass specified action

- (BOOL)prepareTheResource:(NSDictionary *)resource
{
	return NO; // do nil
}

@end
