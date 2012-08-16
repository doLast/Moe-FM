//
//  MFMResourcePlaylist.m
//  Moe FM
//
//  Created by Greg Wang on 12-7-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MFMResourcePlaylist.h"

static NSString * const kPlaylistURLStr = @"http://moe.fm/listen/playlist?api=";

@interface MFMResourcePlaylist ()

@property (retain, nonatomic) NSNumber *page;
@property (retain, nonatomic) NSNumber *itemCount;
@property (assign, nonatomic) NSNumber *mayHaveNext;
@property (retain, nonatomic) NSURL *nextURL;
@property (retain, nonatomic) NSArray *resourceSongs;

@end

@implementation MFMResourcePlaylist

@synthesize page = _page;
@synthesize itemCount = _itemCount;
@synthesize mayHaveNext = _mayHaveNext;
@synthesize nextURL = _nextURL;
@synthesize resourceSongs = _resourceSongs;

+ (MFMResourcePlaylist *)magicPlaylist
{
	static MFMResourcePlaylist *magicPlaylist;
	if (magicPlaylist == nil) {
		NSString *urlPrefix = [kPlaylistURLStr stringByAppendingFormat:@"%@&", MFMAPIFormat];
		NSURL *url = [MFMResource urlWithPrefix:urlPrefix parameters:nil];
		magicPlaylist = [[MFMResourcePlaylist alloc] initWithURL:url];
	}
	return magicPlaylist;
}

# pragma mark - Override MFMResource Methods

- (NSString *)description
{
	NSMutableString *str = [NSMutableString string];
	for (MFMResourceSong *resourceSong in self.resourceSongs) {
		[str appendString:resourceSong.description];
	}
	return str;
}

- (BOOL)prepareTheResource:(NSDictionary *)resource
{
	NSDictionary *responseInfo = [resource objectForKey:@"information"];
	NSArray *songs = [resource objectForKey:@"playlist"];
	if (responseInfo == nil || songs == nil) {
		NSLog(@"Response info: %@, Songs: %@", responseInfo, songs);
		return NO;
	}
	
	self.page = [responseInfo objectForKey:@"page"];
	self.itemCount = [responseInfo objectForKey:@"item_count"];
	self.mayHaveNext = [responseInfo objectForKey:@"may_have_next"];
	self.nextURL = [NSURL URLWithString:[responseInfo objectForKey:@"next_url"]];
	
	NSMutableArray *resourceSongs = [NSMutableArray array];
	for (NSDictionary *song in songs) {
		MFMResourceSong *resourceSong = [[MFMResourceSong alloc] initWithResouce:song];
		[resourceSongs addObject:resourceSong];
	}
	self.resourceSongs = resourceSongs;
	
	return YES;
}


@end
