//
//  MFMMenuViewController.h
//  Moe FM
//
//  Created by Greg Wang on 12-7-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	kMFMMenuMain = 0, 
	kMFMMenuMusic, 
	kMFMMenuSong, 
	kMFMMenuRadio, 
	kMFMMenuTag, 
} MFMMenuType;

@interface MFMMenuViewController : UITableViewController

@property (nonatomic, weak) IBOutlet UIBarButtonItem *preferencesButton;

- (IBAction)showPreferences:(id)sender;

@end
