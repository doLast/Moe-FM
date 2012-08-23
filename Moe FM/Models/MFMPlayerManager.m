//
//  MFMPlayerManager.m
//  Moe FM
//
//  Created by Greg Wang on 12-7-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MFMPlayerManager.h"
#import "MFMNetworkManager.h"
#import "AudioStreamer.h"

#import "MFMResourcePlaylist.h"
#import "MFMResourceSong.h"

NSString * const MFMPlayerErrorDomain = @"MFMPlayerErrorDomain";
NSString * const MFMPlayerStatusChangedNotification = @"MFMPlayerStatusChangedNotification";
NSString * const MFMPlayerSongChangedNotification = @"MFMPlayerSongChangedNotification";

@interface MFMPlayerManager ()

@property (retain, nonatomic) AudioStreamer *audioStreamer;
@property (nonatomic) MFMPlayerStatus playerStatus;
@property (nonatomic, strong) NSError *error;

@end

@implementation MFMPlayerManager

#pragma mark - getter & setter
@synthesize audioStreamer = _audioStreamer;

@synthesize playlist = _playlist;
@synthesize trackNum = _trackNum;
@synthesize playerStatus = _playerStatus;
@synthesize error = _error;

- (void)setPlaylist:(MFMResourcePlaylist *)playlist
{
	if (playlist != nil && playlist != _playlist) {
		_playlist = playlist;
		self.trackNum = 0;
	}
}

- (void)setTrackNum:(NSUInteger)trackNum
{
	_trackNum = trackNum;
	[self start];
}

- (MFMResourceSong *)currentSong
{
	if (self.playlist == nil || [self.playlist count] == 0) {
		return nil;
	}
	return [self.playlist objectAtIndex:self.trackNum];
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
	static MFMPlayerManager *playerManager = nil;
	if (playerManager == nil) {
		playerManager = [[MFMPlayerManager alloc] init];
		// Give it a magic playlist to begin
		MFMResourcePlaylist *resourcePlaylist = [MFMResourcePlaylist magicPlaylist];
		playerManager.playlist = resourcePlaylist;
	}
	return playerManager;
}

- (MFMPlayerManager *)init
{
	self = [super init];
	if (self != nil) {
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

- (BOOL)start
{
	if (self.playlist == nil) {
		return NO;
	}
	
	[self stop];
	
	// If no more song
	if ([self.playlist objectAtIndex:self.trackNum] == nil) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:MFMResourceNotification object:self.playlist];
		// If start failed
		if ([self.playlist loadObjectAtIndex:self.trackNum] == NO) {
			[[NSNotificationCenter defaultCenter] removeObserver:self name:MFMResourceNotification object:self.playlist];
			self.trackNum = 0;
			return YES;
		}
		
		NSLog(@"Waiting for Playlist to ready");
		return YES;
	}
	
	return [self play];
}

- (BOOL)play
{
	// If no connection
	if ([MFMNetworkManager sharedNetworkManager].allowConnection == NO) {
		self.error = [NSError errorWithDomain:NSPOSIXErrorDomain code:ENETUNREACH userInfo:nil];
		self.playerStatus = MFMPlayerStatusError;
		return NO;
	}
	
	// If no resource
	if ([self.playlist count] == 0) {
		// Wait for resource to load
		return [self start];
	}
	
	// If have song and no streamer
	if (self.audioStreamer == nil) {
		[self createStreamer];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:MFMPlayerSongChangedNotification object:self];
	}
	
	[self.audioStreamer start];
	
	return YES;
//	return [self.audioStreamer isPlaying] || [self.audioStreamer isWaiting];
}

- (BOOL)pause
{
	if ([self.audioStreamer isPlaying] || [self.audioStreamer isWaiting]) {
		[self.audioStreamer pause];
		return YES;
	}
	return NO;
}

- (void)next
{
	if (self.playlist != nil) {
		self.trackNum = self.trackNum + 1;
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
			[self start];
		}
		else {
			NSLog(@"Fail to obtain the playlist, error: %@", [self.playlist.error localizedDescription]);
			self.error = self.playlist.error;
			self.playerStatus = MFMPlayerStatusError;
		}
	}
}

- (void)handleNotificationFromStreamer:(AudioStreamer *)streamer
{
	if (streamer == self.audioStreamer) {
		if (streamer.errorCode != AS_NO_ERROR) {
			// handle the error via a UI, retrying the stream, etc.
			NSString *description = [AudioStreamer stringForErrorCode:streamer.errorCode];
			NSDictionary *errorDictionary = @{ NSLocalizedDescriptionKey : description };
			self.error = [NSError errorWithDomain:MFMPlayerErrorDomain code:streamer.errorCode userInfo:errorDictionary];
			self.playerStatus = MFMPlayerStatusError;
			
			NSLog(@"Streamer error: %@", [self.error localizedDescription]);
			[self next];
		} else if ([streamer isPlaying]) {
			NSLog(@"Is Playing");
			self.playerStatus = MFMPlayerStatusPlaying;
		} else if ([streamer isPaused]) {
			NSLog(@"Is Paused");
			self.playerStatus = MFMPlayerStatusPaused;
		} else if ([streamer isIdle]) {
			NSLog(@"Is Idle");
			[self.currentSong postListenLog];
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
