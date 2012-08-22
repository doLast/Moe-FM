//
//  MFMResourceCollection.h
//  Moe FM
//
//  Created by Greg Wang on 12-8-16.
//
//

#import "MFMResource.h"

extern const NSInteger MFMResourcePerPageDefault;

@interface MFMResourceCollection : MFMResource

@property (nonatomic, readonly) MFMResourceObjType objType;
@property (nonatomic, readonly) NSUInteger perPage;
@property (nonatomic, readonly) NSUInteger count;
@property (nonatomic, readonly) NSUInteger total;

- (MFMResourceCollection *)initWithObjType:(MFMResourceObjType)objType
						  withItemsPerPage:(NSUInteger)perPage;

- (BOOL)reloadResources;
- (BOOL)loadPage:(NSUInteger)page;
- (BOOL)loadObjectAtIndex:(NSUInteger)index;
- (id)objectAtIndex:(NSUInteger)index;
- (void)addObject:(NSObject *)object toIndex:(NSUInteger)index;

@end
