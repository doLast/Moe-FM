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
@property (nonatomic, strong) UIButton *favButton;

@end

@implementation MFMFavCell

@synthesize resourceFav = _resourceFav;
@synthesize favButton = _favButton;

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
	self.resource = resourceFav.obj;
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button setFrame:CGRectMake(0, 0, 32, 32)];
	[button addTarget:self action:@selector(toggleFav:) forControlEvents:UIControlEventTouchUpInside];
	self.favButton = button;
	
	[self updateFavStatus];
}

- (void)updateFavStatus
{
	if (self.favType == MFMFavTypeHeart) {
		[self.favButton setImage:[UIImage imageNamed:@"fav_no"] forState:UIControlStateNormal];
		[self.favButton setImage:[UIImage imageNamed:@"fav_yes"] forState:UIControlStateSelected];
	}
	else if (self.favType == MFMFavTypeTrash) {
		[self.favButton setImage:[UIImage imageNamed:@"dislike_no"] forState:UIControlStateNormal];
		[self.favButton setImage:[UIImage imageNamed:@"dislike_yes"] forState:UIControlStateSelected];
	}
	
	self.favButton.selected = [self.resourceFav didAddToFavAsType:self.favType];
}

- (void)updateFavInfo
{
	if ([self.resourceFav.obj isKindOfClass:[MFMResourceSub class]]) {
		[self showFavButton];
	}
}

- (IBAction)toggleFav:(id)sender
{
	if (self.resourceFav != nil) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:MFMResourceNotification object:self.resourceFav];
		[self.resourceFav toggleFavAsType:self.favType];
	}
}

- (void)showFavButton
{
	self.accessoryView = self.favButton;
}

- (void)hideFavButton
{
	self.accessoryView = nil;
}

#pragma mark - NotificationCenter

- (void)handleNotification:(NSNotification *)notification
{
	if (notification.name == MFMResourceNotification) {
		[self updateFavStatus];
		
		[[NSNotificationCenter defaultCenter] removeObserver:self name:MFMResourceNotification object:notification.object];
	}
}

@end
