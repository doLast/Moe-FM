//
//  MFMPlayerViewController.h
//  Moe FM
//
//  Created by Greg Wang on 12-4-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MFMPlayerViewController : UIViewController

@property (assign, nonatomic) IBOutlet UILabel *songNameLable;
@property (assign, nonatomic) IBOutlet UILabel *songArtistLabel;
@property (assign, nonatomic) IBOutlet UILabel *songAlbumLabel;
@property (assign, nonatomic) IBOutlet UIProgressView *songTimeIndicator;
@property (assign, nonatomic) IBOutlet UIImageView *songArtworkImage;
@property (assign, nonatomic) IBOutlet UIButton *playOrPauseButton;
@property (assign, nonatomic) IBOutlet UIButton *favouriteButton;
@property (assign, nonatomic) IBOutlet UIButton *dislikeButton;
@property (assign, nonatomic) IBOutlet UIButton *nextButton;



@end
