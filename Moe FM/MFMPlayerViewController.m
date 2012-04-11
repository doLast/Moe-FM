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
@property (retain, nonatomic) MoeFmAPI *api;
@property (retain, nonatomic) MoeFmPlayer *player;

@end

@implementation MFMPlayerViewController

@synthesize songNameLable = _songNameLable;
@synthesize songArtistLabel = _songArtistLabel;
@synthesize songAlbumLabel = _songAlbumLabel;
@synthesize songProgressIndicator = _songProgressIndicator;
@synthesize songArtworkImage = _songArtworkImage;

@synthesize api = _api;
@synthesize player = _player;


#pragma mark - View lifecycle

- (void) viewDidLoad
{
	[super viewDidLoad];
	
	UIApplication *application = [UIApplication sharedApplication];
	if([application respondsToSelector:@selector(beginReceivingRemoteControlEvents)])
		[application beginReceivingRemoteControlEvents];
	[self becomeFirstResponder]; // this enables listening for events
}

- (void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	if(!self.api){
		self.api = [[MoeFmAPI alloc] initWithApiKey:@"302182858672af62ebf4524ee8d9a06304f7db527"];
	}
	
	NSArray *playlist = [self.api getListenPlaylistWithPage:0];
	
	if(!self.player){
		self.player = [[MoeFmPlayer alloc] initWithPlaylist:playlist delegate:self];
	}
}

- (BOOL)canBecomeFirstResponder {
	return YES;
}

#pragma mark - View Updater



#pragma mark - MoeFmPlayer Delegates

- (void)updateProgressIndicator:(float)percentage
{
	[self.songProgressIndicator setProgress:percentage animated:YES];
}

- (void)updateMetadate:(NSDictionary *)metadata{
	self.songNameLable.text = [metadata objectForKey:@"sub_title"];
	if([self.songNameLable.text length] == 0) {
		self.songNameLable.text = @"Unknown Song";
	}
	
	self.songArtistLabel.text = [metadata objectForKey:@"artist"];
	if([self.songArtistLabel.text length] == 0) {
		self.songArtistLabel.text = @"Unknown Artist";
	}
	
	self.songAlbumLabel.text = [metadata objectForKey:@"wiki_title"];
	if([self.songAlbumLabel.text length] == 0) {
		self.songAlbumLabel.text = @"Unknown Album";
	}
	
	NSString *imageAddress = [[metadata objectForKey:@"cover"] objectForKey:@"square"];
	NSURL *imageURL = [NSURL URLWithString:imageAddress];
	NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
	self.songArtworkImage.image = [UIImage imageWithData:imageData];
}

- (NSArray *)getNewPlaylist{
	NSArray *playlist = [self.api getListenPlaylistWithPage:0];
	return playlist;
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
- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
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
		default:
			break;
	}
}

@end
