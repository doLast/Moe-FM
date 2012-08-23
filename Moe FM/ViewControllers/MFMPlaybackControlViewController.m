//
//  MFMPlaybackControlViewController.m
//  Moe FM
//
//  Created by Greg Wang on 12-8-21.
//
//

#import "MFMPlaybackControlViewController.h"

#import "MFMResourceFav.h"
#import "MFMResourceSong.h"
#import "MFMPlayerManager.h"
#import "MFMOAuth.h"

@interface MFMPlaybackControlViewController ()

@end

@implementation MFMPlaybackControlViewController

@synthesize playButton = _playButton;
@synthesize favButton = _favButton;
@synthesize dislikeButton = _dislikeButton;
@synthesize nextButton = _nextButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:MFMPlayerSongChangedNotification object:[MFMPlayerManager sharedPlayerManager]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:MFMPlayerStatusChangedNotification object:[MFMPlayerManager sharedPlayerManager]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:MFMOAuthStatusChangedNotification object:[MFMOAuth sharedOAuth]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
		// Toggle like
		if ([currentSong.favSub didAddToFavAsType:MFMFavTypeHeart]) {
			self.favButton.selected = YES;
		}
		else {
			self.favButton.selected = NO;
		}
	}
}

- (void)updatePlaybackStatus
{
	MFMPlayerStatus status = [MFMPlayerManager sharedPlayerManager].playerStatus;
	switch (status) {
		case MFMPlayerStatusPlaying:
			self.playButton.selected = YES;
			break;
		case MFMPlayerStatusPaused:
			self.playButton.selected = NO;
			break;
		case MFMPlayerStatusWaiting:
			self.playButton.selected = YES;
			break;
		default:
			break;
	}
}

#pragma mark - Actions

- (IBAction)togglePlaybackState:(id)sender
{
	MFMPlayerManager *playerManager = [MFMPlayerManager sharedPlayerManager];
	if ([playerManager pause] == NO) {
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
