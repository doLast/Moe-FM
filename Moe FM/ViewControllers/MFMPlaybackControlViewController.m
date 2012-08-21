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

@synthesize playButtonR = _playButtonR;
@synthesize favButtonR = _favButtonR;
@synthesize dislikeButtonR = _dislikeButtonR;
@synthesize nextButtonR = _nextButtonR;
@synthesize playButtonL = _playButtonL;
@synthesize favButtonL = _favButtonL;
@synthesize dislikeButtonL = _dislikeButtonL;
@synthesize nextButtonL = _nextButtonL;

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
		self.favButtonR.enabled = YES;
		self.dislikeButtonR.enabled = YES;
		self.favButtonL.enabled = YES;
		self.dislikeButtonL.enabled = YES;
	}
	else {
		self.favButtonR.enabled = NO;
		self.dislikeButtonR.enabled = NO;
		self.favButtonL.enabled = NO;
		self.dislikeButtonL.enabled = NO;
	}
}

- (void)updateSongInfo
{
	MFMResourceSong *currentSong = [MFMPlayerManager sharedPlayerManager].currentSong;
	if (currentSong != nil) {
		// Toggle like
		if ([currentSong.favSub didAddToFavAsType:MFMFavTypeHeart]) {
			self.favButtonR.selected = YES;
			self.favButtonL.selected = YES;
		}
		else {
			self.favButtonR.selected = NO;
			self.favButtonL.selected = NO;
		}
	}
}

- (void)updatePlaybackStatus
{
	MFMPlayerStatus status = [MFMPlayerManager sharedPlayerManager].playerStatus;
	switch (status) {
		case MFMPlayerStatusPlaying:
			self.playButtonR.selected = YES;
			self.playButtonL.selected = YES;
			break;
		case MFMPlayerStatusPaused:
			self.playButtonR.selected = NO;
			self.playButtonL.selected = NO;
			break;
		case MFMPlayerStatusWaiting:
			self.playButtonR.selected = YES;
			self.playButtonL.selected = YES;
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
	self.favButtonR.enabled = NO;
	self.favButtonL.enabled = NO;
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
