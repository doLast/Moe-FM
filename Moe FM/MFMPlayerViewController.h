//
//  MFMPlayerViewController.h
//  Moe FM
//
//  Created by Greg Wang on 12-4-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoeFmPlayer.h"

@interface MFMPlayerViewController : UIViewController <MoeFmPlayerDelegate>

@property (assign, nonatomic) IBOutlet UILabel *songNameLable;
@property (assign, nonatomic) IBOutlet UILabel *songArtistLabel;
@property (assign, nonatomic) IBOutlet UILabel *songAlbumLabel;
@property (assign, nonatomic) IBOutlet UIProgressView *songProgressIndicator;
@property (assign, nonatomic) IBOutlet UIImageView *songArtworkImage;

- (IBAction)togglePlaybackState:(UIButton *)sender;
- (IBAction)toggleFavourite:(UIButton *)sender;
- (IBAction)toggleDislike:(UIButton *)sender;
- (IBAction)nextTrack:(UIButton *)sender;

@end
