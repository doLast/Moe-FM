//
//  MFMResourceSong.m
//  Moe FM
//
//  Created by Greg Wang on 12-7-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MFMResourceSong.h"

@interface MFMResourceSong ()

@property (retain, nonatomic) NSNumber *upId;
@property (retain, nonatomic) NSURL *url;
@property (retain, nonatomic) NSNumber *streamLength;
@property (retain, nonatomic) NSString *streamTime;
@property (retain, nonatomic) NSNumber *fileSize;
@property (retain, nonatomic) NSString *fileType;
@property (retain, nonatomic) NSNumber *wikiId;
@property (assign, nonatomic) MFMWikiType wikiType;
@property (retain, nonatomic) NSArray *cover;
@property (retain, nonatomic) NSString *title;
@property (retain, nonatomic) NSString *wikiTitle;
@property (retain, nonatomic) NSURL *wikiUrl;
@property (retain, nonatomic) NSNumber *subId;
@property (assign, nonatomic) MFMSubType subType;
@property (retain, nonatomic) NSString *subTitle;
@property (retain, nonatomic) NSURL *subUrl;
@property (retain, nonatomic) NSString *artist;
@property (retain, nonatomic) NSDictionary *favWiki;
@property (retain, nonatomic) NSDictionary *favSub;

@end

@implementation MFMResourceSong

@synthesize upId = _upId;
@synthesize url = _url;
@synthesize streamLength = _streamLength;
@synthesize streamTime = _streamTime;
@synthesize fileSize = _fileSize;
@synthesize fileType = _fileType;
@synthesize wikiId = _wikiId;
@synthesize wikiType = _wikiType;
@synthesize cover = _cover;
@synthesize title = _title;
@synthesize wikiTitle = _wikiTitle;
@synthesize wikiUrl = _wikiUrl;
@synthesize subId = _subId;
@synthesize subType = _subType;
@synthesize subTitle = _subTitle;
@synthesize subUrl = _subUrl;
@synthesize artist = _artist;
@synthesize favWiki = _favWiki;
@synthesize favSub = _favSub;

# pragma mark - Override MFMResource Methods

- (NSString *)description
{
	return [NSString stringWithFormat:@"MFMResourceSong\nid: %@\nurl: %@\nlength: %@\ntime: %@\nfileSize: %@\nfileType: %@\nwikiId: %@\nwikiType: %@\ncover: %@\ntitle: %@\nwikiTitle: %@\nwikiUrl: %@\nsubId: %@\nsubType: %@\nsubTitle: %@\nsubUrl: %@\nartist: %@\nfavWiki: %@\nfavSub: %@\n", self.upId, self.url, self.streamLength, self.streamTime, self.fileSize, self.fileType, self.wikiId, MFMWikiTypeStr[self.wikiType], self.cover, self.title, self.wikiTitle, self.wikiUrl, self.subId, MFMSubTypeStr[self.subType], self.subTitle, self.subUrl, self.artist, self.favWiki, self.favSub, nil];
}

- (BOOL)prepareTheResource:(NSDictionary *)resource
{	
	self.upId = [resource objectForKey:@"up_id"];
	self.url = [NSURL URLWithString:[resource objectForKey:@"url"]];
	self.streamLength = [resource objectForKey:@"stream_length"];
	self.streamTime = [resource objectForKey:@"stream_time"];
	self.fileSize = [resource objectForKey:@"file_size"];
	self.fileType = [resource objectForKey:@"file_type"];
	self.wikiId = [resource objectForKey:@"wiki_id"];
	self.wikiType = [[NSArray arrayWithObjects:MFMWikiTypeStr count:MFMSubTypeTotal]
					 indexOfObject:[resource objectForKey:@"wiki_type"]];
	self.cover = [resource objectForKey:@"cover"];
	self.title = [resource objectForKey:@"title"];
	self.wikiTitle = [resource objectForKey:@"wiki_title"];
	self.wikiUrl = [NSURL URLWithString:[resource objectForKey:@"wiki_url"]];
	self.subId = [resource objectForKey:@"sub_id"];
	self.subType = [[NSArray arrayWithObjects:MFMSubTypeStr count:MFMSubTypeTotal] indexOfObject:[resource objectForKey:@"sub_type"]];
	self.subTitle = [resource objectForKey:@"sub_title"];
	self.subUrl	= [NSURL URLWithString:[resource objectForKey:@"sub_url"]];
	self.artist = [resource objectForKey:@"artist"];
	self.favWiki = [resource objectForKey:@"fav_wiki"];
	self.favSub = [resource objectForKey:@"fav_sub"];
	
//	NSLog(@"Resource prepared\n%@", self);
	
	return YES;
}

@end
