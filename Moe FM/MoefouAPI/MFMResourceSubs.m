//
//  MFMResourceSubs.m
//  Moe FM
//
//  Created by Greg Wang on 12-8-24.
//
//

static NSString * const kWikiSubsURLStr = @"http://api.moefou.org/{wiki_type}/subs.";

#import "MFMResourceSubs.h"
#import "MFMResourceSub.h"

@interface MFMResourceSubs ()

@property (nonatomic) MFMResourceObjType wikiType;
@property (nonatomic, strong) NSNumber *wikiId;
@property (nonatomic, strong) NSString *wikiName;

@property (nonatomic) NSUInteger total;

- (NSURL *)urlForPage:(NSUInteger)page;

@end

@implementation MFMResourceSubs

@synthesize wikiId = _wikiId;
@synthesize wikiName = _wikiName;
@synthesize wikiType = _wikiType;

- (MFMResourceSubs *)initWithWikiId:(NSNumber *)wikiId
						   wikiName:(NSString *)wikiName
						   wikiType:(MFMResourceObjType)wikiType
							subType:(MFMResourceObjType)subType
							perPage:(NSUInteger)perPage
{
	self = [super initWithObjType:subType withItemsPerPage:perPage];
	if (self != nil) {
		self.wikiId = wikiId;
		self.wikiName = wikiName;
		self.wikiType = wikiType;
	}
	return self;
}

+ (MFMResourceSubs *)subsWithWikiId:(NSNumber *)wikiId wikiName:(NSString *)wikiName wikiType:(MFMResourceObjType)wikiType subType:(MFMResourceObjType)subType perPage:(NSUInteger)perPage
{
	MFMResourceSubs *subs = nil;
	if (wikiId != nil || wikiName != nil) {
		subs = [[MFMResourceSubs alloc] initWithWikiId:wikiId wikiName:wikiName wikiType:wikiType subType:subType perPage:perPage];
	}
	return subs;
}

- (NSURL *)urlForPage:(NSUInteger)page
{
	NSString *wikiTypeStr = [MFMResourceObjTypeStr[self.wikiType] copy];
	NSString *urlPrefix = [kWikiSubsURLStr stringByReplacingOccurrencesOfString:@"{wiki_type}" withString:wikiTypeStr];
	urlPrefix = [urlPrefix stringByAppendingFormat:@"%@?", MFMAPIFormat];
	
	NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
	if (self.wikiId) [parameters setValue:self.wikiId forKey:@"wiki_id"];
	if (self.wikiName) [parameters setValue:self.wikiName forKey:@"wiki_name"];
	[parameters setValue:MFMResourceObjTypeStr[self.objType] forKey: @"sub_type"];
	//	[parameters setValue:page forKey:@"page"];
	[parameters setValue:[NSNumber numberWithInteger:self.perPage] forKey:@"perpage"];
	
	NSURL *url = [MFMResource urlWithPrefix:urlPrefix parameters:parameters];
	url = [NSURL URLWithString:[NSString stringWithFormat:@"%@&page=%d", url, page + 1]];
	
	return url;
}

- (BOOL)prepareTheResource:(NSDictionary *)resource
{
	NSDictionary *responseInfo = [resource objectForKey:@"information"];
	NSArray *subs = [resource objectForKey:@"subs"];
	if (responseInfo == nil || subs == nil) {
		NSLog(@"Response info: %@, Subs: %@", responseInfo, subs);
		return NO;
	}
	
	NSNumber *total = [responseInfo objectForKey:@"count"];
	self.total = total.integerValue;
	NSNumber *page = [responseInfo objectForKey:@"page"];
	
	int i = 0;
	for (NSDictionary *sub in subs) {
		MFMResourceSub *resourceSub = [[MFMResourceSub alloc] initWithResouce:sub];
		[self addObject:resourceSub toIndex:(page.integerValue - 1) * self.perPage + i];
		i++;
	}
	
	return YES;
}

@end
