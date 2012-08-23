//
//  MFMJsonFetcher.m
//  Moe FM
//
//  Created by Greg Wang on 12-7-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MFMDataFetcher.h"
#import "MFMOAuth.h"
#import "MFMNetworkManager.h"

@interface MFMDataFetcher ()

@property (retain, nonatomic) NSURLRequest *request;
@property (retain, nonatomic) GTMHTTPFetcher *fetcher;
@property (assign, nonatomic) NSInteger type;
@property (assign, nonatomic) id <MFMDataFetcherDelegate> delegate;

@property (assign, nonatomic) BOOL didFinish;

@end

@implementation MFMDataFetcher

@synthesize request = _request;
@synthesize fetcher = _fetcher;
@synthesize type = _type;
@synthesize delegate = _delegate;

@synthesize didFinish = _didFinish;

- (BOOL)isFetching
{
	if (self.fetcher == nil) {
		return NO;
	}
	return self.fetcher.isFetching;
}

- (MFMDataFetcher *)initWithURL:(NSURL *)url dataType:(MFMDataType)type
{
	self = [super init];
	if (self) {
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
		// If signed in, sign the request with OAuth
		BOOL authorized = [[MFMOAuth sharedOAuth] authorizeRequest:request];
		if (!authorized) {
			NSLog(@"Not authorized");
		}
		
		self.request = request;
		self.fetcher = nil;
		self.type = type;
		self.delegate = nil;
		self.didFinish = NO;
	}
	return self;
}

- (void)beginFetchWithDelegate:(id <MFMDataFetcherDelegate>)delegate
{
	@synchronized(self) {
		if ([self isFetching]) {
			return;
		}
		
		self.delegate = delegate;
		if ([MFMNetworkManager sharedNetworkManager].allowConnection == NO) {
			NSError *error = [NSError errorWithDomain:NSPOSIXErrorDomain code:ENETUNREACH userInfo:nil];
			[self handelError:error];
			return;
		}
		
		self.fetcher = [GTMHTTPFetcher fetcherWithRequest:self.request];

		switch (self.type) {
			case MFMDataTypeImage:
				[self.fetcher beginFetchWithDelegate:self didFinishSelector:@selector(imageFetcher:finishedWithData:error:)];
				break;
			case MFMDataTypeJson:
			default:
				[self.fetcher beginFetchWithDelegate:self didFinishSelector:@selector(jsonFetcher:finishedWithData:error:)];
				break;
		}
	}
}

- (void)stop
{
	@synchronized(self) {
		self.delegate = nil;
		[self.fetcher stopFetching];
	}
}

- (void)handelError:(NSError *)error
{
    NSLog(@"Fetching failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
	
	if (self.delegate && [self.delegate respondsToSelector:@selector(fetcher:didFinishWithError:)]) {
		// inform the user
		[self.delegate fetcher:self didFinishWithError:error];
	}
	self.delegate = nil;
}

- (void)jsonFetcher:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)data error:(NSError *)error
{
	NSLog(@"Succeeded! Received %d bytes of data",[data length]);
	
	if (error == nil) {
		NSDictionary* json = [NSJSONSerialization 
							  JSONObjectWithData:data
							  options:kNilOptions 
							  error:&error];
		
		if (error != nil) {
			[self handelError:error];
		}
		else if (self.delegate &&
				 [self.delegate respondsToSelector:@selector(fetcher:didFinishWithJson:)]) {
			[self.delegate fetcher:self didFinishWithJson:json];
		}
	}
	else {
		[self handelError:error];
	}
	
	self.delegate = nil;
	self.didFinish = YES;
	
	return;
}

- (void)imageFetcher:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)data error:(NSError *)error
{
	NSLog(@"Succeeded! Received %d bytes of data",[data length]);
	
	if (error == nil) {
		if (self.delegate &&
			[self.delegate respondsToSelector:@selector(fetcher:didFinishWithImage:)]) {
			UIImage *image = [UIImage imageWithData:data];
			[self.delegate fetcher:self didFinishWithImage:image];
		}
	}
	else {
		[self handelError:error];
	}
	
	self.delegate = nil;
	self.didFinish = YES;
	
	return;
}

@end
