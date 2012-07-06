//
//  MFMResourceFavs.h
//  Moe FM
//
//  Created by Greg Wang on 12-7-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MFMResource.h"
#import "MFMResourceFav.h"

@interface MFMResourceFavs : MFMResource <MFMResourceSubsInterface, MFMResourceWikisInterface>

@property (retain, nonatomic, readonly) NSNumber *page;
@property (retain, nonatomic, readonly) NSNumber *perpage;
@property (retain, nonatomic, readonly) NSNumber *count;
@property (retain, nonatomic, readonly) NSArray *resourceFavs;

@property (readonly, nonatomic) NSArray *resourceSubs;
@property (readonly, nonatomic) NSArray *resourceWikis;
@property (readonly, nonatomic) MFMResourcePlaylist *playlist;

+ (MFMResourceFavs *)favsWithUid:(NSNumber *)uid
						userName:(NSString *)userName
						 objType:(MFMFavObjType)objType
						 favType:(MFMFavType)favType
							page:(NSNumber *)page
						 perpage:(NSNumber *)perpage;

@end
