//
//  MFMResourceCollection.m
//  Moe FM
//
//  Created by Greg Wang on 12-8-16.
//
//

#import "MFMResourceCollection.h"

@interface MFMResourceCollection ()

@property (nonatomic, strong) NSArray *resources;
@property (nonatomic) MFMResourceObjType objType;
@property (nonatomic, strong) NSNumber *fromPage;
@property (nonatomic, strong) NSNumber *nextPage;
@property (nonatomic, strong) NSNumber *perPage;
@property (nonatomic, strong) NSNumber *count;

- (NSURL *)urlForPage:(NSNumber *)page;

@end

@implementation MFMResourceCollection

@synthesize resources = _resources;
@synthesize objType = _objType;
@synthesize fromPage = _fromPage;
@synthesize nextPage = _nextPage;
@synthesize perPage = _perPage;
@synthesize count = _count;

- (MFMResourceCollection *)initWithObjType:(MFMResourceObjType)objType
							fromPageNumber:(NSNumber *)fromPage
						  withItemsPerPage:(NSNumber *)perPage
{
	assert(fromPage != nil);
	assert(perPage != nil);
	self = [super init];
	if (self != nil) {
		self.resources = nil;
		self.objType = objType;
		self.fromPage = fromPage;
		self.nextPage = nil;
		self.perPage = perPage;
		self.count = nil;
	}
	return self;
}

- (BOOL)reloadResources
{
	[self stopFetch];
	self.nextPage = nil;
	self.count = nil;
	return [self startFetchNextPage];
}

- (BOOL)startFetchNextPage
{
	NSURL *url = nil;
	if (self.nextPage == nil) {
		url = [self urlForPage:self.fromPage];
	}
	else if (self.count != nil && self.nextPage.doubleValue < self.count.doubleValue / self.perPage.doubleValue + 1) {
		url = [self urlForPage:self.nextPage];
	}
	else {
		return NO;
	}
	
	return [self startFetchWithURL:url andDataType:MFMDataTypeJson];
}

- (NSURL *)urlForPage:(NSNumber *)page
{
	return nil;
}

@end
