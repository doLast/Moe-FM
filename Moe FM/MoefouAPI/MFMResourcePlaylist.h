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

@property (nonatomic, strong, readonly) NSNumber *mayHaveNext;

+ (MFMResourcePlaylist *)magicPlaylist;
+ (MFMResourcePlaylist *)playlistWithCollection:(MFMResourceCollection *)collection;
+ (MFMResourcePlaylist *)playlistWithFavType:(MFMResourceObjType)favType;
+ (MFMResourcePlaylist *)playlistWIthObjType:(MFMResourceObjType)objType andIds:(NSArray *)ids;

@end
