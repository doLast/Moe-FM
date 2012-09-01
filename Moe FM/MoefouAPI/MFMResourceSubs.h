//
//  MFMResourceSubs.h
//  Moe FM
//
//  Created by Greg Wang on 12-8-24.
//
//

#import "MFMResourceCollection.h"
#import "MFMResourceSub.h"

@interface MFMResourceSubs : MFMResourceCollection

@property (nonatomic, readonly) MFMResourceObjType wikiType;
@property (nonatomic, strong, readonly) NSNumber *wikiId;

+ (MFMResourceSubs *)subsWithWikiId:(NSNumber *)wikiId wikiName:(NSString *)wikiName wikiType:(MFMResourceObjType)wikiType subType:(MFMResourceObjType)subType perPage:(NSUInteger)perPage;
+ (MFMResourceSubs *)relationshipsWithWikiId:(NSNumber *)wikiId wikiName:(NSString *)wikiName wikiType:(MFMResourceObjType)wikiType objType:(MFMResourceObjType)objType;

@end
