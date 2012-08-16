//
//  MFMResourceSub.m
//  Moe FM
//
//  Created by Greg Wang on 12-7-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MFMResourceSub.h"

const NSString * const MFMSubTypeStr[] = 
{@"ep", @"song"};

@interface MFMResourceSub ()

@property (retain, nonatomic) NSNumber *subId;
@property (retain, nonatomic) NSNumber *subParentWiki;
@property (retain, nonatomic) NSString *subTitle;
@property (retain, nonatomic) NSString *subTitleEncode;
@property (assign, nonatomic) MFMSubType subType;
@property (retain, nonatomic) NSString *subOrder;
@property (retain, nonatomic) NSArray *subMeta;
@property (retain, nonatomic) NSString *subAbout;
@property (retain, nonatomic) NSDate *subDate;
@property (retain, nonatomic) NSDate *subModified;
@property (retain, nonatomic) NSURL *subFmURL;
@property (retain, nonatomic) NSURL *subURL;
@property (retain, nonatomic) NSString *subViewTitle;

@end

@implementation MFMResourceSub

@synthesize subId;
@synthesize subParentWiki;
@synthesize subTitle;
@synthesize subTitleEncode;
@synthesize subType;
@synthesize subOrder;
@synthesize subMeta;
@synthesize subAbout;
@synthesize subDate;
@synthesize subModified;
@synthesize subFmURL;
@synthesize subURL;
@synthesize subViewTitle;

# pragma mark - Override MFMResource Methods

- (NSString *)description
{
	return [NSString stringWithFormat:@"MFMResourceSub\nid: %@\nparentWiki: %@\ntitle: %@\ntitleEncode: %@\ntype: %@\norder: %@\nmeta: %@\nabout: %@\ndate: %@\nmodified: %@\nfmURL: %@\nurl: %@\nviewTitle: %@\n", self.subId, self.subParentWiki, self.subTitle, self.subTitleEncode, MFMSubTypeStr[self.subType], self.subOrder, self.subMeta, self.subAbout, self.subDate, self.subModified, self.subFmURL, self.subURL, self.subViewTitle, nil];
}

- (BOOL)prepareTheResource:(NSDictionary *)resource
{
	self.subId = [resource objectForKey:@"sub_id"];
	self.subParentWiki = [resource objectForKey:@"sub_parent_wiki"];
	self.subTitle = [resource objectForKey:@"sub_title"];
	self.subTitleEncode = [resource objectForKey:@"sub_title_encode"];
	self.subType = [[NSArray arrayWithObjects:MFMSubTypeStr count:MFMSubTypeTotal]
					 indexOfObject:[resource objectForKey:@"sub_type"]];
	self.subOrder = [resource objectForKey:@"sub_order"];
	self.subMeta = [resource objectForKey:@"sub_meta"];
	self.subAbout = [resource objectForKey:@"sub_about"];
	self.subDate = [NSDate dateWithTimeIntervalSince1970:[(NSNumber *)[resource objectForKey:@"sub_date"] doubleValue]];
	self.subModified = [NSDate dateWithTimeIntervalSince1970:[(NSNumber *)[resource objectForKey:@"sub_modified"] doubleValue]];
	self.subFmURL = [NSURL URLWithString:[resource objectForKey:@"sub_fm_url"]];
	self.subURL = [NSURL URLWithString:[resource objectForKey:@"sub_url"]];
	self.subViewTitle = [resource objectForKey:@"sub_view_title"];
	
	return YES;
}

@end
