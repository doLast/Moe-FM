//
//  MFMResourceFavs.m
//  Moe FM
//
//  Created by Greg Wang on 12-7-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MFMResourceFavs.h"
#import "MFMResourceSub.h"
#import "MFMResourceWiki.h"
#import "MFMResourcePlaylist.h"

static NSString * const kUserFavsUrlStr = @"http://api.moefou.org/user/favs/";
static NSString * const kPlaylistUrlStr = @"http://moe.fm/listen/playlist?api=";

@interface MFMResourceFavs ()

@property (retain, nonatomic) NSNumber *page;
@property (retain, nonatomic) NSNumber *perpage;
@property (retain, nonatomic) NSNumber *count;
@property (retain, nonatomic) NSArray *resourceFavs;

@property (retain, nonatomic) NSURL *playlistUrl;

@end


@implementation MFMResourceFavs

@synthesize page = _page;
@synthesize perpage = _perpage;
@synthesize count = _count;
@synthesize resourceFavs = _resourceFavs;

@synthesize playlistUrl = _playlistUrl;

- (MFMResourceFavs *)initWithUid:(NSNumber *)uid
						userName:(NSString *)userName
						 objType:(MFMFavObjType)objType
						 favType:(MFMFavType)favType
							page:(NSNumber *)page
						 perpage:(NSNumber *)perpage
{
	const NSString * category;
	if (objType < MFMFavObjTypeWiki) {
		category = MFMFavObjTypeStr[MFMFavObjTypeWiki];
	}
	else if (objType < MFMFavObjTypeSub) {
		category = MFMFavObjTypeStr[MFMFavObjTypeSub];
	}
	
	NSString *urlPrefix = [kUserFavsUrlStr stringByAppendingFormat:@"%@.%@?", 
						   category, MFMAPIFormat];
	NSString *playlistPrefix = [kPlaylistUrlStr stringByAppendingFormat:@"%@&fav=%@&", MFMAPIFormat, MFMFavObjTypeStr[objType]];
	
	NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
	if (uid) [parameters setValue:uid forKey:@"uid"];
	if (userName) [parameters setValue:userName forKey:@"user_name"];
	[parameters setValue:MFMFavObjTypeStr[objType] forKey: @"obj_type"];
	[parameters setValue:[NSNumber numberWithInt:favType] forKey:@"fav_type"]; 
	if (page) [parameters setValue:page forKey:@"page"];
	if (perpage) [parameters setValue:perpage forKey:@"perpage"];
	
	NSMutableDictionary *playlistParameters = [NSMutableDictionary dictionary];
	if (page) [playlistParameters setValue:page forKey:@"page"];
	if (perpage) [playlistParameters setValue:perpage forKey:@"perpage"];
	
	NSURL *url = [MFMResource urlWithPrefix:urlPrefix parameters:parameters];
	NSURL *playlistUrl = [MFMResource urlWithPrefix:playlistPrefix parameters:playlistParameters];
	NSLog(@"ResourceFavs playlist url: %@", playlistUrl);
	
	self = [super initWithURL:url];
	if (self != nil) {
		self.page = nil;
		self.perpage = nil;
		self.count = nil;
		self.resourceFavs = nil;
		self.playlistUrl = playlistUrl;
	}
	return self;
}

+ (MFMResourceFavs *)favsWithUid:(NSNumber *)uid
						userName:(NSString *)userName
						 objType:(MFMFavObjType)objType
						 favType:(MFMFavType)favType
							page:(NSNumber *)page
						 perpage:(NSNumber *)perpage
{
	MFMResourceFavs *instance = 
	[[MFMResourceFavs alloc] initWithUid:uid userName:userName
								 objType:objType favType:favType 
									page:page perpage:perpage];
	return instance;
}

# pragma mark - getter & setter

- (NSArray *)extraObjects
{
	if (self.resourceFavs == nil) {
		NSLog(@"No resource yet!");
		return nil;
	}
	
	NSMutableArray *result = [NSMutableArray arrayWithCapacity:self.resourceFavs.count];
	for (MFMResourceFav *fav in self.resourceFavs) {
		id obj = (MFMResourceSub *)fav.obj;
		[result addObject:obj];
	}
	return result;
}

- (NSArray *)resourceSubs
{	
//	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"favObjType>%d", MFMFavObjTypeWiki];
//	NSArray *filtered = [self.resourceFavs filteredArrayUsingPredicate:predicate];
	
	return [self extraObjects];
}

- (NSArray *)resourceWikis
{
//	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"favObjType<%d", MFMFavObjTypeWiki];
//	NSArray *filtered = [self.resourceFavs filteredArrayUsingPredicate:predicate];
	
	return [self extraObjects];
}

- (MFMResourcePlaylist *)playlist
{
	MFMResourcePlaylist *resourcePlaylist = [[MFMResourcePlaylist alloc] initWithURL:self.playlistUrl];
	return resourcePlaylist;
}

# pragma mark - Override MFMResource Methods

- (NSString *)description
{
	NSMutableString *str = [NSMutableString string];
	for (MFMResourceFav *resourceFav in self.resourceFavs) {
		[str appendString:resourceFav.description];
	}
	return str;
}

- (BOOL)prepareTheResource:(NSDictionary *)resource
{
	NSDictionary *responseInfo = [resource objectForKey:@"information"];
	NSArray *favs = [resource objectForKey:@"favs"];
	if (responseInfo == nil || favs == nil) {
		NSLog(@"Response info: %@, Favs: %@", responseInfo, favs);
		return NO;
	}
	
	self.page = [responseInfo objectForKey:@"page"];
	self.perpage = [responseInfo objectForKey:@"perpage"];
	self.count = [responseInfo objectForKey:@"count"];
	
	NSMutableArray *resourceFavs = [NSMutableArray array];
	for (NSDictionary *fav in favs) {
		MFMResourceFav *resourceFav = [[MFMResourceFav alloc] initWithResouce:fav];
		[resourceFavs addObject:resourceFav];
	}
	self.resourceFavs = resourceFavs;
	
	return YES;
}

@end
