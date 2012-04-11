//
//  MoeFmPlayer.h
//  Moe FM
//
//  Created by Greg Wang on 12-4-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MoeFmPlayerDelegate

- (void)updateProgressIndicator:(float)percentage;
- (void)updateMetadate:(NSDictionary *)metadata;
- (NSArray *)getNewPlaylist;

@end

@interface MoeFmPlayer : NSObject

- (MoeFmPlayer *) initWithDelegate:(id <MoeFmPlayerDelegate>)delegate;
- (MoeFmPlayer *) initWithPlaylist:(NSArray *)playlist delegate:(id <MoeFmPlayerDelegate>)delegate;

- (void)setPlaylist:(NSArray *)playlist;
- (void)appendPlaylist:(NSArray *)playlist;
- (void)start;
- (void)startTrack:(NSUInteger) trackNum;
- (void)pause;
- (void)startOrPause;
- (void)stop;
- (void)next;
- (void)previous; 

@end
