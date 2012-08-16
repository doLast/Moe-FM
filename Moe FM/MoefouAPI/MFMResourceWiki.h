//
//  MFMResourceWiki.h
//  Moe FM
//
//  Created by Greg Wang on 12-7-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MFMResource.h"

typedef enum {
	MFMWikiTypeTv = 0, 
	MFMWIkiTypeOva, 
	MFMWikiTypeOad, 
	MFMWikiTypeMovie, 
	MFMWikiTypeAnime, 
	MFMWikiTypeComic, 
	MFMWikiTypeMusic, 
	MFMWikiTypeRadio, 
	MFMWikiTypeTotal
} MFMWikiType;
extern const NSString * const MFMWikiTypeStr[];

typedef enum {
	MFMWikiCoverSmall = 0, 
	MFMWikiCoverMedium, 
	MFMWikiCoverSquare, 
	MFMWikiCoverLarge, 
	MFMWIKICoverTotal
} MFMWikiCover;
extern const NSString * const MFMWikiCoverStr[];

@interface MFMResourceWiki : MFMResource

@property (retain, nonatomic, readonly) NSNumber *wikiId;
@property (retain, nonatomic, readonly) NSString *wikiTitle;
@property (retain, nonatomic, readonly) NSString *wikiTitleEncode;
@property (assign, nonatomic, readonly) MFMWikiType wikiType;
@property (retain, nonatomic, readonly) NSDate *wikiDate;
@property (retain, nonatomic, readonly) NSDate *wikiModified;
@property (retain, nonatomic, readonly) NSNumber *wikiModifiedUser;
@property (retain, nonatomic, readonly) NSArray *wikiMeta;
@property (retain, nonatomic, readonly) NSURL *wikiFmURL;
@property (retain, nonatomic, readonly) NSURL *wikiURL;
@property (retain, nonatomic, readonly) NSDictionary *wikiCover;


//- (MFMResourceWiki *)initWithWikiType:(MFMWikiType[])types
//								 page:(NSNumber *)page
//							  perpage:(NSNumber *)perpage
//							  initial:(NSString *)initial
//								  tag:(NSString *[])tags
//							   wikiId:(NSNumber *[])ids
//								 date:(NSString *)date;

@end
