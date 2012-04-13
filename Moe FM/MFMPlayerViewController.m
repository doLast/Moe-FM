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

@interface MFMPlayerViewController ()
@property (retain, nonatomic) MoeFmPlayer *player;
@property (retain, nonatomic) MoeFmAPI *playlistAPI;
@property (retain, nonatomic) MoeFmAPI *imageAPI;

- (MoeFmAPI *)createAPI;

@end

@implementation MFMPlayerViewController

@synthesize songNameLable = _songNameLable;
@synthesize songInfoLabel = _songInfoLabel;
@synthesize songProgressIndicator = _songProgressIndicator;
@synthesize songArtworkImage = _songArtworkImage;

@synthesize player = _player;
@synthesize playlistAPI = _playlistAPI;
@synthesize imageAPI = _imageAPI;


#pragma mark - View lifecycle

- (void) viewDidLoad
{
	[super viewDidLoad];
	
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
}

- (void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

- (BOOL)canBecomeFirstResponder {
	return YES;
}

#pragma mark - View Updater



#pragma mark - MoeFmPlayer Delegates

- (void)player:(MoeFmPlayer *)player updateProgress:(float)percentage
{
	[self.songProgressIndicator setProgress:percentage animated:YES];
}

- (void)player:(MoeFmPlayer *)player updateMetadata:(NSDictionary *)metadata
{
	self.songNameLable.text = [metadata objectForKey:@"sub_title"];
	if([self.songNameLable.text length] == 0) {
		self.songNameLable.text = @"Unknown Song";
	}
	
	NSString *artist = [metadata objectForKey:@"artist"];
	if([artist length] == 0) {
		artist = @"Unknown Artist";
	}
	
	NSString *album = [metadata objectForKey:@"wiki_title"];
	if([album length] == 0) {
		album = @"Unknown Album";
	}
	
	self.songInfoLabel.text = [NSString stringWithFormat:@"%@ / %@", artist, album];
	
	NSString *imageAddress = [[metadata objectForKey:@"cover"] objectForKey:@"square"];
	NSURL *imageURL = [NSURL URLWithString:imageAddress];

	NSLog(@"Requesting image");
	BOOL status = [self.imageAPI requestImageWithURL:imageURL];
	if(status == NO){
		// Fail to establish connection
		NSLog(@"Unable to create connection for %@", imageURL);
	}
}

- (void)player:(MoeFmPlayer *)player needToUpdatePlaylist:(NSArray *)currentplaylist
{
	NSLog(@"Requesting playlist");
	BOOL status = [self.playlistAPI requestListenPlaylistWithPage:0];
	if(status == NO){
		// Fail to establish connection
		NSLog(@"Unable to create connection for playlist");
	}
}

- (void)player:(MoeFmPlayer *)player stateChangesTo:(AudioStreamerState)state
{
	switch (state) {
		case AS_WAITING_FOR_DATA:
			// TODO
			break;
		case AS_BUFFERING:
			// TODO
			break;
		case AS_PLAYING:
			// TODO
			break;
		case AS_PAUSED:
			// TODO
			break;
		case AS_STOPPED:
			// TODO
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
	[alert show];
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
	self.songArtworkImage.image = image;
}

- (void)api:(MoeFmAPI *)api requestFailedWithError:(NSError *)error
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[error localizedDescription] 
													message:[error localizedFailureReason] 
												   delegate:self 
										  cancelButtonTitle:@"OK" 
										  otherButtonTitles:nil];
	[alert show];
}

#pragma mark - Actions

- (IBAction)togglePlaybackState:(UIButton *)sender
{
	[self.player startOrPause];
}

- (IBAction)toggleFavourite:(UIButton *)sender
{
	
}

- (IBAction)toggleDislike:(UIButton *)sender
{
	
}

- (IBAction)nextTrack:(UIButton *)sender
{
	[self.player next];
}

#pragma mark - Remote Control Events
/* The iPod controls will send these events when the app is in the background */
- (void)remoteControlReceivedWithEvent:(UIEvent *)event 
{
	switch (event.subtype) {
		case UIEventSubtypeRemoteControlTogglePlayPause:
			[self.player startOrPause];
			break;
		case UIEventSubtypeRemoteControlPlay:
			[self.player start];
			break;
		case UIEventSubtypeRemoteControlPause:
			[self.player pause];
			break;
		case UIEventSubtypeRemoteControlStop:
			[self.player stop];
			break;
		case UIEventSubtypeRemoteControlNextTrack:
			[self.player next];
			break;
		case UIEventSubtypeRemoteControlPreviousTrack:
			[self.player previous];
			break;
		default:
			break;
	}
}

@end
