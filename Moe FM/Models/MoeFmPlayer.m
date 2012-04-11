//
//  MoeFmPlayer.m
//  Moe FM
//
//  Created by Greg Wang on 12-4-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MoeFmPlayer.h"
#import "AudioStreamer.h"

@interface MoeFmPlayer ()

@property (assign, nonatomic) id <MoeFmPlayerDelegate> delegate;
@property (retain, nonatomic) NSArray *playlist;
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

- (MoeFmPlayer *) initWithDelegate:(id <MoeFmPlayerDelegate>)delegate{
	self = [super init];
	
	self.delegate = delegate;
	self.trackNum = 1;
	
	return self;
}

- (MoeFmPlayer *) initWithPlaylist:(NSArray *)playlist 
						  delegate:(id <MoeFmPlayerDelegate>)delegate
{
	self = [super init];
	
	self.playlist = playlist;
	self.delegate = delegate;
	self.trackNum = 1;
	
	return self;
}

//
// createTimers
//
// Creates or destoys the timers
//
-(void)createTimers:(BOOL)create {
	if (create) {
		if (self.streamer) {
			[self createTimers:NO];
			self.updateTimer =
			[NSTimer
			 scheduledTimerWithTimeInterval:0.1
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

- (void)updateProgress:(NSTimer *)timer
{
	if(self.streamer){
//		NSLog(@"Played %f, %f", self.streamer.progress, self.streamer.duration);
		[self.delegate updateProgressIndicator:self.streamer.progress / self.streamer.duration];
		
		if([self.streamer isIdle]){
			[self next];
		}
	}
}

- (void)updateMetadata
{
	[self.delegate updateMetadate:[self.playlist objectAtIndex:self.trackNum]];
}

- (void) setPlaylist:(NSArray *)playlist
{
	_playlist = playlist;
	[self stop];
}

- (void) appendPlaylist:(NSArray *)playlist
{
	if(self.playlist){
		self.playlist = [self.playlist arrayByAddingObjectsFromArray:playlist];
	}
	else {
		self.playlist = playlist;
	}
}

- (void)start
{
	if(!self.playlist){
		NSLog(@"No playlist assigned");
		return;
	}
	if(!self.streamer){
		NSDictionary *music = [self.playlist objectAtIndex:self.trackNum];
		NSString *audioAddress = [music objectForKey:@"url"];
		NSURL *audioURL = [NSURL URLWithString:audioAddress];
		
		self.streamer = [[AudioStreamer alloc] initWithURL:audioURL];
		[self updateMetadata];
		NSLog(@"New streamer created");
	}
	
	[self.streamer start];
	[self createTimers:YES];
	
	NSLog(@"Player start on track %d", self.trackNum);
}

- (void)startTrack:(NSUInteger) trackNum
{
	if(trackNum == self.trackNum){
		return;
	}
	if(trackNum < 1 || trackNum > [self.playlist count]){
		NSLog(@"TrackNum out of bound");
		return;
	}
	if(trackNum == [self.playlist count]){
		self.playlist = [self.delegate getNewPlaylist];
		trackNum = 1;
	}
	[self stop];
	
	self.trackNum = trackNum;
	[self start];
}

- (void)pause
{
	if(self.streamer){
		[self.streamer pause];
	}
	[self createTimers:NO];
	NSLog(@"Player pause");
}

- (void)startOrPause
{
	if(!self.streamer || ![self.streamer isPlaying]){
		[self start];
	}
	else {
		[self pause];
	}
}

- (void)stop
{
	if(self.streamer){
		[self.streamer stop];
		self.streamer = nil;
	}
	[self createTimers:NO];
	NSLog(@"Player stop");
}

- (void)next
{
	[self startTrack:self.trackNum + 1];
}

- (void)previous
{
	[self startTrack:self.trackNum - 1];
}


@end
