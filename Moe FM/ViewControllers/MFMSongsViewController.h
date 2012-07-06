//
//  MFMSongsViewController.h
//  Moe FM
//
//  Created by Greg Wang on 12-7-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFMResource.h"

@interface MFMSongsViewController : UITableViewController

@property (retain, nonatomic) MFMResource <MFMResourceSubsInterface> *resource;

@end
