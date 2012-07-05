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

const NSString * const MFMFavObjTypeStr[] = 
{@"tv", @"ova", @"oad", @"movie", @"anime", @"comic", @"music", @"radio",  @"wiki", @"ep", @"song", @"sub"};

@interface MFMResourceFav ()

@property (retain, nonatomic) NSNumber *favId;
@property (retain, nonatomic) NSNumber *favObjId;
@property (assign, nonatomic) MFMFavObjType favObjType;
@property (retain, nonatomic) NSNumber *favUid;
@property (retain, nonatomic) NSDate *favDate;
@property (assign, nonatomic) MFMFavType favType;
@property (retain, nonatomic) MFMResource *obj;

@end

@implementation MFMResourceFav

@synthesize favId = _favId;
@synthesize favObjId = _favObjId;
@synthesize favObjType = _favObjType;
@synthesize favUid = _favUid;
@synthesize favDate = _favDate;
@synthesize favType = _favType;
@synthesize obj = _obj;

# pragma mark - Override MFMResource Methods

- (NSString *)description
{
	return [NSString stringWithFormat:@"MFMResourceFav\nid: %@\nobjId: %@\nobjType: %@\nuid: %@\ndate: %@\ntype: %d\nobj: %@\n", self.favId, self.favObjId, MFMFavObjTypeStr[self.favObjType], self.favUid, self.favDate, self.favType, self.obj];
}

- (BOOL)prepareTheResource:(NSDictionary *)resource
{
	self.favId = [resource objectForKey:@"fav_id"];
	self.favObjId = [resource objectForKey:@"fav_obj_id"]; 
	self.favObjType = [[NSArray arrayWithObjects:MFMFavObjTypeStr count:MFMFavObjTypeTotal]
					   indexOfObject:[resource objectForKey:@"fav_obj_type"]];
	
	self.favUid = [resource objectForKey:@"fav_uid"];
	self.favDate = [NSDate dateWithTimeIntervalSince1970:[(NSNumber *)[resource objectForKey:@"fav_date"] doubleValue]];
	self.favType = [[resource objectForKey:@"fav_type"] integerValue];
	switch (self.favObjType) {
		case MFMFavObjTypeTv:
		case MFMFavObjTypeOva:
		case MFMFavObjTypeOad: 
		case MFMFavObjTypeMovie: 
		case MFMFavObjTypeAnime: 
		case MFMFavObjTypeComic: 
		case MFMFavObjTypeMusic: 
		case MFMFavObjTypeRadio: 
			self.obj = [[MFMResourceWiki alloc] 
						initWithResouce:[resource objectForKey:@"obj"]];
			break;
		case MFMFavObjTypeEp: 
		case MFMFavObjTypeSong: 
			self.obj = [[MFMResourceSub alloc] 
						initWithResouce:[resource objectForKey:@"obj"]];
			break;
		default:
			break;
	}
	
	return YES;
}

@end
