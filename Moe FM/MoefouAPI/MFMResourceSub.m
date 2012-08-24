//
//  MFMResourceSub.m
//  Moe FM
//
//  Created by Greg Wang on 12-7-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MFMResourceSub.h"
#import "MFMResourceWiki.h"

@interface MFMResourceSub ()

@property (retain, nonatomic) NSNumber *subId;
@property (retain, nonatomic) NSNumber *subParentWiki;
@property (retain, nonatomic) NSString *subTitle;
@property (retain, nonatomic) NSString *subTitleEncode;
@property (assign, nonatomic) MFMResourceObjType subType;
@property (retain, nonatomic) NSString *subOrder;
@property (retain, nonatomic) NSArray *subMeta;
@property (retain, nonatomic) NSString *subAbout;
@property (retain, nonatomic) NSDate *subDate;
@property (retain, nonatomic) NSDate *subModified;
@property (retain, nonatomic) NSURL *subFmURL;
@property (retain, nonatomic) NSURL *subURL;
@property (retain, nonatomic) NSString *subViewTitle;
@property (retain, nonatomic) MFMResourceWiki *wiki;

@end

@implementation MFMResourceSub

#pragma mark - getter & setter

@synthesize subId = _subId;
@synthesize subParentWiki = _subParentWiki;
@synthesize subTitle = _subTitle;
@synthesize subTitleEncode = _subTitleEncode;
@synthesize subType = _subType;
@synthesize subOrder = _subOrder;
@synthesize subMeta = _subMeta;
@synthesize subAbout = _subAbout;
@synthesize subDate = _subDate;
@synthesize subModified = _subModified;
@synthesize subFmURL = _subFmURL;
@synthesize subURL = _subURL;
@synthesize subViewTitle = _subViewTitle;
@synthesize wiki = _wiki;

# pragma mark - Override MFMResource Methods

- (NSString *)description
{
	return [NSString stringWithFormat:@"MFMResourceSub\nid: %@\nparentWiki: %@\ntitle: %@\ntitleEncode: %@\ntype: %@\norder: %@\nmeta: %@\nabout: %@\ndate: %@\nmodified: %@\nfmURL: %@\nurl: %@\nviewTitle: %@\nwiki: %@\n", self.subId, self.subParentWiki, self.subTitle, self.subTitleEncode, MFMResourceObjTypeStr[self.subType], self.subOrder, self.subMeta, self.subAbout, self.subDate, self.subModified, self.subFmURL, self.subURL, self.subViewTitle, self.wiki, nil];
}

- (BOOL)prepareTheResource:(NSDictionary *)resource
{
	self.subId = [resource objectForKey:@"sub_id"];
	self.subParentWiki = [resource objectForKey:@"sub_parent_wiki"];
	self.subTitle = [resource objectForKey:@"sub_title"];
	self.subTitleEncode = [resource objectForKey:@"sub_title_encode"];
	self.subType = [[NSArray arrayWithObjects:MFMResourceObjTypeStr count:MFMResourceObjTypeTotal]
					 indexOfObject:[resource objectForKey:@"sub_type"]];
	self.subOrder = [resource objectForKey:@"sub_order"];
	self.subMeta = [resource objectForKey:@"sub_meta"];
	self.subAbout = [resource objectForKey:@"sub_about"];
	self.subDate = [NSDate dateWithTimeIntervalSince1970:[(NSNumber *)[resource objectForKey:@"sub_date"] doubleValue]];
	self.subModified = [NSDate dateWithTimeIntervalSince1970:[(NSNumber *)[resource objectForKey:@"sub_modified"] doubleValue]];
	self.subFmURL = [NSURL URLWithString:[resource objectForKey:@"sub_fm_url"]];
	self.subURL = [NSURL URLWithString:[resource objectForKey:@"sub_url"]];
	self.subViewTitle = [resource objectForKey:@"sub_view_title"];
	if ([resource objectForKey:@"wiki"] != nil) {
		self.wiki = [[MFMResourceWiki alloc] initWithResouce:[resource objectForKey:@"wiki"]];
	}
	
	return YES;
}

@end
