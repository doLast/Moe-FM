//
//  MFMResourceSubs.h
//  Moe FM
//
//  Created by Greg Wang on 12-8-24.
//
//

#import "MFMResourceCollection.h"

@interface MFMResourceSubs : MFMResourceCollection

+ (MFMResourceSubs *)subsWithWikiId:(NSNumber *)wikiId wikiName:(NSString *)wikiName wikiType:(MFMResourceObjType)wikiType subType:(MFMResourceObjType)subType perPage:(NSUInteger)perPage;

@end
