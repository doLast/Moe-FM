//
//  MFMResourcePlaylist.h
//  Moe FM
//
//  Created by Greg Wang on 12-7-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MFMResource.h"
#import "MFMResourceSong.h"

@interface MFMResourcePlaylist : MFMResource

@property (retain, nonatomic, readonly) NSNumber *page;
@property (retain, nonatomic, readonly) NSNumber *itemCount;
@property (assign, nonatomic, readonly) NSNumber *mayHaveNext;
@property (retain, nonatomic, readonly) NSURL *nextUrl;
@property (retain, nonatomic, readonly) NSArray *resourceSongs;

+ (MFMResourcePlaylist *)magicPlaylist;

@end
