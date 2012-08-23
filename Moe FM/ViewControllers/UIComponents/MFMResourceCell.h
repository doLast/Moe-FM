//
//  MFMResourceCell.h
//  Moe FM
//
//  Created by Greg Wang on 12-8-23.
//
//

#import <UIKit/UIKit.h>
#import "MFMHttpImageView.h"

@class MFMResource;

@interface MFMResourceCell : UITableViewCell

@property (nonatomic, strong) MFMResource *resource;

@property (nonatomic, strong) IBOutlet MFMHttpImageView *httpImageView;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *subtitleLabel;

@end
