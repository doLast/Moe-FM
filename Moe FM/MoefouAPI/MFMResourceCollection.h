//
//  MFMResourceCollection.h
//  Moe FM
//
//  Created by Greg Wang on 12-8-16.
//
//

#import "MFMResource.h"

@interface MFMResourceCollection : MFMResource

@property (nonatomic, strong, readonly) NSArray *resources;
@property (nonatomic, readonly) MFMResourceObjType objType;
@property (nonatomic, strong, readonly) NSNumber *fromPage;
@property (nonatomic, strong, readonly) NSNumber *nextPage;
@property (nonatomic, strong, readonly) NSNumber *perPage;
@property (nonatomic, strong, readonly) NSNumber *count;

- (MFMResourceCollection *)initWithObjType:(MFMResourceObjType)objType
							fromPageNumber:(NSNumber *)fromPage
						  withItemsPerPage:(NSNumber *)perPage;

- (BOOL)reloadResources;
- (BOOL)startFetchNextPage;

@end
