//
//  MFMFavsViewController.h.m
//  Moe FM
//
//  Created by Greg Wang on 12-7-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MFMFavsViewController.h"
#import "MFMFavCell.h"

#import "SVPullToRefresh.h"
#import "MFMPlayerManager.h"

#import "MFMResourcePlaylist.h"
#import "MFMResourceFavs.h"
#import "MFMResourceFav.h"
#import "MFMResourceSub.h"

@interface MFMFavsViewController ()

@property (nonatomic) NSUInteger page;

@end


@implementation MFMFavsViewController

@synthesize resourceCollection = _resourceCollection;

- (void)viewDidLoad
{
    [super viewDidLoad];
		
	// Pull to refresh config
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
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
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
	return [self.resourceCollection count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"FavCell";
	MFMFavCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	MFMResourceFav *resource = [self.resourceCollection objectAtIndex:indexPath.row];
	cell.resourceFav = resource;

	return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	MFMPlayerManager *playerManager = [MFMPlayerManager sharedPlayerManager];
	if (self.resourceCollection.objType == MFMResourceObjTypeSong) {
		MFMResourcePlaylist *resourcePlaylist = [MFMResourcePlaylist playlistWithCollection:self.resourceCollection];
		playerManager.playlist = resourcePlaylist;
		playerManager.trackNum = indexPath.row;
	}
	else {
		MFMResourceFav *fav = [self.resourceCollection objectAtIndex:indexPath.row];
		MFMResourceWiki *wiki = (MFMResourceWiki *)fav.obj;
		MFMResourcePlaylist *resourcePlaylist = [MFMResourcePlaylist playlistWIthObjType:self.resourceCollection.objType andIds:[NSArray arrayWithObject:wiki.wikiId]];
		playerManager.playlist = resourcePlaylist;
		playerManager.trackNum = 0;
	}
}

- (void)refreshData
{
	NSUInteger page = self.page;
	self.page = 0;
	if ([self.resourceCollection reloadResources] == NO){
		NSLog(@"Cannot refresh");
		self.page = page;
		[self.tableView.pullToRefreshView stopAnimating];
	}
}

- (void)loadMoreData
{
	if ([self.resourceCollection loadPage:self.page] == NO) {
		NSLog(@"No more pages");
		[self.tableView.infiniteScrollingView stopAnimating];
	}
}

- (void)handleNotification:(NSNotification *)notification
{
	if (self.navigationController.visibleViewController != self) {
		return;
	}
	if (notification.name == MFMResourceNotification  && 
		notification.object == self.resourceCollection) {
		if (self.resourceCollection.error != nil) {
			[self.tableView.pullToRefreshView stopAnimating];
			[self.tableView.infiniteScrollingView stopAnimating];
			return;
		}
		
		self.page++;
		if (self.page == 1) {
			[self.tableView reloadData];
		}
		else {
			int i;
			NSMutableArray *indexPaths = [NSMutableArray array];
			for (i = [self.tableView numberOfRowsInSection:0]; i < [self.resourceCollection count]; i++) {
				[indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
			}
			[self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:NO];
		}
		[self.tableView.pullToRefreshView stopAnimating];
		[self.tableView.infiniteScrollingView stopAnimating];
	}
}

@end
