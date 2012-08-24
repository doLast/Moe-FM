//
//  MFMWikiViewController.m
//  Moe FM
//
//  Created by Greg Wang on 12-8-24.
//
//

#import "MFMWikiViewController.h"
#import "MFMWikiCell.h"

#import "SVPullToRefresh.h"
#import "MFMPlayerManager.h"

#import "MFMResourceWiki.h"
#import "MFMResourceFav.h"
#import "MFMResourceSubs.h"

@interface MFMWikiViewController ()

@end

@implementation MFMWikiViewController

@synthesize resourceWiki = _resourceWiki;
@synthesize resourceFav = _resourceFav;

#pragma mark - view life cycle

- (void)viewDidLoad
{
    if (self.resourceWiki != nil && [self.resourceWiki isKindOfClass:[MFMResourceWiki class]]) {
		MFMResourceObjType subType = MFMResourceObjTypeEp;
		if (self.resourceWiki.wikiType == MFMResourceObjTypeMusic) {
			subType = MFMResourceObjTypeSong;
		}
		self.resourceCollection = [MFMResourceSubs subsWithWikiId:self.resourceWiki.wikiId wikiName:nil wikiType:self.resourceWiki.wikiType subType:subType perPage:MFMResourcePerPageDefault];
		
		[super viewDidLoad];
	}
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
		return 1;
	}
	return [self.resourceCollection count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 0) {
		static NSString *CellIdentifier = @"WikiCell";
		MFMWikiCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		
		cell.bounds = CGRectMake(cell.bounds.origin.x, cell.bounds.origin.y, cell.bounds.size.width, 200);
		cell.resource = self.resourceWiki;
		cell.resourceFav = self.resourceFav;
        
		return cell;
	}
	
	static NSString *CellIdentifier = @"ResourceCell";
	MFMResourceCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	cell.resource = [self.resourceCollection objectAtIndex:indexPath.row];
	cell.titleLabel.text = [NSString stringWithFormat:@"%d. %@", indexPath.row + 1, cell.titleLabel.text];
	cell.subtitleLabel.text = @"";
	
	return cell;
}

- (void)refreshData
{
	if ([self.resourceCollection count] == 0) {
		return [super refreshData];
	}
	
	[self.tableView.pullToRefreshView stopAnimating];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 0) {
		return 128;
	}
	
	return 44;
}

@end
