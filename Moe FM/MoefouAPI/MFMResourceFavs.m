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

static NSString * const kUserFavsURLStr = @"http://api.moefou.org/user/favs/";
static NSString * const kPlaylistURLStr = @"http://moe.fm/listen/playlist?api=";

@interface MFMResourceFavs ()

//@property (retain, nonatomic) NSURL *playlistURL;

@property (nonatomic, strong) NSArray *resources;
@property (nonatomic, strong) NSNumber *nextPage;
@property (nonatomic, strong) NSNumber *count;
@property (nonatomic, strong) NSNumber *uid;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic) MFMFavType favType;

@end


@implementation MFMResourceFavs

//@synthesize playlistURL = _playlistURL;

@synthesize uid = _uid;
@synthesize userName = _userName;
@synthesize favType = _favType;

- (MFMResourceFavs *)initWithUid:(NSNumber *)uid
						userName:(NSString *)userName
						 objType:(MFMResourceObjType)objType
						 favType:(MFMFavType)favType
						fromPage:(NSNumber *)fromPage
						 perPage:(NSNumber *)perPage
{
	self = [super initWithObjType:objType fromPageNumber:fromPage withItemsPerPage:perPage];
	if (self != nil) {
		self.uid = uid;
		self.userName = userName;
		self.favType = favType;
	}
	return self;
}

+ (MFMResourceFavs *)favsWithUid:(NSNumber *)uid
						userName:(NSString *)userName
						 objType:(MFMResourceObjType)objType
						 favType:(MFMFavType)favType
						fromPage:(NSNumber *)fromPage
						 perPage:(NSNumber *)perPage
{
	MFMResourceFavs *instance = 
	[[MFMResourceFavs alloc] initWithUid:uid userName:userName objType:objType favType:favType fromPage:fromPage perPage:perPage];
	return instance;
}

- (NSURL *)urlForPage:(NSNumber *)page
{
	const NSString * category;
	if (self.objType < MFMResourceObjTypeWiki) {
		category = MFMResourceObjTypeStr[MFMResourceObjTypeWiki];
	}
	else if (self.objType < MFMResourceObjTypeSub) {
		category = MFMResourceObjTypeStr[MFMResourceObjTypeSub];
	}
	
	NSString *urlPrefix = [kUserFavsURLStr stringByAppendingFormat:@"%@.%@?",
						   category, MFMAPIFormat];
	
	NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
	if (self.uid) [parameters setValue:self.uid forKey:@"uid"];
	if (self.userName) [parameters setValue:self.userName forKey:@"user_name"];
	[parameters setValue:MFMResourceObjTypeStr[self.objType] forKey: @"obj_type"];
	[parameters setValue:[NSNumber numberWithInt:self.favType] forKey:@"fav_type"];
//	[parameters setValue:page forKey:@"page"];
	[parameters setValue:self.perPage forKey:@"perpage"];
	
	NSURL *url = [MFMResource urlWithPrefix:urlPrefix parameters:parameters];
	url = [NSURL URLWithString:[NSString stringWithFormat:@"%@&page=%@", url, page]];
	
	return url;
}

#pragma mark - getter & setter

- (MFMResourcePlaylist *)playlist
{
	MFMResourcePlaylist *resourcePlaylist = [[MFMResourcePlaylist alloc] init];
	return resourcePlaylist;
}

#pragma mark - Override MFMResource Methods

- (NSString *)description
{
	NSMutableString *str = [NSMutableString string];
	for (MFMResourceFav *resource in self.resources) {
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
	NSArray *favs = [resource objectForKey:@"favs"];
	if (responseInfo == nil || favs == nil) {
		NSLog(@"Response info: %@, Favs: %@", responseInfo, favs);
		return NO;
	}
	
	self.nextPage = [responseInfo objectForKey:@"page"];
	self.nextPage = [NSNumber numberWithInteger:self.nextPage.integerValue + 1];
	self.count = [responseInfo objectForKey:@"count"];
	
	NSMutableArray *resources = [NSMutableArray arrayWithArray:self.resources];
	for (NSDictionary *fav in favs) {
		MFMResourceFav *resourceFav = [[MFMResourceFav alloc] initWithResouce:fav];
		[resources addObject:resourceFav];
	}
	self.resources = resources;
	
	return YES;
}

@end
