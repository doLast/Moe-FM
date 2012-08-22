//
//  MFMPlayerViewController.h
//  Moe FM
//
//  Created by Greg Wang on 12-7-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MFMHttpImageView;
@class MFMReflectedImageView;

@interface MFMPlayerViewController : UIViewController

@property (assign, nonatomic) IBOutlet UIView *songInfoView;
@property (assign, nonatomic) IBOutlet UILabel *songNameLabel;
@property (assign, nonatomic) IBOutlet UILabel *songArtistLabel;
@property (assign, nonatomic) IBOutlet UILabel *songAlbumLabel;
@property (assign, nonatomic) IBOutlet UIProgressView *songProgressIndicator;
@property (assign, nonatomic) IBOutlet MFMHttpImageView *songArtworkImage;
@property (assign, nonatomic) IBOutlet MFMReflectedImageView *songArtworkReflection;
@property (assign, nonatomic) IBOutlet UIActivityIndicatorView *songArtworkLoadingIndicator;
@property (assign, nonatomic) IBOutlet UIActivityIndicatorView *songBufferingIndicator;
@property (assign, nonatomic) IBOutlet UIButton *playButton;

- (IBAction)showMenu:(id)sender;
- (IBAction)togglePlaybackState:(id)sender;

@end
