//
//  MFMPlayerViewController.m
//  Moe FM
//
//  Created by Greg Wang on 12-4-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MFMPlayerViewController.h"
#import "MoeFmAPI.h"
#import "MoeFmPlayer.h"
#import "Reachability.h"

#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>

typedef enum {
	MFMPVC_NETWORK_ALERT = 0, 
	MFMPVC_PLAYER_ERR_ALERT,
	MFMPVC_REQUEST_ERR_ALERT
} MFMPlayerViewAlertTags;

@interface MFMPlayerViewController ()
@property (retain, nonatomic) MoeFmPlayer *player;
@property (retain, nonatomic) MoeFmAPI *playlistAPI;
@property (retain, nonatomic) MoeFmAPI *imageAPI;

@property (retain, nonatomic) Reachability *internetReachability;

- (MoeFmAPI *)createAPI;

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
@synthesize dislikeButton = _dislikeButton;
@synthesize nextButton = _nextButton;

@synthesize player = _player;
@synthesize playlistAPI = _playlistAPI;
@synthesize imageAPI = _imageAPI;

@synthesize internetReachability = _internetReachability;


#pragma mark - View lifecycle

- (void) viewDidLoad
{
	[super viewDidLoad];
	
	self.navTitle.title = NSLocalizedString(@"APP_NAME", @"");
	
	// Allow application to recieve remote control
	UIApplication *application = [UIApplication sharedApplication];
	if([application respondsToSelector:@selector(beginReceivingRemoteControlEvents)])
		[application beginReceivingRemoteControlEvents];
	[self becomeFirstResponder]; // this enables listening for events
	
	// Create APIs
	if(!self.playlistAPI){
		self.playlistAPI = [self createAPI];
	}
	if(!self.imageAPI){
		self.imageAPI = [self createAPI];
	}
	
	// Create player
	if(!self.player){
		self.player = [[MoeFmPlayer alloc] initWithDelegate:self];
	}
	
	// Internet Reachability Notifications
	self.internetReachability = [Reachability reachabilityForInternetConnection];
	[self.internetReachability startNotifier];
	[self updateReachability:self.internetReachability];
	
	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
	
    /*
	// Decorate the songArtworkImage
	CALayer *layer = self.songArtworkImage.layer;
    [layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [layer setBorderWidth:8.0f];
    [layer setShadowColor: [[UIColor blackColor] CGColor]];
    [layer setShadowOpacity:0.9f];
    [layer setShadowOffset: CGSizeMake(1, 3)];
    [layer setShadowRadius:4.0];
    [self.songArtworkImage setClipsToBounds:NO];
    */
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self resetMetadataView];
}

- (void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[self start];
}

- (BOOL)canBecomeFirstResponder {
	return YES;
}

#pragma mark - View Updater

- (void) updateMetadata:(NSDictionary *)metadata
{
	NSMutableDictionary *nowPlayingInfo = [NSMutableDictionary dictionary];
	
	// Update Song Title
	self.songNameLabel.text = [metadata objectForKey:@"sub_title"];
	if([self.songNameLabel.text length] == 0) {
		self.songNameLabel.text = NSLocalizedString(@"UNKNOWN_SONG", @"");
	}
	[nowPlayingInfo setValue:self.songNameLabel.text forKey:MPMediaItemPropertyTitle];
	
	// Update Artist
	NSString *artist = [metadata objectForKey:@"artist"];
	if([artist length] == 0) {
		artist = NSLocalizedString(@"UNKNOWN_ARTIST", @"");;
	}
	[nowPlayingInfo setValue:artist forKey:MPMediaItemPropertyArtist];
	
	// Update Album
	NSString *album = [metadata objectForKey:@"wiki_title"];
	if([album length] == 0) {
		album = NSLocalizedString(@"UNKNOWN_ALBUM", @"");
	}
	[nowPlayingInfo setValue:album forKey:MPMediaItemPropertyAlbumTitle];
	
	self.songInfoLabel.text = [NSString stringWithFormat:@"%@ / %@", artist, album];
    
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0) {
        // Post to NowPlayingInfoCenter
        [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = nowPlayingInfo;
    }
	
	// Update image async
	NSString *coverSize = nil;
	if(self.internetReachability.currentReachabilityStatus == ReachableViaWiFi){
		coverSize = @"large";
	}
	else {
		coverSize = @"square";
	}
	NSString *imageAddress = [[metadata objectForKey:@"cover"] objectForKey:coverSize];
	NSURL *imageURL = [NSURL URLWithString:imageAddress];
	
	NSLog(@"Requesting image");
	if(self.imageAPI.isBusy){
		[self.imageAPI cancelRequest];
		NSLog(@"Image API request canceled");
	}
	
	BOOL status = [self.imageAPI requestImageWithURL:imageURL];
	if(status == NO){
		// Fail to establish connection
		NSLog(@"Unable to create connection for %@", imageURL);
	}
	else {
		[self.songArtworkLoadingIndicator startAnimating];
	}
}

- (void) updateArtworkWithImage:(UIImage *)image
{
	self.songArtworkImage.image = image;
	[self.songArtworkLoadingIndicator stopAnimating];
		
	
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0) {
        MPMediaItemArtwork *mediaItemArtwork = [[MPMediaItemArtwork alloc] initWithImage:image];
        MPNowPlayingInfoCenter *nowPlayingInfoCenter = [MPNowPlayingInfoCenter defaultCenter];
        NSMutableDictionary *newInfo = [NSMutableDictionary dictionaryWithDictionary:nowPlayingInfoCenter.nowPlayingInfo];
        [newInfo setValue:mediaItemArtwork forKey:MPMediaItemPropertyArtwork];
        nowPlayingInfoCenter.nowPlayingInfo = newInfo;
	}
}

- (void) resetMetadataView
{
	self.songNameLabel.text = NSLocalizedString(@"DEFAULT_SONG", @"");;
	self.songInfoLabel.text = NSLocalizedString(@"DEFAULT_INFO_LABEL", @"");;
	self.songArtworkImage.image = [UIImage imageNamed:@"cover_large.png"];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0) {
        [self.songProgressIndicator setProgress:1 animated:YES];//ios5
    }
}

#pragma mark - Player Controls

- (void)start{
	[self.player start];
}

- (void)pause{
	[self.player pause];
}

- (void)startOrPause{
	[self.player startOrPause];
}

- (void)stop{
	[self.player stop];
}

- (void)next{
	[self.player next];
}

- (void)previous{
	[self.player previous];
}

#pragma mark - Actions

- (IBAction)togglePlaybackState:(UIButton *)sender
{
	[self startOrPause];
}

- (IBAction)toggleFavourite:(UIButton *)sender
{
	// TODO
}

- (IBAction)toggleDislike:(UIButton *)sender
{
	// TODO
}

- (IBAction)nextTrack:(UIButton *)sender
{
	[self next];
}

/* The iPod controls will send these events when the app is in the background */
- (void)remoteControlReceivedWithEvent:(UIEvent *)event 
{
	switch (event.subtype) {
		case UIEventSubtypeRemoteControlTogglePlayPause:
			[self startOrPause];
			break;
		case UIEventSubtypeRemoteControlPlay:
			[self start];
			break;
		case UIEventSubtypeRemoteControlPause:
			[self pause];
			break;
		case UIEventSubtypeRemoteControlStop:
			[self stop];
			break;
		case UIEventSubtypeRemoteControlNextTrack:
			[self next];
			break;
		case UIEventSubtypeRemoteControlPreviousTrack:
			[self previous];
			break;
		default:
			break;
	}
}

#pragma mark - Network Reachability

//Called by Reachability whenever status changes.
- (void) reachabilityChanged: (NSNotification* )note
{
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
	
	[self updateReachability:curReach];
}

- (void) updateReachability:(Reachability *)curReach
{
	NetworkStatus networkStatus = [curReach currentReachabilityStatus];
	
	if(networkStatus == ReachableViaWWAN){
		[self toggleNetworkAccess:NO];
		UIAlertView *alert = 
		[[UIAlertView alloc] 
		 initWithTitle:NSLocalizedString(@"USE_CELLULAR_ALERT_TITLE", @"")
		 message:NSLocalizedString(@"USE_CELLULAR_ALERT_MSG", @"") 
		 delegate:self 
		 cancelButtonTitle:NSLocalizedString(@"ALERT_NO", @"")
		 otherButtonTitles:NSLocalizedString(@"ALERT_YES", @""), nil];
		alert.tag = MFMPVC_NETWORK_ALERT;
		[alert show];
	}
	else if(networkStatus == ReachableViaWiFi){
		[self toggleNetworkAccess:YES];
	}
	else {
		[self toggleNetworkAccess:YES];
	}
}

- (void) toggleNetworkAccess:(BOOL)allow
{
	self.player.allowNetworkAccess = allow;
	self.playlistAPI.allowNetworkAccess = allow;
	self.imageAPI.allowNetworkAccess = allow;
	// Add more if necessary
	NSLog(@"Toggling Network Access to %d", allow);
}

#pragma mark - MoeFmPlayer Delegates

- (void)player:(MoeFmPlayer *)player needToUpdatePlaylist:(NSArray *)currentplaylist
{
	NSLog(@"Requesting playlist");
	if(self.playlistAPI.isBusy){
		NSLog(@"Playlist API is busy, try again later");
		return;
	}
	
	BOOL status = [self.playlistAPI requestListenPlaylistWithPage:0];
	if(status == NO){
		// Fail to establish connection
		NSLog(@"Unable to create connection for playlist");
	}
}

- (void)player:(MoeFmPlayer *)player updateProgress:(float)percentage
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0) {
	[self.songProgressIndicator setProgress:percentage animated:YES];//ios5
    }
}

- (void)player:(MoeFmPlayer *)player updateMetadata:(NSDictionary *)metadata
{
	[self updateMetadata:metadata];
}

- (void)player:(MoeFmPlayer *)player stateChangesTo:(AudioStreamerState)state
{
	switch (state) {
		case AS_WAITING_FOR_DATA:
			self.playButton.alpha = 1;
            self.playButton.imageView.image = [UIImage imageNamed:@"pause.png"];
			[self.songBufferingIndicator startAnimating];
			break;
		case AS_BUFFERING:
            self.playButton.imageView.image = [UIImage imageNamed:@"pause.png"];
			self.playButton.alpha = 1;
			[self.songBufferingIndicator startAnimating];
			break;
		case AS_PLAYING:
			self.playButton.alpha = 1;
            self.playButton.imageView.image = [UIImage imageNamed:@"pause.png"];
			[self.songBufferingIndicator stopAnimating];
			break;
		case AS_PAUSED:
			self.playButton.alpha = 1;
            self.playButton.imageView.image = [UIImage imageNamed:@"play.png"];
			[self.songBufferingIndicator stopAnimating];
			break;
		case AS_STOPPED:
            self.playButton.imageView.image = [UIImage imageNamed:@"play.png"];
			self.playButton.alpha = 1;
			[self.songBufferingIndicator stopAnimating];
			break;
			
		default:
			break;
	}
}

- (void)player:(MoeFmPlayer *)player stoppingWithError:(NSString *)error
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:error
													message:nil
												   delegate:self 
										  cancelButtonTitle:@"OK" 
										  otherButtonTitles:nil];
	alert.tag = MFMPVC_PLAYER_ERR_ALERT;
	[alert show];
}

- (void)player:(MoeFmPlayer *)player needNetworkAccess:(BOOL)allow
{
	if(allow){
		[self updateReachability:self.internetReachability];
	}
}

#pragma mark - MoeFmAPI Delegates

- (MoeFmAPI *)createAPI
{
	return [[MoeFmAPI alloc] initWithApiKey:@"302182858672af62ebf4524ee8d9a06304f7db527"
								   delegate:self];
}

- (void)api:(MoeFmAPI *)api readyWithPlaylist:(NSArray *)playlist
{
	[self.player setPlaylist:playlist];
}

- (void)api:(MoeFmAPI *)api readyWithImage:(UIImage *)image
{
	[self updateArtworkWithImage:image];
}

- (void)api:(MoeFmAPI *)api requestFailedWithError:(NSError *)error
{
	UIAlertView *alert = 
	[[UIAlertView alloc] initWithTitle:[error localizedDescription] 
							   message:[error localizedFailureReason] 
							  delegate:self 
					 cancelButtonTitle:NSLocalizedString(@"ALERT_YES", @"") 
					 otherButtonTitles:nil];
	alert.tag = MFMPVC_REQUEST_ERR_ALERT;
	[alert show];
}

- (void)api:(MoeFmAPI *)api needNetworkAccess:(BOOL)allow
{
	if(allow){
		[self updateReachability:self.internetReachability];
	}
}

#pragma mark - Alert View Delegate

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
	if(alertView.tag == MFMPVC_NETWORK_ALERT){
		if (buttonIndex == 1) {
			[self toggleNetworkAccess:YES];
		}
		else {
			[self toggleNetworkAccess:NO];
		}
	}
}


@end
