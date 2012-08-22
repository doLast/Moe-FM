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
	[self.resourceCollection stopFetch];
	self.resourceCollection = nil;
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
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	MFMResourceFav *resource = [self.resourceCollection objectAtIndex:indexPath.row];
	if ([resource.obj isKindOfClass:[MFMResourceSub class]]) {
		MFMResourceSub *sub = (MFMResourceSub *)resource.obj;
		
		cell.textLabel.text = sub.subTitle;
		cell.detailTextLabel.text = sub.wiki.wikiTitle;
	}
	else if ([resource.obj isKindOfClass:[MFMResourceWiki class]]) {
		MFMResourceWiki *wiki = (MFMResourceWiki *)resource.obj;
		cell.textLabel.text = wiki.wikiTitle;
		cell.detailTextLabel.text = @"";
		
		if (wiki.wikiType == MFMResourceObjTypeMusic) 
		for (NSDictionary *meta in wiki.wikiMeta) {
			if ([[meta objectForKey:@"meta_key"] isEqualToString:@"艺术家"]) {
				cell.detailTextLabel.text = [meta objectForKey:@"meta_value"];
			}
		}
		
		if (cell.detailTextLabel.text.length == 0) 
		for (NSDictionary *meta in wiki.wikiMeta) {
			if ([[meta objectForKey:@"meta_key"] isEqualToString:@"简介"]) {
				cell.detailTextLabel.text = [meta objectForKey:@"meta_value"];
			}
		}
		
		if (cell.detailTextLabel.text.length == 0) {
			cell.detailTextLabel.text = NSLocalizedString(@"UNKNOWN_ARTIST", @"");
		}
	}

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
	self.page = 0;
	if ([self.resourceCollection reloadResources] == NO){
		NSLog(@"Cannot refresh");
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
	if (notification.name == MFMResourceNotification  && 
		notification.object == self.resourceCollection) {
		if (self.resourceCollection.error != nil) {
			[self.tableView.pullToRefreshView stopAnimating];
			return;
		}
		
		self.page++;
		[self.tableView reloadData];
		[self.tableView.pullToRefreshView stopAnimating];
		[self.tableView.infiniteScrollingView stopAnimating];
	}
}

@end
