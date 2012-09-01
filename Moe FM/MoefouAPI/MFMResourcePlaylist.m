//
//  MFMResourcePlaylist.m
//  Moe FM
//
//  Created by Greg Wang on 12-7-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MFMResourcePlaylist.h"
#import "MFMResourceFavs.h"
#import "MFMResourceSubs.h"

static NSString * const kPlaylistURLStr = @"http://moe.fm/listen/playlist?api=";

@interface MFMResourcePlaylist ()

@property (nonatomic) NSUInteger total;

@property (nonatomic) BOOL mayHaveNext;
@property (nonatomic, strong) NSURL *playlistURL;

@end

@implementation MFMResourcePlaylist

#pragma mark - Getter & Setter

@synthesize mayHaveNext = _mayHaveNext;
@synthesize playlistURL = _playlistURL;

#pragma mark - life cycle

- (MFMResourcePlaylist *)initWithPlaylistURL:(NSURL *)playlistURL
{
	self = [super initWithObjType:MFMResourceObjTypeSong withItemsPerPage:MFMResourcePerPageDefault];
	if (self != nil) {
		self.mayHaveNext = YES;
		self.playlistURL = playlistURL;
		self.total = UINT_MAX;
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
	
	if ([collection isKindOfClass:[MFMResourceSubs class]]) {
		MFMResourceSubs *subs = (MFMResourceSubs *)collection;
		return [MFMResourcePlaylist playlistWIthObjType:subs.wikiType andIds:[NSArray arrayWithObject:subs.wikiId]];
	}
//	else if ([collection isKindOfClass:[MFMResourceWikis class]]) {
//		NSMutableSet *ids = [NSMutableSet set];
//		for (MFMResourceWiki *wiki in collection.resources) {
//			[ids addObject:wiki.wikiId];
//		}
//		return [MFMResourcePlaylist playlistWIthObjType:collection.objType
//												 andIds:[ids allObjects]];
//	}
	return nil;
}

+ (MFMResourcePlaylist *)playlistWithResource:(MFMResource *)resource
{
	if ([resource isKindOfClass:[MFMResourceCollection class]]) {
		return [MFMResourcePlaylist playlistWithCollection:(MFMResourceCollection *)resource];
	}
	
	if ([resource isKindOfClass:[MFMResourceFav class]]) {
		MFMResourceFav *fav = (MFMResourceFav *)resource;
		return [MFMResourcePlaylist playlistWithResource:fav.obj];
	}
	
	if ([resource isKindOfClass:[MFMResourceWiki class]]) {
		MFMResourceWiki *wiki = (MFMResourceWiki *)resource;
		return [MFMResourcePlaylist playlistWIthObjType:wiki.wikiType andIds:[NSArray arrayWithObject:wiki.wikiId]];
	}
	
	if ([resource isKindOfClass:[MFMResourceSub class]]) {
		MFMResourceSub *sub = (MFMResourceSub *)resource;
		return [MFMResourcePlaylist playlistWIthObjType:sub.subType andIds:[NSArray arrayWithObject:sub.subId]];
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
		[idStr setString:[idStr substringToIndex:idStr.length - 1]];
	}
	NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
								[NSNumber numberWithInteger:MFMResourcePerPageDefault], @"perpage",
								idStr, MFMResourceObjTypeStr[objType], 
								nil];
	NSURL *url = [MFMResource urlWithPrefix:urlPrefix parameters:parameters];
	MFMResourcePlaylist *playlist = [[MFMResourcePlaylist alloc] initWithPlaylistURL:url];
	return playlist;
}

# pragma mark - Override Methods

- (BOOL)loadPage:(NSUInteger)page
{
	if (self.mayHaveNext) {
		return [super loadPage:page];
	}
	NSLog(@"No more page.");
	return NO;
}

- (NSURL *)urlForPage:(NSUInteger)page
{
	NSURL *url = self.playlistURL;
	url = [NSURL URLWithString:[NSString stringWithFormat:@"%@&page=%d", url, page + 1]];
	
	return url;
}

- (BOOL)prepareTheResource:(NSDictionary *)resource
{
	NSDictionary *responseInfo = [resource objectForKey:@"information"];
	NSArray *songs = [resource objectForKey:@"playlist"];
	if (responseInfo == nil || songs == nil) {
		NSLog(@"Response info: %@, Songs: %@", responseInfo, songs);
		return NO;
	}
	
	NSNumber *mayHaveNext = [responseInfo objectForKey:@"may_have_next"];
	self.mayHaveNext = mayHaveNext.boolValue;
	NSNumber *page = [responseInfo objectForKey:@"page"];
	
	int i = 0;
	for (NSDictionary *song in songs) {
		MFMResourceSong *resourceSong = [[MFMResourceSong alloc] initWithResouce:song];
		[self addObject:resourceSong toIndex:(page.integerValue - 1) * self.perPage + i];
		i++;
	}
	
	return YES;
}


@end
