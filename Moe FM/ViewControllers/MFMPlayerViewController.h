//
//  MFMPlayerViewController.h
//  Moe FM
//
//  Created by Greg Wang on 12-7-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MFMHttpImageView;

@interface MFMPlayerViewController : UIViewController

@property (assign, nonatomic) IBOutlet UINavigationItem *navTitle;

@property (assign, nonatomic) IBOutlet UILabel *songNameLabel;
@property (assign, nonatomic) IBOutlet UILabel *songInfoLabel;
@property (assign, nonatomic) IBOutlet UIProgressView *songProgressIndicator;
@property (assign, nonatomic) IBOutlet MFMHttpImageView *songArtworkImage;
@property (assign, nonatomic) IBOutlet UIActivityIndicatorView *songArtworkLoadingIndicator;
@property (assign, nonatomic) IBOutlet UIActivityIndicatorView *songBufferingIndicator;
@property (assign, nonatomic) IBOutlet UIButton *playButton;
@property (assign, nonatomic) IBOutlet UIButton *favButton;
@property (assign, nonatomic) IBOutlet UIButton *dislikeButton;
@property (assign, nonatomic) IBOutlet UIButton *nextButton;

- (IBAction)showMenu:(id)sender;
- (IBAction)togglePlaybackState:(id)sender;
- (IBAction)toggleFavourite:(id)sender;
- (IBAction)toggleDislike:(id)sender;
- (IBAction)nextTrack:(id)sender;

@end
