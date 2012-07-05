//
//  MFMResourceFavs.h
//  Moe FM
//
//  Created by Greg Wang on 12-7-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MFMResource.h"
#import "MFMResourceFav.h"

@interface MFMResourceFavs : MFMResource

@property (retain, nonatomic, readonly) NSNumber *page;
@property (retain, nonatomic, readonly) NSNumber *perpage;
@property (retain, nonatomic, readonly) NSNumber *count;
@property (retain, nonatomic, readonly) NSArray *resourceFavs;

+ (MFMResourceFavs *)favsWithUid:(NSNumber *)uid
						userName:(NSString *)userName
						 objType:(MFMFavObjType)objType
						 favType:(MFMFavType)favType
							page:(NSNumber *)page
						 perpage:(NSNumber *)perpage;

@end
