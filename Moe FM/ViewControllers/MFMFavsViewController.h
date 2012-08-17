//
//  MFMFavsViewController.h.h
//  Moe FM
//
//  Created by Greg Wang on 12-7-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MFMResourceFavs;

@interface MFMFavsViewController : UITableViewController

@property (retain, nonatomic) MFMResourceFavs *resourceCollection;

- (IBAction)playAll:(id)sender;

@end
