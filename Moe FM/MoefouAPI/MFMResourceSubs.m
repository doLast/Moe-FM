//
//  MFMResourceSubs.m
//  Moe FM
//
//  Created by Greg Wang on 12-8-24.
//
//

static NSString * const kWikiSubsURLStr = @"http://api.moefou.org/{wiki_type}/subs.";
static NSString * const kWikiRelationshipsURLStr = @"http://api.moefou.org/{wiki_type}/relationships.";

#import "MFMResourceSubs.h"
#import "MFMResourceSub.h"

@interface MFMResourceSubs ()

@property (nonatomic) MFMResourceObjType wikiType;
@property (nonatomic, strong) NSNumber *wikiId;
@property (nonatomic, strong) NSString *wikiName;
@property (nonatomic) BOOL isRelationship;

@property (nonatomic) NSUInteger total;

- (NSURL *)urlForPage:(NSUInteger)page;

@end

@implementation MFMResourceSubs

@synthesize wikiId = _wikiId;
@synthesize wikiName = _wikiName;
@synthesize wikiType = _wikiType;
@synthesize isRelationship = _isRelationship;

- (MFMResourceSubs *)initWithWikiId:(NSNumber *)wikiId
						   wikiName:(NSString *)wikiName
						   wikiType:(MFMResourceObjType)wikiType
							objType:(MFMResourceObjType)objType
							perPage:(NSUInteger)perPage
					   relationship:(BOOL)isRelationship
{
	self = [super initWithObjType:objType withItemsPerPage:perPage];
	if (self != nil) {
		self.wikiId = wikiId;
		self.wikiName = wikiName;
		self.wikiType = wikiType;
		self.isRelationship = isRelationship;
	}
	return self;
}

+ (MFMResourceSubs *)subsWithWikiId:(NSNumber *)wikiId wikiName:(NSString *)wikiName wikiType:(MFMResourceObjType)wikiType subType:(MFMResourceObjType)subType perPage:(NSUInteger)perPage
{
	MFMResourceSubs *subs = nil;
	if ((wikiId != nil || wikiName != nil) && subType > MFMResourceObjTypeWiki) {
		subs = [[MFMResourceSubs alloc] initWithWikiId:wikiId wikiName:wikiName wikiType:wikiType objType:subType perPage:perPage relationship:NO];
	}
	return subs;
}

+ (MFMResourceSubs *)relationshipsWithWikiId:(NSNumber *)wikiId wikiName:(NSString *)wikiName wikiType:(MFMResourceObjType)wikiType objType:(MFMResourceObjType)objType
{
	MFMResourceSubs *subs = nil;
	if ((wikiId != nil || wikiName != nil) && objType > MFMResourceObjTypeWiki) {
		subs = [[MFMResourceSubs alloc] initWithWikiId:wikiId wikiName:wikiName wikiType:wikiType objType:objType perPage:MFMResourcePerPageDefault relationship:YES];
	}
	return subs;
}

- (NSURL *)urlForPage:(NSUInteger)page
{
	NSString *wikiTypeStr = [MFMResourceObjTypeStr[self.wikiType] copy];
	NSString *urlStr = nil;
	if (self.isRelationship) {
		urlStr = [kWikiRelationshipsURLStr copy];
	}
	else {
		urlStr = [kWikiSubsURLStr copy];
	}
	NSString *urlPrefix = [urlStr stringByReplacingOccurrencesOfString:@"{wiki_type}" withString:wikiTypeStr];
	urlPrefix = [urlPrefix stringByAppendingFormat:@"%@?", MFMAPIFormat];
	
	NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
	if (self.wikiId) [parameters setValue:self.wikiId forKey:@"wiki_id"];
	if (self.wikiName) [parameters setValue:self.wikiName forKey:@"wiki_name"];
	if (self.isRelationship) {
		[parameters setValue:MFMResourceObjTypeStr[self.objType] forKey: @"obj_type"];
	}
	else {
		[parameters setValue:MFMResourceObjTypeStr[self.objType] forKey: @"sub_type"];
		//	[parameters setValue:page forKey:@"page"];
		[parameters setValue:[NSNumber numberWithInteger:self.perPage] forKey:@"perpage"];
	}
	
	NSURL *url = [MFMResource urlWithPrefix:urlPrefix parameters:parameters];
	if (!self.isRelationship) url = [NSURL URLWithString:[NSString stringWithFormat:@"%@&page=%d", url, page + 1]];
	
	return url;
}

- (BOOL)prepareTheResource:(NSDictionary *)resource
{
	NSDictionary *responseInfo = [resource objectForKey:@"information"];
	NSArray *subs = [resource objectForKey:@"subs"];
	NSArray *relationships = [resource objectForKey:@"relationships"];
	
	if (responseInfo == nil || (subs == nil && relationships == nil)) {
		NSLog(@"Response info: %@, Subs: %@, Relationships: %@", responseInfo, subs, relationships);
		return NO;
	}
	
	NSNumber *total = [responseInfo objectForKey:@"count"];
	self.total = total.integerValue;
	NSNumber *page = [responseInfo objectForKey:@"page"];
	if (relationships != nil) {
		page = [NSNumber numberWithInteger:1];
	}
	
	int i = 0;
	
	for (NSDictionary *sub in subs) {
		MFMResourceSub *resourceSub = [[MFMResourceSub alloc] initWithResouce:sub];
		[self addObject:resourceSub toIndex:(page.integerValue - 1) * self.perPage + i];
		i++;
	}
	
	for (NSDictionary *relationship in relationships) {
		MFMResourceSub *resourceSub = [[MFMResourceSub alloc] initWithResouce:[relationship objectForKey:@"obj"]];
		[self addObject:resourceSub toIndex:(page.integerValue - 1) * self.perPage + i];
		i++;
	}
	
	return YES;
}

@end
