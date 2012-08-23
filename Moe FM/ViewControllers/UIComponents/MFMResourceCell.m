//
//  MFMResourceCell.m
//  Moe FM
//
//  Created by Greg Wang on 12-8-23.
//
//

#import "MFMResourceCell.h"

@interface MFMResourceCell ()

@end

@implementation MFMResourceCell

#pragma mark - Getter & Setter

@synthesize httpImageView = _httpImageView;
@synthesize titleLabel = _titleLabel;
@synthesize subtitleLabel = _subtitleLabel;
@synthesize accessoryButton = _accessoryButton;

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
