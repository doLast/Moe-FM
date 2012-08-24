//
//  MFMWikiViewController.h
//  Moe FM
//
//  Created by Greg Wang on 12-8-24.
//
//

#import "MFMResourcesViewController.h"

@class MFMResourceWiki;
@class MFMResourceFav;

@interface MFMWikiViewController : MFMResourcesViewController

@property (nonatomic, strong) MFMResourceWiki *resourceWiki;
@property (nonatomic, strong) MFMResourceFav *resourceFav;

@end
