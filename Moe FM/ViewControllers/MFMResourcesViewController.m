//
//  MFMResourcesViewController.m
//  Moe FM
//
//  Created by Greg Wang on 12-8-25.
//
//

#import "MFMResourcesViewController.h"
#import "MFMResourceCell.h"
#import "SVPullToRefresh.h"
#import "YRDropdownView.h"

#import "MFMPlayerManager.h"
#import "MFMResourceCollection.h"
#import "MFMResourcePlaylist.h"

@interface MFMResourcesViewController ()

@property (nonatomic) NSUInteger page;

@end

@implementation MFMResourcesViewController

@synthesize playAllButton = _playAllButton;
@synthesize resourceCollection = _resourceCollection;
@synthesize page = _page;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.playAllButton.title = NSLocalizedString(@"PLAY_ALL", @"");

	// Pull to refresh config
	__weak MFMResourcesViewController *_self = self;
	
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
	static NSString *CellIdentifier = @"ResourceCell";
	MFMResourceCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	MFMResource *resource = [self.resourceCollection objectAtIndex:indexPath.row];
	cell.resource = resource;
	
	return cell;
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
		MFMResource *resource = [self.resourceCollection objectAtIndex:indexPath.row];
		MFMResourcePlaylist *resourcePlaylist = [MFMResourcePlaylist playlistWithResource:resource];
		playerManager.playlist = resourcePlaylist;
		playerManager.trackNum = 0;
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
			[YRDropdownView showDropdownInView:self.navigationController.view title:@"Error" detail:[self.resourceCollection.error localizedDescription] accessoryView:nil animated:YES hideAfter:2.0f];
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
			NSInteger section = [self numberOfSectionsInTableView:self.tableView] - 1;
			NSMutableArray *indexPaths = [NSMutableArray array];
			for (i = [self.tableView numberOfRowsInSection:section]; i < [self.resourceCollection count]; i++) {
				[indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:section]];
			}
			[self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:NO];
		}
		[self.tableView.pullToRefreshView stopAnimating];
		[self.tableView.infiniteScrollingView stopAnimating];
	}
}

@end
