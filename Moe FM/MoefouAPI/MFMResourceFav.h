//
//  MoefouResourceFav.h
//  Moe FM
//
//  Created by Greg Wang on 12-7-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MFMResource.h"

typedef enum {
	MFMFavObjTypeTv = 0, 
	MFMFavObjTypeOva, 
	MFMFavObjTypeOad, 
	MFMFavObjTypeMovie, 
	MFMFavObjTypeAnime, 
	MFMFavObjTypeComic, 
	MFMFavObjTypeMusic, 
	MFMFavObjTypeRadio, 
	MFMFavObjTypeWiki, 
	MFMFavObjTypeEp, 
	MFMFavObjTypeSong, 
	MFMFavObjTypeSub, 
	MFMFavObjTypeTotal
} MFMFavObjType;
extern const NSString * const MFMFavObjTypeStr[];

typedef enum {
	MFMFavTypeHeart = 1,
	MFMFavTypeTrash
} MFMFavType;


@interface MFMResourceFav : MFMResource

@property (retain, nonatomic, readonly) NSNumber *favId;
@property (retain, nonatomic, readonly) NSNumber *favObjId;
@property (assign, nonatomic, readonly) MFMFavObjType favObjType;
@property (retain, nonatomic, readonly) NSNumber *favUid;
@property (retain, nonatomic, readonly) NSDate *favDate;
@property (assign, nonatomic, readonly) MFMFavType favType;
@property (retain, nonatomic, readonly) MFMResource *obj;

@end
