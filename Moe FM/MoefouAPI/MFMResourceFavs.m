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

@interface MFMResourceFavs ()

@property (nonatomic, strong) NSNumber *uid;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic) MFMFavType favType;

@property (nonatomic) NSUInteger total;

- (NSURL *)urlForPage:(NSUInteger)page;

@end


@implementation MFMResourceFavs

#pragma mark - getter & setter

@synthesize uid = _uid;
@synthesize userName = _userName;
@synthesize favType = _favType;

#pragma mark - life cycle

- (MFMResourceFavs *)initWithUid:(NSNumber *)uid
						userName:(NSString *)userName
						 objType:(MFMResourceObjType)objType
						 favType:(MFMFavType)favType
						 perPage:(NSUInteger)perPage
{
	self = [super initWithObjType:objType withItemsPerPage:perPage];
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
						 perPage:(NSUInteger)perPage
{
	MFMResourceFavs *instance = 
	[[MFMResourceFavs alloc] initWithUid:uid userName:userName objType:objType favType:favType perPage:perPage];
	return instance;
}

#pragma mark - Override Methods

- (NSURL *)urlForPage:(NSUInteger)page
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
	[parameters setValue:[NSNumber numberWithInteger:self.perPage] forKey:@"perpage"];
	
	NSURL *url = [MFMResource urlWithPrefix:urlPrefix parameters:parameters];
	url = [NSURL URLWithString:[NSString stringWithFormat:@"%@&page=%d", url, page + 1]];
	
	return url;
}

- (BOOL)prepareTheResource:(NSDictionary *)resource
{
	NSDictionary *responseInfo = [resource objectForKey:@"information"];
	NSArray *favs = [resource objectForKey:@"favs"];
	if (responseInfo == nil || favs == nil) {
		NSLog(@"Response info: %@, Favs: %@", responseInfo, favs);
		return NO;
	}
	
	NSNumber *total = [responseInfo objectForKey:@"count"];
	self.total = total.integerValue;
	NSNumber *page = [responseInfo objectForKey:@"page"];
	
	int i = 0;
	for (NSDictionary *fav in favs) {
		MFMResourceFav *resourceFav = [[MFMResourceFav alloc] initWithResouce:fav];
		[self addObject:resourceFav toIndex:(page.integerValue - 1) * self.perPage + i];
		i++;
	}
	
	return YES;
}

@end
