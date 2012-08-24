//
//  MFMResourceCollection.m
//  Moe FM
//
//  Created by Greg Wang on 12-8-16.
//
//

#import "MFMResourceCollection.h"

const NSInteger MFMResourcePerPageDefault = 10;

@interface MFMResourceCollection ()

@property (nonatomic, strong) NSMutableDictionary *resources;
@property (nonatomic) MFMResourceObjType objType;
@property (nonatomic) NSUInteger perPage;
@property (nonatomic) NSUInteger total;

- (NSURL *)urlForPage:(NSUInteger)page;

@end

@implementation MFMResourceCollection

#pragma mark - Getter & Setter

@synthesize resources = _resources;
@synthesize objType = _objType;
@synthesize perPage = _perPage;
@synthesize total = _total;

- (NSUInteger)count
{
	if (self.resources == nil) {
		return 0;
	}
	return [self.resources count];
}

#pragma mark - Life cycle

- (MFMResourceCollection *)initWithObjType:(MFMResourceObjType)objType
						  withItemsPerPage:(NSUInteger)perPage
{
	self = [super init];
	if (self != nil) {
		self.resources = nil;
		self.objType = objType;
		self.perPage = perPage;
		self.total = 0;
	}
	return self;
}

- (NSString *)description
{
	NSMutableString *str = [NSMutableString string];
	for (NSObject *resource in self.resources) {
		[str appendString:resource.description];
	}
	return str;
}

#pragma mark - Loading request

- (BOOL)reloadResources
{
	[self stopFetch];
	NSMutableDictionary *resources = self.resources;
	NSUInteger total = self.total;
	self.resources = nil;
	self.total = 0;
	if ([self loadPage:0] == NO) {
		self.resources = resources;
		self.total = total;
		return NO;
	}
	return YES;
}

- (BOOL)loadPage:(NSUInteger)page
{
	if (self.resources == nil || page * self.perPage < self.total) {
		return [self startFetchWithURL:[self urlForPage:page]];
	}
	return NO;
}

- (BOOL)loadObjectAtIndex:(NSUInteger)index
{
	return [self loadPage:index / self.perPage];
}

#pragma mark - Object manipulation

- (id)objectAtIndex:(NSUInteger)index
{
	return [self.resources objectForKey:[NSNumber numberWithInteger:index]];
}

- (void)addObject:(NSObject *)object toIndex:(NSUInteger)index
{
	if (self.resources == nil) {
		self.resources = [NSMutableDictionary dictionary];
	}
	[self.resources setObject:object forKey:[NSNumber numberWithInteger:index]];
}

#pragma mark - Abstract method

- (NSURL *)urlForPage:(NSUInteger)page
{
	return nil;
}

@end
