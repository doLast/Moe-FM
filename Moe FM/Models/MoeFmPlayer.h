//
//  MoeFmPlayer.h
//  Moe FM
//
//  Created by Greg Wang on 12-4-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AudioStreamer.h"

@class MoeFmPlayer;

@protocol MoeFmPlayerDelegate

- (void)player:(MoeFmPlayer *)player needToUpdatePlaylist:(NSArray *)currentplaylist;

@optional
- (void)player:(MoeFmPlayer *)player updateProgress:(float)percentage;
- (void)player:(MoeFmPlayer *)player updateMetadata:(NSDictionary *)metadata;
- (void)player:(MoeFmPlayer *)player stateChangesTo:(AudioStreamerState)state;

@optional
- (void)player:(MoeFmPlayer *)player stoppingWithError:(NSString *)error;

@end

@interface MoeFmPlayer : NSObject

@property (retain, nonatomic) NSArray *playlist;
@property (readonly) NSString *playerErrorReason;

- (MoeFmPlayer *) initWithDelegate:(NSObject <MoeFmPlayerDelegate> *)delegate;

- (void)setPlaylist:(NSArray *)playlist;
- (void)start;
- (void)startTrack:(NSUInteger) trackNum;
- (void)pause;
- (void)startOrPause;
- (void)stop;
- (void)next;
- (void)previous; 

@end
