//
//  MFMSongsViewController.m
//  Moe FM
//
//  Created by Greg Wang on 12-7-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MFMSongsViewController.h"
#import "SVPullToRefresh.h"

#import "MFMResourceSub.h"

@interface MFMSongsViewController ()

@property (retain, nonatomic) NSArray *resourceSubs;

@end


@implementation MFMSongsViewController

@synthesize resource = _resource;

@synthesize resourceSubs = _resourceSubs;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	__weak MFMSongsViewController *_self = self;

	[self.tableView addPullToRefreshWithActionHandler:^{
		NSLog(@"refresh dataSource");
		[_self performSelector:@selector(refreshTableData)];
	}];

	[self.tableView addInfiniteScrollingWithActionHandler:^{
		NSLog(@"load more data");
	}];
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self selector:@selector(handleNotification:) name:MFMResourceNotification object:self.resource];
	
	[self.tableView.pullToRefreshView triggerRefresh];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
	if (self.resourceSubs != nil) {
		NSLog(@"Have %d rows", self.resourceSubs.count);
		return self.resourceSubs.count;
	}
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SongCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    MFMResourceSub *resourceSub = [self.resourceSubs objectAtIndex:indexPath.row];
	
	cell.textLabel.text = resourceSub.subTitle;
	cell.detailTextLabel.text = [resourceSub.subId stringValue];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (void)refreshTableData
{
	if ([self.resource startFetch] == NO){
		[self.tableView.pullToRefreshView stopAnimating];
	}
}

- (void)handleNotification:(NSNotification *)notification
{
	if (notification.name == MFMResourceNotification  && 
		notification.object == self.resource) {
		self.resourceSubs = self.resource.resourceSubs;
		if (self.resourceSubs == nil) {
			NSLog(@"Got error: %@", self.resource.error.localizedDescription);
		}
		[self.tableView reloadData];
		[self.tableView.pullToRefreshView stopAnimating]; 
	}
}

@end
