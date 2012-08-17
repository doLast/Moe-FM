//
//  MFMResourcePlaylist.m
//  Moe FM
//
//  Created by Greg Wang on 12-7-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MFMResourcePlaylist.h"
#import "MFMResourceFavs.h"

static NSString * const kPlaylistURLStr = @"http://moe.fm/listen/playlist?api=";

@interface MFMResourcePlaylist ()

@property (nonatomic, strong) NSArray *resources;
@property (nonatomic, strong) NSNumber *nextPage;
@property (nonatomic, strong) NSNumber *count;
@property (nonatomic, strong) NSNumber *mayHaveNext;
@property (nonatomic, strong) NSURL *playlistURL;

@end

@implementation MFMResourcePlaylist

@synthesize mayHaveNext = _mayHaveNext;
@synthesize playlistURL = _playlistURL;

- (MFMResourcePlaylist *)initWithPlaylistURL:(NSURL *)playlistURL
{
	self = [super initWithObjType:MFMResourceObjTypeSong fromPageNumber:[NSNumber numberWithInteger:1] withItemsPerPage:[NSNumber numberWithInteger:10]];
	if (self != nil) {
		self.mayHaveNext = [NSNumber numberWithBool:YES];
		self.playlistURL = playlistURL;
		self.count = [NSNumber numberWithInteger:0];
	}
	return self;
}

+ (MFMResourcePlaylist *)magicPlaylist
{
	NSString *urlPrefix = [kPlaylistURLStr stringByAppendingFormat:@"%@&", MFMAPIFormat];
	NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
								[NSNumber numberWithInteger:MFMResourcePerPageDefault], @"perpage", nil];
	NSURL *url = [MFMResource urlWithPrefix:urlPrefix parameters:parameters];
	MFMResourcePlaylist *magicPlaylist = [[MFMResourcePlaylist alloc] initWithPlaylistURL:url];
	return magicPlaylist;
}

+ (MFMResourcePlaylist *)playlistWithCollection:(MFMResourceCollection *)collection
{
	if ([collection isKindOfClass:[MFMResourceFavs class]]) {
		
		return [MFMResourcePlaylist playlistWithFavType:collection.objType];
	}
	return nil;
}

+ (MFMResourcePlaylist *)playlistWithFavType:(MFMResourceObjType)favType
{
	if (favType != MFMResourceObjTypeMusic &&
		favType != MFMResourceObjTypeSong &&
		favType != MFMResourceObjTypeRadio) {
		return nil;
	}
	NSString *urlPrefix = [kPlaylistURLStr stringByAppendingFormat:@"%@&", MFMAPIFormat];
	NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
								[NSNumber numberWithInteger:MFMResourcePerPageDefault], @"perpage",
								MFMResourceObjTypeStr[favType], @"fav", 
								nil];
	NSURL *url = [MFMResource urlWithPrefix:urlPrefix parameters:parameters];
	MFMResourcePlaylist *playlist = [[MFMResourcePlaylist alloc] initWithPlaylistURL:url];
	return playlist;
}

+ (MFMResourcePlaylist *)playlistWIthObjType:(MFMResourceObjType)objType andIds:(NSArray *)ids
{
	if ((objType != MFMResourceObjTypeMusic &&
		objType != MFMResourceObjTypeSong &&
		objType != MFMResourceObjTypeRadio) ||
		ids == nil ||
		[ids count] < 1) {
		return nil;
	}
	NSString *urlPrefix = [kPlaylistURLStr stringByAppendingFormat:@"%@&", MFMAPIFormat];
	NSMutableString *idStr = [NSMutableString string];
	for (NSNumber *resourceId in ids) {
		if ([resourceId isKindOfClass:[NSNumber class]]) {
			[idStr appendFormat:@"%d,", resourceId.integerValue];
		}
	}
	if (idStr.length > 0) {
		[idStr substringToIndex:idStr.length - 1];
	}
	NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
								[NSNumber numberWithInteger:MFMResourcePerPageDefault], @"perpage",
								idStr, MFMResourceObjTypeStr[objType], 
								nil];
	NSURL *url = [MFMResource urlWithPrefix:urlPrefix parameters:parameters];
	MFMResourcePlaylist *playlist = [[MFMResourcePlaylist alloc] initWithPlaylistURL:url];
	return playlist;
}

- (NSURL *)urlForPage:(NSNumber *)page
{
	NSURL *url = self.playlistURL;
	url = [NSURL URLWithString:[NSString stringWithFormat:@"%@&page=%@", url, page]];
	
	return url;
}

- (BOOL)startFetchNextPage
{
	NSURL *url = nil;
	if (self.nextPage == nil) {
		url = [self urlForPage:self.fromPage];
	}
	else if (self.mayHaveNext.boolValue) {
		url = [self urlForPage:self.nextPage];
	}
	else {
		NSLog(@"No more pages in playlist");
		return NO;
	}
	return [self startFetchWithURL:url andDataType:MFMDataTypeJson];
}

# pragma mark - Override MFMResource Methods

- (NSString *)description
{
	NSMutableString *str = [NSMutableString string];
	for (NSObject *resource in self.resources) {
		[str appendString:resource.description];
	}
	return str;
}

- (BOOL)prepareTheResource:(NSDictionary *)resource
{
	if (self.nextPage == nil) {
		self.resources = nil;
	}
	
	NSDictionary *responseInfo = [resource objectForKey:@"information"];
	NSArray *songs = [resource objectForKey:@"playlist"];
	if (responseInfo == nil || songs == nil) {
		NSLog(@"Response info: %@, Songs: %@", responseInfo, songs);
		return NO;
	}
	
	self.nextPage = [responseInfo objectForKey:@"page"];
	self.nextPage = [NSNumber numberWithInteger:self.nextPage.integerValue + 1];
	self.mayHaveNext = [responseInfo objectForKey:@"may_have_next"];
	
	NSMutableArray *resources = [NSMutableArray arrayWithArray:self.resources];
	for (NSDictionary *song in songs) {
		MFMResourceSong *resourceSong = [[MFMResourceSong alloc] initWithResouce:song];
		[resources addObject:resourceSong];
	}
	self.resources = resources;
	self.count = [NSNumber numberWithInt:[self.resources count]];
	
	return YES;
}


@end
