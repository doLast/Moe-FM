//
//  MoefouResourceFav.m
//  Moe FM
//
//  Created by Greg Wang on 12-7-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MFMResourceFav.h"
#import "MFMResourceWiki.h"
#import "MFMResourceSub.h"
#import "MFMDataFetcher.h"

NSString * const kAddFavURLStr = @"http://api.moefou.org/fav/add.";
NSString * const kDeleteFavURLStr = @"http://api.moefou.org/fav/delete.";

@interface MFMResourceFav () <MFMDataFetcherDelegate>

@property (retain, nonatomic) NSNumber *favId;
@property (retain, nonatomic) NSNumber *favObjId;
@property (assign, nonatomic) MFMResourceObjType favObjType;
@property (retain, nonatomic) NSNumber *favUid;
@property (retain, nonatomic) NSDate *favDate;
@property (assign, nonatomic) MFMFavType favType;
@property (retain, nonatomic) MFMResource *obj;
@property (retain, nonatomic) MFMDataFetcher *favFetcher;

@end

@implementation MFMResourceFav

#pragma mark - getter & setter

@synthesize favId = _favId;
@synthesize favObjId = _favObjId;
@synthesize favObjType = _favObjType;
@synthesize favUid = _favUid;
@synthesize favDate = _favDate;
@synthesize favType = _favType;
@synthesize obj = _obj;
@synthesize favFetcher = _favFetcher;

#pragma mark - life cycle

- (MFMResourceFav *)initWithObjId:(NSNumber *)objId andType:(MFMResourceObjType)objType
{
	self = [super init];
	if (self != nil) {
		self.favId = nil;
		self.favObjId = objId;
		self.favObjType = objType;
		self.favUid = nil;
		self.favDate = nil;
		self.favType = 0;
		self.obj = nil;
	}
	return self;
}

#pragma mark - fav manipulation

- (BOOL)didAddToFavAsType:(MFMFavType)favType
{
	return self.favUid != nil && self.favType == favType;
}

- (void)toggleFavAsType:(MFMFavType)favType
{
	NSString *urlPrefix = nil;
	NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
	[parameters setValue:MFMResourceObjTypeStr[self.favObjType] forKey:@"fav_obj_type"];
	[parameters setValue:self.favObjId forKey:@"fav_obj_id"];
	
	if ([self didAddToFavAsType:favType]) {
		urlPrefix = [kDeleteFavURLStr stringByAppendingFormat:@"%@?", MFMAPIFormat];
	}
	else {
		urlPrefix = [kAddFavURLStr stringByAppendingFormat:@"%@?", MFMAPIFormat];
		self.favType = favType;
		[parameters setValue:[NSNumber numberWithInt:self.favType] forKey:@"fav_type"];
	}
	
	NSURL *url = [MFMResource urlWithPrefix:urlPrefix parameters:parameters];
	NSLog(@"Toggling fav with url: %@", url);
	
	if (self.favFetcher != nil){
		[self.favFetcher stop];
		self.favFetcher = nil;
	}
	
	self.favFetcher = [[MFMDataFetcher alloc] initWithURL:url dataType:MFMDataTypeJson];
	[self.favFetcher beginFetchWithDelegate:self];
	
	return;
}

# pragma mark - Override MFMResource Methods

- (NSString *)description
{
	return [NSString stringWithFormat:@"MFMResourceFav\nid: %@\nobjId: %@\nobjType: %@\nuid: %@\ndate: %@\ntype: %d\nobj: %@\n", self.favId, self.favObjId, MFMResourceObjTypeStr[self.favObjType], self.favUid, self.favDate, self.favType, self.obj];
}

- (BOOL)prepareTheResource:(NSDictionary *)resource
{
	if ([resource objectForKey:@"fav"] != nil) {
		resource = [resource objectForKey:@"fav"];
	}
	
	self.favId = [resource objectForKey:@"fav_id"];
	self.favUid = [resource objectForKey:@"fav_uid"];
	self.favDate = [NSDate dateWithTimeIntervalSince1970:
					[(NSNumber *)[resource objectForKey:@"fav_date"] doubleValue]];
	
	if (self.favUid != nil) {
		self.favType = [[resource objectForKey:@"fav_type"] integerValue];
		self.favObjId = [resource objectForKey:@"fav_obj_id"]; 
		self.favObjType = [[NSArray arrayWithObjects:MFMResourceObjTypeStr
											   count:MFMResourceObjTypeTotal]
						   indexOfObject:[resource objectForKey:@"fav_obj_type"]];
	}
	
	if ([resource objectForKey:@"obj"] == nil) {
		self.obj = nil;
		return YES;
	}
	
	// If have obj create it
	switch (self.favObjType) {
		case MFMResourceObjTypeTv:
		case MFMResourceObjTypeOva:
		case MFMResourceObjTypeOad: 
		case MFMResourceObjTypeMovie: 
		case MFMResourceObjTypeAnime: 
		case MFMResourceObjTypeComic: 
		case MFMResourceObjTypeMusic: 
		case MFMResourceObjTypeRadio:
		case MFMResourceObjTypeWiki:
			self.obj = [[MFMResourceWiki alloc]
						initWithResouce:[resource objectForKey:@"obj"]];
			break;
		case MFMResourceObjTypeEp: 
		case MFMResourceObjTypeSong:
		case MFMResourceObjTypeSub:
			self.obj = [[MFMResourceSub alloc]
						initWithResouce:[resource objectForKey:@"obj"]];
			break;
		default:
			break;
	}
	
	return YES;
}

@end
