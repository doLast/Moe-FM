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

@synthesize delegate = _delegate;
@synthesize playlist = _playlist;
@synthesize streamer = _streamer;
@synthesize updateTimer = _updateTimer;

@synthesize trackNum = _trackNum;

- (MoeFmPlayer *) initWithDelegate:(NSObject <MoeFmPlayerDelegate> *)delegate{
	self = [super init];
	
	self.delegate = delegate;
	
	return self;
}

- (void)createStreamerWithURL:(NSURL *)streamURL
{
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
	
	if ([self.streamer isWaiting])
	{
		NSLog(@"Streamer is waiting");
		[self toggleTimers:NO];
	}
	else if ([self.streamer isPlaying])
	{
		NSLog(@"Streamer is playing");
		[self toggleTimers:YES];
	}
	else if ([self.streamer isPaused]) {
		NSLog(@"Streamer is paused");
		[self toggleTimers:NO];
	}
	else if ([self.streamer isIdle])
	{
		NSLog(@"Streamer is idle");
		[self toggleTimers:NO];
		if(self.streamer.stopReason == AS_STOPPING_EOF){
			[self next];
		}
		else if(self.streamer.stopReason == AS_STOPPING_ERROR){
			if([self.delegate respondsToSelector:@selector(player:stoppingWithError:)]){
				[self.delegate player:self 
					stoppingWithError:[AudioStreamer stringForErrorCode:[self.streamer errorCode]]];
			}
		}
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

- (void)setPlaylist:(NSArray *)playlist
{
	_playlist = playlist;
	self.trackNum = 0;
	[self stop];
	[self start];
}

- (NSString *)playerErrorReason
{
	return [AudioStreamer stringForErrorCode:[self.streamer errorCode]];
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
	
	[self.streamer start];
	
	NSLog(@"Player start on track %d", self.trackNum);
}

- (void)startTrack:(NSUInteger) trackNum
{
	if(!self.streamer){}
	else if(trackNum == self.trackNum && [self.streamer isPlaying]){
		return;
	}
	else if([self.streamer isWaiting]){
		return;
	}
	
	self.trackNum = trackNum;
	
	if(trackNum >= [self.playlist count]){
		[self.delegate player:self needToUpdatePlaylist:self.playlist];
		return;
	}
	
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
