//
//  MFMResourcesViewController.h
//  Moe FM
//
//  Created by Greg Wang on 12-8-25.
//
//

#import <UIKit/UIKit.h>

@class MFMResourceCollection;

@interface MFMResourcesViewController : UITableViewController

@property (nonatomic, weak) IBOutlet UIBarButtonItem *playAllButton;
@property (retain, nonatomic) MFMResourceCollection *resourceCollection;

- (IBAction)playAll:(id)sender;
- (void)refreshData;
- (void)loadMoreData;

@end
