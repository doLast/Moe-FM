//
//  MFMFavCell.h
//  Moe FM
//
//  Created by Greg Wang on 12-8-23.
//
//

#import "MFMResourceCell.h"
#import "MFMResourceFav.h"

@interface MFMFavCell : MFMResourceCell

@property (nonatomic, strong) MFMResourceFav *resourceFav;
@property (nonatomic, strong, readonly) UIButton *favButton;

- (IBAction)toggleFav:(id)sender;
- (void)showFavButton;
- (void)hideFavButton;

@end
