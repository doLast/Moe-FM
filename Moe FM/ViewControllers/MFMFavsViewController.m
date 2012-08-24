//
//  MFMFavsViewController.h.m
//  Moe FM
//
//  Created by Greg Wang on 12-7-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MFMFavsViewController.h"
#import "MFMWikiViewController.h"
#import "MFMFavCell.h"

#import "MFMResourceFavs.h"
#import "MFMResourceFav.h"

@interface MFMFavsViewController ()

@end

@implementation MFMFavsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"FavCell";
	MFMFavCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	MFMResourceFav *resource = [self.resourceCollection objectAtIndex:indexPath.row];
	cell.resourceFav = resource;

	return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	[self performSegueWithIdentifier:@"ShowDetail" sender:cell];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"ShowDetail"] && [sender isKindOfClass:[MFMFavCell class]]) {
		MFMFavCell *cell = (MFMFavCell *)sender;
		MFMResourceFav *fav = cell.resourceFav;
		assert(fav.favType < MFMResourceObjTypeWiki);
		MFMResourceWiki *wiki = (MFMResourceWiki *) fav.obj;
		
		MFMWikiViewController *vc = segue.destinationViewController;
		vc.resourceWiki = wiki;
		vc.resourceFav = fav;
	}
}

@end
