//
//  MFMWikiCell.h
//  Moe FM
//
//  Created by Greg Wang on 12-8-24.
//
//

#import "MFMFavCell.h"

@interface MFMWikiCell : MFMFavCell

@property (nonatomic, weak) IBOutlet UILabel *detailLabelOne;
@property (nonatomic, weak) IBOutlet UILabel *detailLabelTwo;
@property (nonatomic, weak) IBOutlet UIView *buttonView;

@end
