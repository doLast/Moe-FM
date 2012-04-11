//
//  MoeFmAPI.m
//  Moe FM
//
//  Created by Greg Wang on 12-4-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MoeFmAPI.h"

NSString * const MoeFmAPIListenPlaylistAddress = @"http://moe.fm/listen/playlist?api=json";

@interface MoeFmAPI ()
@property (retain, nonatomic) NSString *apiKey;

@end

@implementation MoeFmAPI

@synthesize apiKey = _apiKey;

- (MoeFmAPI *) initWithApiKey:(NSString *)apiKey
{
	self = [super init];
	
	self.apiKey = apiKey;
	
	return self;
}

- (NSArray *)getListenPlaylistWithPage:(NSInteger)page
{
	NSURL *url = [NSURL URLWithString:[MoeFmAPIListenPlaylistAddress 
									   stringByAppendingFormat:@"&page=%d&api_key=%@", page, self.apiKey]];
	//parse out the json data
	NSData* data = [NSData dataWithContentsOfURL: url];
    NSError* error;
    NSDictionary* json = [NSJSONSerialization 
						  JSONObjectWithData:data 
						  options:kNilOptions 
						  error:&error];
	if(json == nil){
		// TODO
		NSLog(@"Json data is nil");
		return nil;
	}
	
	NSDictionary * response = [json objectForKey:@"response"];
	if(response == nil){
		// TODO
		NSLog(@"Response data is nil");
		return nil;
	}
	
    NSArray* playlist = [response objectForKey:@"playlist"];
	if(playlist == nil){
		// TODO
		NSLog(@"Playlist data is nil");
		return nil;
	}
	
    return playlist;
}

- (NSArray *)getListenPlaylistWithFav:(NSString *)fav 
								 page:(NSInteger)page
{
	// TODO
	return nil;
}

- (NSArray *)getListenPlaylistWithMusic:(NSString *)music 
								   song:(NSString *)song
								  radio:(NSString *)radio 
								   page:(NSInteger)page
{
	// TODO
	return nil;
}



@end
