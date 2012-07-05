//
//  MFMResourceWiki.m
//  Moe FM
//
//  Created by Greg Wang on 12-7-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MFMResourceWiki.h"
const NSString * const MFMWikiTypeStr[] = 
{@"tv", @"ova", @"oad", @"movie", @"anime", @"comic", @"music", @"radio"};
const NSString * const MFMWikiCoverStr[] = 
{@"small", @"medium", @"square", @"large"};

NSString * const MFMWikisUrlStr = @"http://api.moefou.org/wikis.json?";

@interface MFMResourceWiki ()

@property (retain, nonatomic) NSNumber *wikiId;
@property (retain, nonatomic) NSString *wikiTitle;
@property (retain, nonatomic) NSString *wikiTitleEncode;
@property (assign, nonatomic) MFMWikiType wikiType;
@property (retain, nonatomic) NSDate *wikiDate;
@property (retain, nonatomic) NSDate *wikiModified;
@property (retain, nonatomic) NSNumber *wikiModifiedUser;
@property (retain, nonatomic) NSArray *wikiMeta;
@property (retain, nonatomic) NSURL *wikiFmUrl;
@property (retain, nonatomic) NSURL *wikiUrl;
@property (retain, nonatomic) NSDictionary *wikiCover;

@end

@implementation MFMResourceWiki

@synthesize wikiId = _wikiId;
@synthesize wikiTitle = _wikiTitle;
@synthesize wikiTitleEncode = _wikiTitleEncode;
@synthesize wikiType = _wikiType;
@synthesize wikiDate = _wikiDate;
@synthesize wikiModified = _wikiModified;
@synthesize wikiModifiedUser = _wikiModifiedUser;
@synthesize wikiMeta = _wikiMeta;
@synthesize wikiFmUrl = _wikiFmUrl;
@synthesize wikiUrl = _wikiUrl;
@synthesize wikiCover = _wikiCover;

# pragma mark - Override MFMResource Methods

- (NSString *)description
{
	return [NSString stringWithFormat:@"MFMResourceWiki\nid: %@\ntitle: %@\ntitleEncode: %@\ntype: %@\ndate: %@\nmodified: %@\nmodifiedUser: %@\nmeta: %@\nfmUrl: %@\nurl: %@\ncover: %@\n", self.wikiId, self.wikiTitle, self.wikiTitleEncode, MFMWikiTypeStr[self.wikiType], self.wikiDate, self.wikiModified, self.wikiModifiedUser, self.wikiMeta, self.wikiFmUrl, self.wikiUrl, self.wikiCover, nil];
}

- (BOOL)prepareTheResource:(NSDictionary *)resource
{
	self.wikiId = [resource objectForKey:@"wiki_id"];
	self.wikiTitle = [resource objectForKey:@"wiki_title"];
	self.wikiTitleEncode = [resource objectForKey:@"wiki_title_encode"];
	self.wikiType = [[NSArray arrayWithObjects:MFMWikiTypeStr count:MFMWikiTypeTotal]
					 indexOfObject:[resource objectForKey:@"wiki_type"]];
	self.wikiDate = [NSDate dateWithTimeIntervalSince1970:[(NSNumber *)[resource objectForKey:@"wiki_date"] doubleValue]];
	self.wikiModified = [NSDate dateWithTimeIntervalSince1970:[(NSNumber *)[resource objectForKey:@"wiki_modified"] doubleValue]];
	self.wikiModifiedUser = [resource objectForKey:@"wiki_modified_user"];
	self.wikiMeta = [resource objectForKey:@"wiki_meta"];
	self.wikiFmUrl = [NSURL URLWithString:[resource objectForKey:@"wiki_fm_url"]];
	self.wikiUrl = [NSURL URLWithString:[resource objectForKey:@"wiki_url"]];
	self.wikiCover = [resource objectForKey:@"wiki_cover"];
	
	return YES;
}

@end
