//
//  MFMFavsViewController.h.m
//  Moe FM
//
//  Created by Greg Wang on 12-7-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MFMFavsViewController.h"
#import "SVPullToRefresh.h"
#import "MFMPlayerManager.h"

#import "MFMResourcePlaylist.h"
#import "MFMResourceFavs.h"
#import "MFMResourceFav.h"
#import "MFMResourceSub.h"

@interface MFMFavsViewController ()

@end


@implementation MFMFavsViewController

@synthesize resourceCollection = _resourceCollection;

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
	
	__weak MFMFavsViewController *_self = self;

	[self.tableView addPullToRefreshWithActionHandler:^{
		NSLog(@"refresh dataSource");
		[_self performSelector:@selector(refreshData)];
	}];

	[self.tableView addInfiniteScrollingWithActionHandler:^{
		NSLog(@"load more data");
		[_self performSelector:@selector(loadMoreData)];
	}];
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self selector:@selector(handleNotification:) name:MFMResourceNotification object:self.resourceCollection];
	
	[self.tableView.pullToRefreshView triggerRefresh];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self.resourceCollection stopFetch];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Actions

- (IBAction)playAll:(id)sender
{
	MFMResourcePlaylist *resourcePlaylist = [MFMResourcePlaylist playlistWithCollection:self.resourceCollection];
	MFMPlayerManager *playerManager = [MFMPlayerManager sharedPlayerManager];
	playerManager.playlist = resourcePlaylist;
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
	NSArray *resources = self.resourceCollection.resources;
    // Return the number of rows in the section.
	if (resources != nil) {
		NSLog(@"Have %d rows", resources.count);
		return resources.count;
	}
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"SongCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	NSArray *resources = self.resourceCollection.resources;

	MFMResourceFav *resource = [resources objectAtIndex:indexPath.row];
	MFMResourceSub *sub = (MFMResourceSub *)resource.obj;

	cell.textLabel.text = sub.subTitle;
	cell.detailTextLabel.text = [sub.subId stringValue];

	return cell;
}

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

- (void)refreshData
{
	if ([self.resourceCollection reloadResources] == NO){
		NSLog(@"Cannot refresh");
		[self.tableView.pullToRefreshView stopAnimating];
	}
}

- (void)loadMoreData
{
	if ([self.resourceCollection startFetchNextPage] == NO) {
		NSLog(@"No more pages");
		[self.tableView.infiniteScrollingView stopAnimating];
	}
}

- (void)handleNotification:(NSNotification *)notification
{
	if (notification.name == MFMResourceNotification  && 
		notification.object == self.resourceCollection) {
		if (self.resourceCollection.error != nil) {
			[self.tableView.pullToRefreshView stopAnimating];
			return;
		}
		[self.tableView reloadData];
		[self.tableView.pullToRefreshView stopAnimating];
		[self.tableView.infiniteScrollingView stopAnimating];
	}
}

@end
