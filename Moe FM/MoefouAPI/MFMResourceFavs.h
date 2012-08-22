//
//  MFMResourceFavs.h
//  Moe FM
//
//  Created by Greg Wang on 12-7-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MFMResourceCollection.h"
#import "MFMResourceFav.h"

@interface MFMResourceFavs : MFMResourceCollection

+ (MFMResourceFavs *)favsWithUid:(NSNumber *)uid
						userName:(NSString *)userName
						 objType:(MFMResourceObjType)objType
						 favType:(MFMFavType)favType
						 perPage:(NSUInteger)perPage;

@end
