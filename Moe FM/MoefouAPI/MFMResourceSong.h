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

@interface MFMResourceSong : MFMResource

@property (retain, nonatomic, readonly) NSNumber *upId;
@property (retain, nonatomic, readonly) NSURL *url;
@property (retain, nonatomic, readonly) NSNumber *streamLength;
@property (retain, nonatomic, readonly) NSString *streamTime;
@property (retain, nonatomic, readonly) NSNumber *fileSize;
@property (retain, nonatomic, readonly) NSString *fileType;
@property (retain, nonatomic, readonly) NSNumber *wikiId;
@property (assign, nonatomic, readonly) MFMWikiType wikiType;
@property (retain, nonatomic, readonly) NSArray *cover;
@property (retain, nonatomic, readonly) NSString *title;
@property (retain, nonatomic, readonly) NSString *wikiTitle;
@property (retain, nonatomic, readonly) NSURL *wikiUrl;
@property (retain, nonatomic, readonly) NSNumber *subId;
@property (assign, nonatomic, readonly) MFMSubType subType;
@property (retain, nonatomic, readonly) NSString *subTitle;
@property (retain, nonatomic, readonly) NSURL *subUrl;
@property (retain, nonatomic, readonly) NSString *artist;
@property (retain, nonatomic, readonly) NSDictionary *favWiki;
@property (retain, nonatomic, readonly) NSDictionary *favSub;

@end
