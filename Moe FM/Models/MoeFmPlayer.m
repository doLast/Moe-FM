//
//  MoeFmPlayer.m
//  Moe FM
//
//  Created by Greg Wang on 12-4-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MFMAppDelegate.h"
#import "MoeFmPlayer.h"
#import "AudioStreamer.h"

@interface MoeFmPlayer ()
@property (assign, nonatomic) NSObject <MoeFmPlayerDelegate> *delegate;
@property (retain, nonatomic) AudioStreamer *streamer;
@property (retain, nonatomic) NSTimer *updateTimer;

@property (assign, nonatomic) NSUInteger trackNum;

@end


@implementation MoeFmPlayer
@synthesize playlist = _playlist;
@synthesize allowNetworkAccess = _allowNetworkAccess;

@synthesize delegate = _delegate;
@synthesize streamer = _streamer;
@synthesize updateTimer = _updateTimer;

@synthesize trackNum = _trackNum;


- (MoeFmPlayer *) initWithDelegate:(NSObject <MoeFmPlayerDelegate> *)delegate
{
	self = [super init];
	
	self.delegate = delegate;
	
	return self;
}

# pragma mark - Getter and Setter

- (void)setPlaylist:(NSArray *)playlist
{
	_playlist = playlist;
	self.trackNum = 0;
	[self stop];
	[self start];
}

-(void)setAllowNetworkAccess:(BOOL)allowNetworkAccess
{
	_allowNetworkAccess = allowNetworkAccess;
	if(!allowNetworkAccess){
		[self stop];
	}
}

# pragma mark - Streamer

- (void)createStreamerWithURL:(NSURL *)streamURL
{
	if(!self.allowNetworkAccess){
		NSLog(@"No network access allowed");
		if([self.delegate respondsToSelector:@selector(player:needNetworkAccess:)]){
			[self.delegate player:self needNetworkAccess:YES];
		}
		return;
	}
	
	if(self.streamer){
		[self destroyStreamer];
	}
	
	self.streamer = [[AudioStreamer alloc] initWithURL:streamURL];
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self 
	 selector:@selector(streamerStateChanged:) 
	 name:ASStatusChangedNotification 
	 object:self.streamer];
	
	NSLog(@"New streamer created");
}

- (void)destroyStreamer
{
	if(self.streamer){
		[self.streamer stop];
		self.streamer = nil;
		
		[[NSNotificationCenter defaultCenter]
		 removeObserver:self
		 name:ASStatusChangedNotification
		 object:self.streamer];
	}
}

- (void)toggleTimers:(BOOL)create 
{
	if (create) {
		if (self.streamer) {
			[self toggleTimers:NO];
			self.updateTimer =
			[NSTimer
			 scheduledTimerWithTimeInterval:0.5
			 target:self
			 selector:@selector(updateProgress:)
			 userInfo:nil
			 repeats:YES];
		}
	}
	else {
		if (self.updateTimer)
		{
			[self.updateTimer invalidate];
			self.updateTimer = nil;
		}
	}
}

- (void)streamerStateChanged:(NSNotification *)aNotification
{
//	MFMAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	
	[self.delegate player:self stateChangesTo:[self.streamer state]];
	
	if ([self.streamer isPlaying])
	{
		NSLog(@"Streamer is playing");
		[self toggleTimers:YES];
		return;
	}
	else if ([self.streamer isWaiting])
	{
		NSLog(@"Streamer is waiting");
		[self toggleTimers:NO];
	}
	else if ([self.streamer isPaused]) {
		NSLog(@"Streamer is paused");
		[self toggleTimers:NO];
	}
	else if ([self.streamer isIdle])
	{
		NSLog(@"Streamer is idle");
		[self toggleTimers:NO];
	}
	
	if(self.streamer.errorCode != AS_NO_ERROR){
		NSLog(@"Streamer stoped with error %@", [AudioStreamer stringForErrorCode:[self.streamer errorCode]]);
		if([self.delegate respondsToSelector:@selector(player:stoppingWithError:)]){
			[self.delegate player:self 
				stoppingWithError:[AudioStreamer stringForErrorCode:[self.streamer errorCode]]];
		}
		[self stop];
	}
	
	if(self.streamer.stopReason == AS_STOPPING_EOF){
		NSLog(@"Streamer reach EOF, play next");
		[self next];
	}
}

- (void)updateProgress:(NSTimer *)timer
{
	if(self.streamer){
//		NSLog(@"Played %f, %f", self.streamer.progress, self.streamer.duration);
		[self.delegate player:self updateProgress:self.streamer.progress / self.streamer.duration];
	}
}

- (void)updateMetadata
{
	[self.delegate player:self updateMetadata:[self.playlist objectAtIndex:self.trackNum]];
}

- (void)start
{
	if(!self.playlist){
		[self.delegate player:self needToUpdatePlaylist:self.playlist];
		return;
	}
	if(!self.streamer){
		NSDictionary *music = [self.playlist objectAtIndex:self.trackNum];
		NSString *audioAddress = [music objectForKey:@"url"];
		NSURL *audioURL = [NSURL URLWithString:audioAddress];
		
		[self createStreamerWithURL:audioURL];
		[self updateMetadata];
	}
	
	if (![self.streamer isPlaying]) {
		[self.streamer start];
		NSLog(@"Player start on track %d", self.trackNum);
	}
}

- (void)startTrack:(NSUInteger)trackNum
{
	if(!self.streamer){}
	else if(trackNum == self.trackNum && [self.streamer isPlaying]){
		return;
	}
	else if([self.streamer isWaiting]){
		return;
	}
	
	if(trackNum >= [self.playlist count]){
		[self.delegate player:self needToUpdatePlaylist:self.playlist];
		return;
	}
	
	self.trackNum = trackNum;
	
	[self stop];
	[self start];
}

- (void)pause
{
	if(self.streamer){
		[self.streamer pause];
	}
	NSLog(@"Player pause");
}

- (void)startOrPause
{
	if(!self.streamer || [self.streamer isPaused] || [self.streamer isIdle]){
		[self start];
	}
	else if([self.streamer isPlaying]) {
		[self pause];
	}
}

- (void)stop
{
	if(self.streamer){
		[self.streamer stop];
		[self destroyStreamer];
	}
	NSLog(@"Player stop");
}

- (void)next
{
	[self startTrack:self.trackNum + 1];
}

- (void)previous
{
	if(self.streamer){
		[self.streamer seekToTime:0];
	}
//	else {
//		[self startTrack:self.trackNum - 1];	
//	}
}


@end
