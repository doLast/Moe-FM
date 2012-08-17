//
//  MoefouResourceFav.h
//  Moe FM
//
//  Created by Greg Wang on 12-7-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MFMResource.h"

typedef enum {
	MFMFavTypeHeart = 1,
	MFMFavTypeTrash
} MFMFavType;

@interface MFMResourceFav : MFMResource

@property (retain, nonatomic, readonly) NSNumber *favId;
@property (retain, nonatomic, readonly) NSNumber *favObjId;
@property (assign, nonatomic, readonly) MFMResourceObjType favObjType;
@property (retain, nonatomic, readonly) NSNumber *favUid;
@property (retain, nonatomic, readonly) NSDate *favDate;
@property (assign, nonatomic, readonly) MFMFavType favType;
@property (retain, nonatomic, readonly) MFMResource *obj;

- (MFMResourceFav *)initWithObjId:(NSNumber *)objId andType:(MFMResourceObjType)objType;

- (BOOL)didAddToFavAsType:(MFMFavType)favType;
- (void)toggleFavAsType:(MFMFavType)favType;

@end
