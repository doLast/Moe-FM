//
//  MFMPlayerManager.m
//  Moe FM
//
//  Created by Greg Wang on 12-7-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MFMPlayerManager.h"
#import "AudioStreamer.h"
#import "MFMResourcePlaylist.h"
#import "MFMResourceSong.h"

NSString * const MFMPlayerStatusChangedNotification = @"MFMPlayerStatusChangedNotification";
NSString * const MFMPlayerSongChangedNotification = @"MFMPlayerSongChangedNotification";

@interface MFMPlayerManager ()

@property (retain, atomic) MFMResourcePlaylist *playlist;
@property (assign, atomic) NSUInteger trackNum;
@property (retain, nonatomic) AudioStreamer *audioStreamer;
//@property (retain, nonatomic) AudioStreamer *lastStreamer;

@end

@implementation MFMPlayerManager

#pragma mark - getter & setter
@synthesize nextPlaylist = _nextPlaylist;
@synthesize nextTrackNum = _nextTrackNum;
@synthesize playerStatus = _playerStatus;

@synthesize playlist = _playlist;
@synthesize trackNum = _trackNum;
@synthesize audioStreamer = _audioStreamer;

- (MFMResourceSong *)currentSong
{
	if (self.playlist == nil || self.playlist.resourceSongs == nil) {
		return nil;
	}
	return [self.playlist.resourceSongs objectAtIndex:self.trackNum];
}

- (void)setPlayerStatus:(MFMPlayerStatus)playerStatus
{
	if (_playerStatus != playerStatus) {
		_playerStatus = playerStatus;
		[[NSNotificationCenter defaultCenter]
		 postNotificationName:MFMPlayerStatusChangedNotification object:self];
	}
}

- (double)progress
{
	if (self.audioStreamer) {
		return self.audioStreamer.progress;
	}
	return 0;
}

- (double)duration
{
	if (self.audioStreamer) {
		return self.audioStreamer.duration;
	}
	return 0;
}

#pragma mark - initializations
+ (MFMPlayerManager *)sharedPlayerManager
{
	static MFMPlayerManager *playerManager;
	if (playerManager == nil) {
		playerManager = [[MFMPlayerManager alloc] init];
		// Give it a magic playlist to begin
		MFMResourcePlaylist *resourcePlaylist = [MFMResourcePlaylist magicPlaylist];
		playerManager.nextPlaylist = resourcePlaylist;
		playerManager.nextTrackNum = 0;
		[playerManager start];
	}
	return playerManager;
}

- (MFMPlayerManager *)init
{
	self = [super init];
	if (self != nil) {
		self.nextPlaylist = nil;
		self.nextTrackNum = 0;
		self.playlist = nil;
		self.trackNum = 0;
		self.audioStreamer = nil;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:ASStatusChangedNotification object:nil];
	}
	return self;
}

#pragma mark - Player controls

- (AudioStreamer *)streamerWithURL:(NSURL *)url
{
	AudioStreamer *streamer = [[AudioStreamer alloc] initWithURL:url];
	// Do extra config to the streamer if needed
	return streamer;
}

- (void)createStreamer
{
	if (self.audioStreamer != nil)
	{
		return;
	}
	[self destroyStreamer];
	
	NSLog(@"Creating streamer");
	
	NSURL *url = self.currentSong.streamURL;
	self.audioStreamer = [self streamerWithURL:url];
}

- (void)destroyStreamer
{
	if (self.audioStreamer != nil)
	{
		NSLog(@"Destroying streamer");
		AudioStreamer *streamer = self.audioStreamer;
		self.audioStreamer = nil;
		[streamer stop];
	}
}

- (void)prepareTrack
{
	self.trackNum = self.nextTrackNum;
	return;
}

- (void)preparePlaylist
{
	// Set playlist
	self.playlist = self.nextPlaylist;
	self.nextPlaylist = nil;
	
	// If nil playlist
	if (self.playlist == nil) {
		NSLog(@"Got nil playlist");
	}
	else {
		// Got new playlist, prepare to fetch resource
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:MFMResourceNotification object:self.playlist];
		
		// If start failed
		if ([self.playlist startFetch] == NO) {
			NSLog(@"Fail to start fetching");
			[[NSNotificationCenter defaultCenter] removeObserver:self name:MFMResourceNotification object:self.playlist];
			self.playlist = nil;
		}
		else {
			NSLog(@"Waiting for Playlist to ready");
		}
	}
}

- (BOOL)start
{
	if (self.nextPlaylist != nil && self.nextPlaylist != self.playlist) {
		[self stop];
		[self preparePlaylist];
		[self prepareTrack];
		return YES;
	}
	else if (self.nextTrackNum != self.trackNum) {
		[self stop];
		[self prepareTrack];
		[self play];
		return YES;
	}
	return NO;
}

- (BOOL)play
{
	// If no resource
	if (self.playlist.resourceSongs == nil) {
		// Wait for resource to load
		return NO;
	}
	
	// If no more song
	if (self.trackNum >= self.playlist.resourceSongs.count) {
		if ([self.playlist.mayHaveNext boolValue]) {
			NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@&", self.playlist.nextURL]];
			self.nextPlaylist = [[MFMResourcePlaylist alloc] initWithURL:url];
			self.nextTrackNum = 0;
			[self start];
		}
		return NO;
	}
	
	// If have song and no streamer
	if (self.audioStreamer == nil) {
		[self createStreamer];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:MFMPlayerSongChangedNotification object:self];
	}
	
//	if ([self.audioStreamer start] == NO) {
//		return [self.audioStreamer play];
//	}
	[self.audioStreamer start];
	
	return YES;
//	return [self.audioStreamer isPlaying] || [self.audioStreamer isWaiting];
}

- (BOOL)pause
{
	[self.audioStreamer pause];
	return YES;
}

- (void)next
{
	if (self.playlist != nil && self.playlist.resourceSongs != nil) {
		self.nextTrackNum = self.trackNum + 1;
		[self start];
	}
}

- (void)stop
{
	[self destroyStreamer];
}

#pragma mark - NotificationCenter

- (void)handleNotification:(NSNotification *)notification
{
	if (notification.name == MFMResourceNotification) {
		[self handleNotificationFromResource:notification.object];
	}
	else if (notification.name == ASStatusChangedNotification) {
		[self handleNotificationFromStreamer:notification.object];
	}
}

- (void)handleNotificationFromResource:(MFMResource *)resource
{
	if (resource == self.playlist) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:MFMResourceNotification object:self.playlist];
		if (self.playlist.error == nil) {
			[self play];
		}
		else {
			NSLog(@"Fail to obtain the playlist, error: %@", [self.playlist.error localizedDescription]);
			self.playlist = nil;
		}
	}
}

- (void)handleNotificationFromStreamer:(AudioStreamer *)streamer
{
	if (streamer == self.audioStreamer) {
		if (streamer.errorCode != AS_NO_ERROR) {
			// handle the error via a UI, retrying the stream, etc.
			NSLog(@"Streamer error: %@", [AudioStreamer stringForErrorCode:streamer.errorCode]);
			self.playerStatus = MFMPlayerStatusPaused;
			[self next];
		} else if ([streamer isPlaying]) {
			NSLog(@"Is Playing");
			self.playerStatus = MFMPlayerStatusPlaying;
		} else if ([streamer isPaused]) {
			NSLog(@"Is Paused");
			self.playerStatus = MFMPlayerStatusPaused;
		} else if ([streamer isIdle]) {
			NSLog(@"Is Idle");
			self.playerStatus = MFMPlayerStatusPaused;
			[self next];
		} else if ([streamer isWaiting]){
			// stream is waiting for data, probably nothing to do
			NSLog(@"Is Waiting");
			self.playerStatus = MFMPlayerStatusWaiting;
		}
	}
}

@end
