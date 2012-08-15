//
//  MFMPlayerManager.h
//  Moe FM
//
//  Created by Greg Wang on 12-7-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const MFMPlayerStatusChangedNotification;
extern NSString * const MFMPlayerSongChangedNotification;

typedef enum {
	MFMPlayerStatusPlaying = 0, 
	MFMPlayerStatusPaused, 
	MFMPlayerStatusWaiting, 
	MFMPlayerStatusTotal
} MFMPlayerStatus;

@class MFMResourcePlaylist;
@class MFMResourceSong;


@interface MFMPlayerManager : NSObject

@property (retain, nonatomic) MFMResourcePlaylist *nextPlaylist;
@property (assign, nonatomic) NSUInteger nextTrackNum;
@property (readonly, nonatomic) MFMResourceSong *currentSong;
@property (readonly, nonatomic) MFMPlayerStatus playerStatus;

+ (MFMPlayerManager *)sharedPlayerManager;

- (BOOL)start;
- (BOOL)play;
- (BOOL)pause;
- (void)next;

@end
