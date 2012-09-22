//
//  MFMPlayerViewController.m
//  Moe FM
//
//  Created by Greg Wang on 12-7-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MFMPlayerViewController.h"
#import "MFMHttpImageView.h"
#import "MFMReflectedImageView.h"
#import "PPRevealSideViewController.h"
#import "YRDropdownView.h"

#import "MFMPlayerManager.h"
#import "MFMResourceSong.h"
#import "MFMOAuth.h"

#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>

@interface MFMPlayerViewController () <MFMHttpImageViewDelegate>

@property (strong, nonatomic) NSTimer *progressTimer;

@end

@implementation MFMPlayerViewController

@synthesize songInfoView = _songInfoView;
@synthesize songNameLabel = _songNameLabel;
@synthesize songArtistLabel = _songArtistLabel;
@synthesize songAlbumLabel = _songAlbumLabel;
@synthesize songProgressIndicator = _songProgressIndicator;
@synthesize songArtworkImage = _songArtworkImage;
@synthesize songArtworkReflection = _songArtworkReflection;
@synthesize songArtworkLoadingIndicator = _songArtworkLoadingIndicator;
@synthesize songBufferingIndicator = _songBufferingIndicator;
@synthesize playButton = _playButton;

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
	
	self.songArtworkImage.delegate = self;
	self.songInfoView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BarLCD"]];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:MFMPlayerSongChangedNotification object:[MFMPlayerManager sharedPlayerManager]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:MFMPlayerStatusChangedNotification object:[MFMPlayerManager sharedPlayerManager]];
	
	[self updatePlaybackStatus];
	
	self.title = NSLocalizedString(@"CURRENT_PLAYING", @"");
	self.songNameLabel.text = @"";
	self.songArtistLabel.text = @"";
	self.songAlbumLabel.text = @"";
	
	// Hide Navigation bar
	[self.navigationController setNavigationBarHidden:YES animated:NO];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
	self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.157809 green:0.492767 blue:0.959104 alpha:1];
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
		self.title = self.songNameLabel.text;
		
		// Update Artist
		NSString *artist = currentSong.artist;
		if([artist length] == 0) {
			artist = NSLocalizedString(@"UNKNOWN_ARTIST", @"");;
		}
		[nowPlayingInfo setValue:artist forKey:MPMediaItemPropertyArtist];
		self.songArtistLabel.text = artist;
		
		// Update Album
		NSString *album = currentSong.wikiTitle;
		if([album length] == 0) {
			album = NSLocalizedString(@"UNKNOWN_ALBUM", @"");
		}
		[nowPlayingInfo setValue:album forKey:MPMediaItemPropertyAlbumTitle];
		self.songAlbumLabel.text = album;
		
//		self.songInfoLabel.text = [NSString stringWithFormat:@"%@ | %@", artist, album];
		
		// Post to NowPlayingInfoCenter
		[MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = nowPlayingInfo;
		
		// Update Artwork
		NSString *coverURLStr = [currentSong.cover objectForKey:@"large"];
		if (coverURLStr != nil) {
			[self.songArtworkLoadingIndicator startAnimating];
			self.songArtworkImage.imageURL = [NSURL URLWithString:coverURLStr];
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
			break;
		case MFMPlayerStatusError:
			NSLog(@"Player error: %@", [[MFMPlayerManager sharedPlayerManager].error localizedDescription]);
			[YRDropdownView showDropdownInView:self.navigationController.view title:@"Error" detail:[[MFMPlayerManager sharedPlayerManager].error localizedDescription] accessoryView:nil animated:YES hideAfter:0];
		case MFMPlayerStatusPaused:
			self.playButton.alpha = 0.2;
			[self.songBufferingIndicator stopAnimating];
			[self toggleTimer:NO];
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
		[playerManager play];
	}
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
			[[MFMPlayerManager sharedPlayerManager] next];
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
	
	self.songArtworkReflection.image = image;
	
	MPNowPlayingInfoCenter *nowPlayingInfoCenter = [MPNowPlayingInfoCenter defaultCenter];
	MPMediaItemArtwork *mediaItemArtwork = [[MPMediaItemArtwork alloc] initWithImage:image];
	NSMutableDictionary *newInfo = [NSMutableDictionary dictionaryWithDictionary:nowPlayingInfoCenter.nowPlayingInfo];
	[newInfo setValue:mediaItemArtwork forKey:MPMediaItemPropertyArtwork];
	nowPlayingInfoCenter.nowPlayingInfo = newInfo;
}

- (void)imageView:(MFMHttpImageView *)imageView didFailLoadingWithError:(NSError *)error
{
	[self.songArtworkLoadingIndicator stopAnimating];
}

#pragma mark - NotificationCenter

- (void)handleNotification:(NSNotification *)notification
{
	if (notification.name == MFMPlayerSongChangedNotification) {
		[self updateSongInfo];
	}
	else if (notification.name == MFMPlayerStatusChangedNotification) {
		[self updatePlaybackStatus];
	}
}

@end
