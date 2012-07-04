//
//  MFMJsonFetcher.m
//  Moe FM
//
//  Created by Greg Wang on 12-7-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MFMDataFetcher.h"

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
	return self.fetcher.isFetching;
}

- (MFMDataFetcher *)initWithURL:(NSURL *)url dataType:(NSInteger)type
{
	self = [super init];
	if (self) {
		self.request = [NSURLRequest requestWithURL:url];
		// If signned in, sign the request with OAuth
		
		self.type = type;
		self.didFinish = NO;
	}
	return self;
}

- (void)beginFetchWithDelegate:(id <MFMDataFetcherDelegate>)delegate
{
	@synchronized(self) {
		self.delegate = delegate;
		
		self.fetcher = [GTMHTTPFetcher fetcherWithRequest:self.request];

		switch (self.type) {
			case kMFMDataFetcherImage:
				[self.fetcher beginFetchWithDelegate:self didFinishSelector:@selector(imageFetcher:finishedWithData:error:)];
				NSLog(@"Fetcher begin %d", self.fetcher.isFetching);
				break;
			case kMFMDataFetcherJson:
			default:
				[self.fetcher beginFetchWithDelegate:self didFinishSelector:@selector(jsonFetcher:finishedWithData:error:)];
				NSLog(@"Fetcher begin %d", self.fetcher.isFetching);
				break;
		}
		
		
	}
}

- (void)stop
{
	@synchronized(self) {
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
}

- (void)jsonFetcher:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)data error:(NSError *)error
{
	NSLog(@"Succeeded! Received %d bytes of data",[data length]);
	
	if (error == nil && 
		self.delegate && 
		[self.delegate respondsToSelector:@selector(fetcher:didFinishWithJson:)]) {
		
		NSDictionary* json = [NSJSONSerialization 
							  JSONObjectWithData:data
							  options:kNilOptions 
							  error:&error];
		
		if (error != nil) {
			[self handelError:error];
		}
		
		[self.delegate fetcher:self didFinishWithJson:json];
	}
	else {
		[self handelError:error];
	}
	
	self.didFinish = YES;
	
	return;
}

- (void)imageFetcher:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)data error:(NSError *)error
{
	NSLog(@"Succeeded! Received %d bytes of data",[data length]);
	
	if (error == nil && 
		self.delegate && 
		[self.delegate respondsToSelector:@selector(fetcher:didFinishWithJson:)]) {
		
		UIImage *image = [UIImage imageWithData:data];
		
		[self.delegate fetcher:self didFinishWithImage:image];
	}
	else {
		[self handelError:error];
	}
	
	self.didFinish = YES;
	
	return;
}

@end
