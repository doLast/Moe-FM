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
	MFMPlayerStatusError, 
	MFMPlayerStatusTotal
} MFMPlayerStatus;

@class MFMResourcePlaylist;
@class MFMResourceSong;


@interface MFMPlayerManager : NSObject

@property (strong, nonatomic) MFMResourcePlaylist *playlist;
@property (nonatomic) NSUInteger trackNum;
@property (readonly, nonatomic) MFMResourceSong *currentSong;
@property (readonly, nonatomic) MFMPlayerStatus playerStatus;
@property (readonly, nonatomic) double progress;
@property (readonly, nonatomic) double duration;
@property (readonly, nonatomic, strong) NSError *error;

+ (MFMPlayerManager *)sharedPlayerManager;

- (BOOL)play;
- (BOOL)pause;
- (void)next;

@end
