//
//  MFMPlayerViewController.m
//  Moe FM
//
//  Created by Greg Wang on 12-4-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MFMPlayerViewController.h"

@implementation MFMPlayerViewController

@synthesize songNameLable = _songNameLable;
@synthesize songArtistLabel = _songArtistLabel;
@synthesize songAlbumLabel = _songAlbumLabel;
@synthesize songTimeIndicator = _songTimeIndicator;
@synthesize songArtworkImage = _songArtworkImage;
@synthesize playOrPauseButton = _playOrPauseButton;
@synthesize favouriteButton = _favouriteButton;
@synthesize dislikeButton = _dislikeButton;
@synthesize nextButton = _nextButton;

#pragma mark - View lifecycle

- (void) viewDidLoad
{
	[super viewDidLoad];
}


@end
