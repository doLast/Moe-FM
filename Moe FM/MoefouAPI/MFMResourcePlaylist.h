//
//  MFMResourcePlaylist.h
//  Moe FM
//
//  Created by Greg Wang on 12-7-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MFMResourceCollection.h"
#import "MFMResourceSong.h"

@interface MFMResourcePlaylist : MFMResourceCollection

@property (nonatomic, readonly) BOOL mayHaveNext;

+ (MFMResourcePlaylist *)magicPlaylist;
+ (MFMResourcePlaylist *)playlistWithCollection:(MFMResourceCollection *)collection;
+ (MFMResourcePlaylist *)playlistWithResource:(MFMResource *)resource;

@end
