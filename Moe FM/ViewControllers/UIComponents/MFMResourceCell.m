//
//  MFMResourceCell.m
//  Moe FM
//
//  Created by Greg Wang on 12-8-23.
//
//

#import "MFMResourceCell.h"
#import "MFMResource.h"
#import "MFMResourceWiki.h"
#import "MFMResourceSub.h"

@interface MFMResourceCell ()

@end

@implementation MFMResourceCell

#pragma mark - Getter & Setter

@synthesize resource = _resource;

@synthesize httpImageView = _httpImageView;
@synthesize titleLabel = _titleLabel;
@synthesize subtitleLabel = _subtitleLabel;

- (void)setResource:(MFMResource *)resource
{
	_resource = resource;
	[self updateInfo];
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		[self awakeFromNib];
	}
	return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
		[self awakeFromNib];
    }
    return self;
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list-item-bg"]];
	self.backgroundView = backgroundView;
}

- (void)updateInfo
{
	if ([self.resource isKindOfClass:[MFMResourceSub class]]) {
		MFMResourceSub *sub = (MFMResourceSub *)self.resource;
		self.titleLabel.text = sub.subTitle;
		self.subtitleLabel.text = NSLocalizedString(@"UNKNOWN_ALBUM", @"");
		
		NSURL *url = [NSURL URLWithString:[sub.wiki.wikiCover objectForKey:@"small"]];
		[self.httpImageView resetImage];
		self.httpImageView.imageURL = url;
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		if (sub.wiki == nil || [sub.wiki isKindOfClass:[NSNull class]]) {
			return;
		}
		self.subtitleLabel.text = sub.wiki.wikiTitle;
	}
	else if ([self.resource isKindOfClass:[MFMResourceWiki class]]) {
		MFMResourceWiki *wiki = (MFMResourceWiki *)self.resource;
		self.titleLabel.text = wiki.wikiTitle;
		self.subtitleLabel.text = NSLocalizedString(@"UNKNOWN_ARTIST", @"");
		
		NSURL *url = [NSURL URLWithString:[wiki.wikiCover objectForKey:@"small"]];
		[self.httpImageView resetImage];
		self.httpImageView.imageURL = url;
		self.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
		
		if (wiki.wikiMeta == nil || [wiki.wikiMeta isKindOfClass:[NSNull class]]) {
			return;
		}
		
		for (NSDictionary *meta in wiki.wikiMeta) {
			if ([[meta objectForKey:@"meta_key"] isEqualToString:@"艺术家"]) {
				self.subtitleLabel.text = [meta objectForKey:@"meta_value"];
				break;
			}
			if ([[meta objectForKey:@"meta_key"] isEqualToString:@"简介"]) {
				self.subtitleLabel.text = [meta objectForKey:@"meta_value"];
			}
		}
	}
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
	[super setSelected:selected animated:animated];

	if(selected)
	{
		[self.titleLabel setTextColor:[UIColor whiteColor]];
		[self.titleLabel setShadowColor:[UIColor colorWithRed:25.0/255 green:96.0/255 blue:148.0/255 alpha:1.0]];
		[self.titleLabel setShadowOffset:CGSizeMake(0, -1)];
		
		[self.subtitleLabel setTextColor:[UIColor whiteColor]];
		[self.subtitleLabel setShadowColor:[UIColor colorWithRed:25.0/255 green:96.0/255 blue:148.0/255 alpha:1.0]];
		[self.subtitleLabel setShadowOffset:CGSizeMake(0, -1)];
	}
	else
	{
		[self.titleLabel setTextColor:[UIColor colorWithRed:0.0 green:68.0/255 blue:118.0/255 alpha:1.0]];
		[self.titleLabel setShadowColor:[UIColor colorWithRed:0.0 green:68.0/255 blue:118.0/255 alpha:0.3]];
		[self.titleLabel setShadowOffset:CGSizeMake(0.8, 0.5)];

		[self.subtitleLabel setTextColor:[UIColor colorWithRed:113.0/255 green:133.0/255 blue:148.0/255 alpha:1.0]];
		[self.subtitleLabel setShadowColor:[UIColor colorWithRed:113.0/255 green:133.0/255 blue:148.0/255 alpha:0.3]];
		[self.subtitleLabel setShadowOffset:CGSizeMake(0.5, 0.3)];
	}
}

@end
