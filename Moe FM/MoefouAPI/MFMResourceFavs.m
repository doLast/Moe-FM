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

static NSString * const kUserFavsUrlStr = @"http://api.moefou.org/user/favs/";

@interface MFMResourceFavs ()

@property (retain, nonatomic) NSNumber *page;
@property (retain, nonatomic) NSNumber *perpage;
@property (retain, nonatomic) NSNumber *count;
@property (retain, nonatomic) NSArray *resourceFavs;

@end


@implementation MFMResourceFavs

@synthesize page = _page;
@synthesize perpage = _perpage;
@synthesize count = _count;
@synthesize resourceFavs = _resourceFavs;

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
	
	NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
	if (uid) [parameters setValue:uid forKey:@"uid"];
	if (userName) [parameters setValue:userName forKey:@"user_name"];
	[parameters setValue:MFMFavObjTypeStr[objType] forKey: @"obj_type"];
	[parameters setValue:[NSNumber numberWithInt:favType] forKey:@"fav_type"]; 
	if (page) [parameters setValue:page forKey:@"page"];
	if (perpage) [parameters setValue:perpage forKey:@"perpage"];
	
	NSURL *url = [MFMResourceFavs urlWithPrefix:urlPrefix parameters:parameters];
	
	self = [super initWithURL:url];
	if (self != nil) {
		self.page = nil;
		self.perpage = nil;
		self.count = nil;
		self.resourceFavs = nil;
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

# pragma mark - class helpers

+ (NSURL *)urlWithPrefix:(NSString *)urlPrefix parameters:(NSDictionary *)parameters
{
	NSMutableString *urlStr = [urlPrefix mutableCopy];
	for (NSString *key in parameters.keyEnumerator) {
		[urlStr appendFormat:@"%@=%@&", key, [parameters objectForKey:key]];
	}
	[urlStr appendString:@"api_key=302182858672af62ebf4524ee8d9a06304f7db527"];
	
	NSURL *url = [NSURL URLWithString:urlStr];
	return url;
}

# pragma mark - getter & setter

- (NSArray *)resourceSubs
{
	if (self.resourceFavs == nil) {
		NSLog(@"No resource yet!");
		return nil;
	}
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"favObjType>%d", MFMFavObjTypeWiki];
	NSArray *filtered = [self.resourceFavs filteredArrayUsingPredicate:predicate];
	NSMutableArray *result = [NSMutableArray arrayWithCapacity:filtered.count];
	for (MFMResourceFav *fav in filtered) {
		MFMResourceSub *sub = (MFMResourceSub *)fav.obj;
		[result addObject:sub];
	}
	return result;
}

- (NSArray *)resourceWikis
{
	if (self.resourceFavs == nil) {
		NSLog(@"No resource yet!");
		return nil;
	}
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"favObjType<%d", MFMFavObjTypeWiki];
	NSArray *filtered = [self.resourceFavs filteredArrayUsingPredicate:predicate];
	NSMutableArray *result = [NSMutableArray arrayWithCapacity:filtered.count];
	for (MFMResourceFav *fav in filtered) {
		MFMResourceWiki *wiki = (MFMResourceWiki *)fav.obj;
		[result addObject:wiki];
	}
	return result;
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
	NSDictionary *favsInfo = [resource objectForKey:@"information"];
	NSArray *favs = [resource objectForKey:@"favs"];
	if (favsInfo == nil || favs == nil) {
		NSLog(@"Favs info: %@, Favs: %@", favsInfo, favs);
		return NO;
	}
	
	self.page = [favsInfo objectForKey:@"page"];
	self.perpage = [favsInfo objectForKey:@"perpage"];
	self.count = [favsInfo objectForKey:@"count"];
	
	NSMutableArray *resourceFavs = [NSMutableArray array];
	for (NSDictionary *fav in favs) {
		MFMResourceFav *resourceFav = [[MFMResourceFav alloc] initWithResouce:fav];
		[resourceFavs addObject:resourceFav];
	}
	self.resourceFavs = resourceFavs;
	
	return YES;
}

@end
