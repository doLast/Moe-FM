//
//  MoeFmAPI.m
//  Moe FM
//
//  Created by Greg Wang on 12-4-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MoeFmAPI.h"

typedef enum
{
	MFMAPI_JSON = 0,
	MFMAPI_PLAYLIST, 
	MFMAPI_IMAGE
} MoeFmAPIRequestType;

NSString * const MoeFmAPIListenPlaylistAddress = @"http://moe.fm/listen/playlist?api=json";


@interface MoeFmAPI ()
@property (assign, nonatomic, readwrite)BOOL isBusy;

@property (assign, nonatomic) NSObject <MoeFmAPIDelegate> *delegate;
@property (retain, nonatomic) NSString *apiKey;
@property (assign, nonatomic) MoeFmAPIRequestType requestType;
@property (retain, nonatomic) NSURLConnection *theConnection;
@property (retain, nonatomic) NSMutableData *receivedData;

- (BOOL)createConnectionWithURL:(NSURL *)url 
					requestType:(MoeFmAPIRequestType)type
				timeoutInterval:(NSTimeInterval)timeout;

@end


@implementation MoeFmAPI

@synthesize isBusy = _isBusy;
@synthesize allowNetworkAccess = _allowNetworkAccess;

@synthesize delegate = _delegate;
@synthesize apiKey = _apiKey;
@synthesize requestType = _requestType;
@synthesize theConnection = _theConnection;
@synthesize receivedData = _receivedData;

- (MoeFmAPI *) initWithApiKey:(NSString *)apiKey delegate:(NSObject <MoeFmAPIDelegate> *)delegate
{
	self = [super init];
	
	self.apiKey = apiKey;
	self.delegate = delegate;
	
	return self;
}

#pragma mark - Getter and Setter

-(void)setAllowNetworkAccess:(BOOL)allowNetworkAccess
{
	_allowNetworkAccess = allowNetworkAccess;
	if(!allowNetworkAccess){
		[self cancelRequest];
	}
}

#pragma mark - NSURLConnection

- (BOOL)createConnectionWithURL:(NSURL *)url 
					requestType:(MoeFmAPIRequestType)type
				timeoutInterval:(NSTimeInterval)timeout
{
	if(!self.allowNetworkAccess){
		NSLog(@"No network access allowed");
		if([self.delegate respondsToSelector:@selector(api:needNetworkAccess:)]){
			[self.delegate api:self needNetworkAccess:YES];
		}
		return NO;
	}
	
	self.isBusy = YES;
	// If currently having a connection, abort the new one
	if(self.theConnection){
		return NO;
	}
	
	// Create the request.
	NSURLRequest *theRequest = [NSURLRequest requestWithURL:url
												cachePolicy:NSURLRequestReloadRevalidatingCacheData
											timeoutInterval:timeout];
	self.requestType = type;
	
	// create the connection with the request
	// and start loading the data
	self.theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	
	if (self.theConnection) {
		// Create the NSMutableData to hold the received data.
		// receivedData is an instance variable declared elsewhere.
		self.receivedData = [NSMutableData data];
	} else {
		// Inform the user that the connection failed.
		return NO;
	}
	return YES;
}

- (void)cancelConnection
{
	if(self.theConnection && self.isBusy){
		[self.theConnection cancel];
		self.theConnection = nil;
		self.receivedData = nil;
		self.isBusy = NO;
	}
}

# pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse.
	
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
	
    // receivedData is an instance variable declared elsewhere.
    [self.receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
    [self.receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    // receivedData is declared as a method instance elsewhere
	self.theConnection = nil;
    self.receivedData = nil;
	
	self.isBusy = NO;
	
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
	
	if([self.delegate respondsToSelector:@selector(api:requestFailedWithError:)]){
		[self.delegate api:self requestFailedWithError:error];
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // do something with the data
    // receivedData is declared as a method instance elsewhere
    NSLog(@"Succeeded! Received %d bytes of data",[self.receivedData length]);
	
	if(self.requestType == MFMAPI_PLAYLIST){
		NSError* error;
		NSDictionary* json = [NSJSONSerialization 
							  JSONObjectWithData:[NSData dataWithData:self.receivedData]
							  options:kNilOptions 
							  error:&error];
		if(json == nil){
			// TODO
			NSLog(@"Json data is nil");
		}
		
		NSDictionary * response = [json objectForKey:@"response"];
		if(response == nil){
			// TODO
			NSLog(@"Response data is nil");
		}
		
		NSArray* playlist = [response objectForKey:@"playlist"];
		if(playlist == nil){
			// TODO
			NSLog(@"Playlist data is nil");
		}
		
		if([self.delegate respondsToSelector:@selector(api:readyWithPlaylist:)]){
			[self.delegate api:self readyWithPlaylist:playlist];
		}
	}
	else if(self.requestType == MFMAPI_IMAGE){
		UIImage *image = [UIImage imageWithData:self.receivedData];
		if([self.delegate respondsToSelector:@selector(api:readyWithImage:)]){
			[self.delegate api:self readyWithImage:image];
		}
	}
	
	
    // release the connection, and the data object
    self.theConnection = nil;
    self.receivedData = nil;
	
	self.isBusy = NO;
}

# pragma mark - public methods

- (BOOL)requestJsonWithURL:(NSURL *)url
{
	return [self createConnectionWithURL:url 
							 requestType:MFMAPI_JSON
						 timeoutInterval:10.0];
}


- (BOOL)requestImageWithURL:(NSURL *)url
{
	return [self createConnectionWithURL:url 
							 requestType:MFMAPI_IMAGE
						 timeoutInterval:10.0];
}

- (BOOL)requestListenPlaylistWithPage:(NSInteger)page
{
	NSURL *url = [NSURL URLWithString:[MoeFmAPIListenPlaylistAddress 
									   stringByAppendingFormat:@"&page=%d&api_key=%@", page, self.apiKey]];
	
    return [self createConnectionWithURL:url 
							 requestType:MFMAPI_PLAYLIST 
						 timeoutInterval:10.0];
}

- (BOOL)requestListenPlaylistWithFav:(NSString *)fav 
									 page:(NSInteger)page
{
	// TODO
	return NO;
}

- (BOOL)requestListenPlaylistWithMusic:(NSString *)music 
									   song:(NSString *)song
									  radio:(NSString *)radio 
									   page:(NSInteger)page
{
	// TODO
	return NO;
}

- (void)cancelRequest
{
	if(self.theConnection == nil){
		[self.theConnection cancel];
	}
}

@end
