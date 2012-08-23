//
//  MFMResourceCell.h
//  Moe FM
//
//  Created by Greg Wang on 12-8-23.
//
//

#import <UIKit/UIKit.h>
#import "MFMHttpImageView.h"

@interface MFMResourceCell : UITableViewCell

@property (nonatomic, strong) IBOutlet MFMHttpImageView *httpImageView;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *subtitleLabel;
@property (nonatomic, strong) IBOutlet UIButton *accessoryButton;

@end
