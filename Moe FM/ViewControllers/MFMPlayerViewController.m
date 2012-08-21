//
//  MFMPlayerViewController.m
//  Moe FM
//
//  Created by Greg Wang on 12-7-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MFMPlayerViewController.h"
#import "MFMHttpImageView.h"

#import "PPRevealSideViewController.h"
#import "MFMPlayerManager.h"
#import "MFMResourceSong.h"
#import "MFMOAuth.h"

#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>

@interface MFMPlayerViewController () <MFMHttpImageViewDelegate>

@property (strong, nonatomic) NSTimer *progressTimer;

@end

@implementation MFMPlayerViewController

@synthesize navTitle = _navTitle;
@synthesize songNameLabel = _songNameLabel;
@synthesize songInfoLabel = _songInfoLabel;
@synthesize songProgressIndicator = _songProgressIndicator;
@synthesize songArtworkImage = _songArtworkImage;
@synthesize songArtworkLoadingIndicator = _songArtworkLoadingIndicator;
@synthesize songBufferingIndicator = _songBufferingIndicator;
@synthesize playButton = _playButton;
@synthesize favButton = _favButton;
@synthesize favProcessingIndicator = _favProcessingIndicator;
@synthesize dislikeButton = _dislikeButton;
@synthesize nextButton = _nextButton;

@synthesize progressTimer = _progressTimer;

#pragma mark - view life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	
	// Allow application to recieve remote control
	UIApplication *application = [UIApplication sharedApplication];
	if([application respondsToSelector:@selector(beginReceivingRemoteControlEvents)])
		[application beginReceivingRemoteControlEvents];
	[self becomeFirstResponder]; // this enables listening for events
	
	// Decorate the songArtworkImage
//	CALayer *layer = self.songArtworkImage.layer;
//    [layer setBorderColor: [[UIColor whiteColor] CGColor]];
//    [layer setBorderWidth:4.0f];
//    [layer setShadowColor: [[UIColor blackColor] CGColor]];
//    [layer setShadowOpacity:0.5f];
//    [layer setShadowOffset: CGSizeMake(1, 3)];
//    [layer setShadowRadius:2.0];
//    [self.songArtworkImage setClipsToBounds:NO];
	self.songArtworkImage.delegate = self;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:MFMPlayerSongChangedNotification object:[MFMPlayerManager sharedPlayerManager]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:MFMPlayerStatusChangedNotification object:[MFMPlayerManager sharedPlayerManager]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:MFMOAuthStatusChangedNotification object:[MFMOAuth sharedOAuth]];
	
	[self updatePlaybackStatus];
	[self updateAuthorization];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)canBecomeFirstResponder
{
	return YES;
}

#pragma mark - view updates

- (void)updateAuthorization
{
	if ([MFMOAuth sharedOAuth].canAuthorize) {
		self.favButton.enabled = YES;
		self.dislikeButton.enabled = YES;
	}
	else {
		self.favButton.enabled = NO;
		self.dislikeButton.enabled = NO;
	}
}

- (void)updateSongInfo
{
	MFMResourceSong *currentSong = [MFMPlayerManager sharedPlayerManager].currentSong;
	if (currentSong != nil) {
		NSMutableDictionary *nowPlayingInfo = [NSMutableDictionary dictionary];
		
		// Update Song Title
		self.songNameLabel.text = currentSong.subTitle;
		if([self.songNameLabel.text length] == 0) {
			self.songNameLabel.text = NSLocalizedString(@"UNKNOWN_SONG", @"");
		}
		[nowPlayingInfo setValue:self.songNameLabel.text forKey:MPMediaItemPropertyTitle];
		
		// Update Artist
		NSString *artist = currentSong.artist;
		if([artist length] == 0) {
			artist = NSLocalizedString(@"UNKNOWN_ARTIST", @"");;
		}
		[nowPlayingInfo setValue:artist forKey:MPMediaItemPropertyArtist];
		
		// Update Album
		NSString *album = currentSong.wikiTitle;
		if([album length] == 0) {
			album = NSLocalizedString(@"UNKNOWN_ALBUM", @"");
		}
		[nowPlayingInfo setValue:album forKey:MPMediaItemPropertyAlbumTitle];
		
		self.songInfoLabel.text = [NSString stringWithFormat:@"%@ | %@", artist, album];
		
		// Post to NowPlayingInfoCenter
		[MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = nowPlayingInfo;
		
		// Update Artwork
		NSString *coverURLStr = [currentSong.cover objectForKey:@"large"];
		if (coverURLStr != nil) {
			self.songArtworkImage.imageURL = [NSURL URLWithString:coverURLStr];
			[self.songArtworkLoadingIndicator startAnimating];
		}
		
		// Toggle like
		if ([currentSong.favSub didAddToFavAsType:MFMFavTypeHeart]) {
			self.favButton.selected = YES;
		}
		else {
			self.favButton.selected = NO;
		}
	}
}

- (void)updateProgress
{
	MFMPlayerManager *playerManager = [MFMPlayerManager sharedPlayerManager];
	double percentage = playerManager.progress / playerManager.duration;
	[self.songProgressIndicator setProgress:percentage animated:YES];
}

- (void)updatePlaybackStatus
{
	MFMPlayerStatus status = [MFMPlayerManager sharedPlayerManager].playerStatus;
	switch (status) {
		case MFMPlayerStatusPlaying:
			self.playButton.alpha = 0;
			[self.songBufferingIndicator stopAnimating];
			[self toggleTimer:YES];
			[self.navigationController setNavigationBarHidden:YES animated:YES];
			break;
		case MFMPlayerStatusPaused:
			self.playButton.alpha = 0.5;
			[self.songBufferingIndicator stopAnimating];
			[self toggleTimer:NO];
			[self.navigationController setNavigationBarHidden:NO animated:YES];
			break;
		case MFMPlayerStatusWaiting:
			self.playButton.alpha = 0;
			[self.songBufferingIndicator startAnimating];
			break;
		default:
			break;
	}
}

- (void)toggleTimer:(BOOL)create
{
	if (create) {
		if (self.progressTimer) {
			[self toggleTimer:NO];
		}
		self.progressTimer =
		[NSTimer
		 scheduledTimerWithTimeInterval:0.5
		 target:self
		 selector:@selector(updateProgress)
		 userInfo:nil
		 repeats:YES];
	}
	else {
		if (self.progressTimer)
		{
			[self.progressTimer invalidate];
			self.progressTimer = nil;
		}
	}
}

#pragma mark - Actions

- (IBAction)showMenu:(id)sender
{
	PPRevealSideViewController *revealSideViewController = (PPRevealSideViewController *)self.navigationController.parentViewController;
	[revealSideViewController pushOldViewControllerOnDirection:PPRevealSideDirectionTop withOffset:53 animated:YES];
}

- (IBAction)togglePlaybackState:(id)sender
{
	MFMPlayerManager *playerManager = [MFMPlayerManager sharedPlayerManager];
	if ([playerManager pause] == NO) {
		NSLog(@"Toggle to Play");
		[playerManager play];
	}
}

- (IBAction)toggleFavourite:(id)sender
{
	self.favButton.enabled = NO;
	MFMResourceFav *favSub = [MFMPlayerManager sharedPlayerManager].currentSong.favSub;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:MFMResourceNotification object:favSub];
	[favSub toggleFavAsType:MFMFavTypeHeart];
}

- (IBAction)toggleDislike:(id)sender
{
	MFMResourceFav *favSub = [MFMPlayerManager sharedPlayerManager].currentSong.favSub;
	[favSub toggleFavAsType:MFMFavTypeTrash];
	[self nextTrack:self];
}

- (IBAction)nextTrack:(id)sender
{
	MFMPlayerManager *playerManager = [MFMPlayerManager sharedPlayerManager];
	[playerManager next];
}

/* The iPod controls will send these events when the app is in the background */
- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
	switch (event.subtype) {
		case UIEventSubtypeRemoteControlTogglePlayPause:
			[self togglePlaybackState:self];
			break;
		case UIEventSubtypeRemoteControlPlay:
			[self togglePlaybackState:self];
			break;
		case UIEventSubtypeRemoteControlPause:
			[self togglePlaybackState:self];
			break;
		case UIEventSubtypeRemoteControlStop:
			break;
		case UIEventSubtypeRemoteControlNextTrack:
			[self nextTrack:self];
			break;
		case UIEventSubtypeRemoteControlPreviousTrack:
			break;
		default:
			break;
	}
}

#pragma mark - MFMHttpImageViewDelegate

- (void)imageView:(MFMHttpImageView *)imageView didFinishLoadingImage:(UIImage *)image
{
	[self.songArtworkLoadingIndicator stopAnimating];
	
	MPNowPlayingInfoCenter *nowPlayingInfoCenter = [MPNowPlayingInfoCenter defaultCenter];
	MPMediaItemArtwork *mediaItemArtwork = [[MPMediaItemArtwork alloc] initWithImage:image];
	NSMutableDictionary *newInfo = [NSMutableDictionary dictionaryWithDictionary:nowPlayingInfoCenter.nowPlayingInfo];
	[newInfo setValue:mediaItemArtwork forKey:MPMediaItemPropertyArtwork];
	nowPlayingInfoCenter.nowPlayingInfo = newInfo;
}

- (void)imageView:(MFMHttpImageView *)imageView didFailLoadingURL:(NSURL *)url
{
	[self.songArtworkLoadingIndicator stopAnimating];
}

#pragma mark - NotificationCenter

- (void)handleNotification:(NSNotification *)notification
{
	if (notification.name == MFMPlayerSongChangedNotification) {
		[self updateSongInfo];
		[self updateAuthorization];
	}
	else if (notification.name == MFMPlayerStatusChangedNotification) {
		[self updatePlaybackStatus];
	}
	else if (notification.name == MFMOAuthStatusChangedNotification) {
		[self updateAuthorization];
	}
	else if (notification.name == MFMResourceNotification) {
		[self updateSongInfo];
		[self updateAuthorization];

		[[NSNotificationCenter defaultCenter] removeObserver:self name:MFMResourceNotification object:notification.object];
	}
}

@end
