//
//  MFMResourceSong.h
//  Moe FM
//
//  Created by Greg Wang on 12-7-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MFMResource.h"
#import "MFMResourceWiki.h"
#import "MFMResourceSub.h"
#import "MFMResourceFav.h"

@interface MFMResourceSong : MFMResource

@property (retain, nonatomic, readonly) NSNumber *upId;
@property (retain, nonatomic, readonly) NSURL *streamURL;
@property (retain, nonatomic, readonly) NSNumber *streamLength;
@property (retain, nonatomic, readonly) NSString *streamTime;
@property (retain, nonatomic, readonly) NSNumber *fileSize;
@property (retain, nonatomic, readonly) NSString *fileType;
@property (retain, nonatomic, readonly) NSNumber *wikiId;
@property (assign, nonatomic, readonly) MFMResourceObjType wikiType;
@property (retain, nonatomic, readonly) NSDictionary *cover;
@property (retain, nonatomic, readonly) NSString *title;
@property (retain, nonatomic, readonly) NSString *wikiTitle;
@property (retain, nonatomic, readonly) NSURL *wikiURL;
@property (retain, nonatomic, readonly) NSNumber *subId;
@property (assign, nonatomic, readonly) MFMResourceObjType subType;
@property (retain, nonatomic, readonly) NSString *subTitle;
@property (retain, nonatomic, readonly) NSURL *subURL;
@property (retain, nonatomic, readonly) NSString *artist;
@property (retain, nonatomic, readonly) MFMResourceFav *favWiki;
@property (retain, nonatomic, readonly) MFMResourceFav *favSub;

@end
