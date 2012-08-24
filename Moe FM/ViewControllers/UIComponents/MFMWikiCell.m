//
//  MFMWikiCell.m
//  Moe FM
//
//  Created by Greg Wang on 12-8-24.
//
//

#import "MFMWikiCell.h"
#import "MFMResourceWiki.h"

@implementation MFMWikiCell

@synthesize detailLabelOne = _detailLabelOne;
@synthesize detailLabelTwo = _detailLabelTwo;
@synthesize buttonView = _buttonView;

- (void)setResource:(MFMResource *)resource
{
	[super setResource:resource];
	
	self.accessoryType = UITableViewCellAccessoryNone;
	self.detailLabelOne.text = NSLocalizedString(@"UNKNOWN_DATE", @"");
	self.detailLabelTwo.text = NSLocalizedString(@"UNKNOWN_ARTIST", @"");
	
	if ([self.resource isKindOfClass:[MFMResourceWiki class]] == NO) {
		return;
	}
	MFMResourceWiki *wiki = (MFMResourceWiki *) self.resource;
	
	if (wiki.wikiMeta == nil || [wiki.wikiMeta isKindOfClass:[NSNull class]]) {
		return;
	}
	for (NSDictionary *meta in wiki.wikiMeta) {
		if ([[meta objectForKey:@"meta_key"] isEqualToString:@"发售日期"]) {
			self.detailLabelOne.text = [meta objectForKey:@"meta_value"];
		}
		else if ([[meta objectForKey:@"meta_key"] isEqualToString:@"艺术家"]) {
			self.detailLabelTwo.text = [meta objectForKey:@"meta_value"];
		}
	}
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	self.userInteractionEnabled = NO;
	[self.buttonView addSubview:self.favButton];
}

@end
