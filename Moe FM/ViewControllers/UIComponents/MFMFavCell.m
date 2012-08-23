//
//  MFMFavself.m
//  Moe FM
//
//  Created by Greg Wang on 12-8-23.
//
//

#import "MFMFavCell.h"
#import "MFMResourceFav.h"
#import "MFMResourceSub.h"
#import "MFMResourceWiki.h"

@interface MFMFavCell ()

@property (nonatomic, readonly) MFMResourceObjType favType;

@end

@implementation MFMFavCell

@synthesize resourceFav = _resourceFav;

- (MFMResourceObjType)favType
{
	if (self.resourceFav == nil) {
		return MFMFavTypeHeart;
	}
	return self.resourceFav.favType;
}

- (void)setResourceFav:(MFMResourceFav *)resourceFav
{
	_resourceFav = resourceFav;
	[self updateFavInfo];
	[self updateFavStatus];
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	[self updateFavStatus];
}

- (void)updateFavStatus
{
	if (self.favType == MFMFavTypeHeart) {
		[self.accessoryButton setImage:[UIImage imageNamed:@"fav_no"] forState:UIControlStateNormal];
		[self.accessoryButton setImage:[UIImage imageNamed:@"fav_yes"] forState:UIControlStateSelected];
	}
	else if (self.favType == MFMFavTypeTrash) {
		[self.accessoryButton setImage:[UIImage imageNamed:@"dislike_no"] forState:UIControlStateNormal];
		[self.accessoryButton setImage:[UIImage imageNamed:@"dislike_yes"] forState:UIControlStateSelected];
	}
	
	self.accessoryButton.selected = [self.resourceFav didAddToFavAsType:self.favType];
}

- (void)updateFavInfo
{
	if ([self.resourceFav.obj isKindOfClass:[MFMResourceSub class]]) {
		MFMResourceSub *sub = (MFMResourceSub *)self.resourceFav.obj;
		
		self.titleLabel.text = sub.subTitle;
		self.subtitleLabel.text = sub.wiki.wikiTitle;
		NSURL *url = [NSURL URLWithString:[sub.wiki.wikiCover objectForKey:@"small"]];
		[self.httpImageView resetImage];
		self.httpImageView.imageURL = url;
	}
	else if ([self.resourceFav.obj isKindOfClass:[MFMResourceWiki class]]) {
		MFMResourceWiki *wiki = (MFMResourceWiki *)self.resourceFav.obj;
		self.titleLabel.text = wiki.wikiTitle;
		self.subtitleLabel.text = @"";
		
		if (wiki.wikiType == MFMResourceObjTypeMusic)
			for (NSDictionary *meta in wiki.wikiMeta) {
				if ([[meta objectForKey:@"meta_key"] isEqualToString:@"艺术家"]) {
					self.subtitleLabel.text = [meta objectForKey:@"meta_value"];
				}
			}
		
		if (self.detailTextLabel.text.length == 0)
			for (NSDictionary *meta in wiki.wikiMeta) {
				if ([[meta objectForKey:@"meta_key"] isEqualToString:@"简介"]) {
					self.subtitleLabel.text = [meta objectForKey:@"meta_value"];
				}
			}
		
		if (self.detailTextLabel.text.length == 0) {
			self.subtitleLabel.text = NSLocalizedString(@"UNKNOWN_ARTIST", @"");
		}
		
		NSURL *url = [NSURL URLWithString:[wiki.wikiCover objectForKey:@"small"]];
		[self.httpImageView resetImage];
		self.httpImageView.imageURL = url;
	}
}

@end
