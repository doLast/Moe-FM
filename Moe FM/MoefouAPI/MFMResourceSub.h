//
//  MFMResourceSub.h
//  Moe FM
//
//  Created by Greg Wang on 12-7-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MFMResource.h"

typedef enum {
	MFMSubTypeEp = 0, 
	MFMSubTypeSong, 
	MFMSubTypeTotal
} MFMSubType;
extern const NSString * const MFMSubTypeStr[];

@interface MFMResourceSub : MFMResource

@property (retain, nonatomic, readonly) NSNumber *subId;
@property (retain, nonatomic, readonly) NSNumber *subParentWiki;
@property (retain, nonatomic, readonly) NSString *subTitle;
@property (retain, nonatomic, readonly) NSString *subTitleEncode;
@property (assign, nonatomic, readonly) MFMSubType subType;
@property (retain, nonatomic, readonly) NSString *subOrder;
@property (retain, nonatomic, readonly) NSArray *subMeta;
@property (retain, nonatomic, readonly) NSString *subAbout;
@property (retain, nonatomic, readonly) NSDate *subDate;
@property (retain, nonatomic, readonly) NSDate *subModified;
@property (retain, nonatomic, readonly) NSURL *subFmUrl;
@property (retain, nonatomic, readonly) NSURL *subUrl;
@property (retain, nonatomic, readonly) NSString *subViewTitle;

@end
