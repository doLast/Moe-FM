//
//  MFMMenuViewController.m
//  Moe FM
//
//  Created by Greg Wang on 12-7-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MFMMenuViewController.h"
#import "PPRevealSideViewController.h"
#import "MFMFavsViewController.h"
#import "MFMPlayerManager.h"

#import "MFMResourcePlaylist.h"
#import "MFMResourceFavs.h"
#import "MFMOAuth.h"

@interface MFMMenuViewController ()

@end


@implementation MFMMenuViewController

@synthesize authorizationButton = _authorizationButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOAuthStatusChanged:) name:MFMOAuthStatusChangedNotification object:[MFMOAuth sharedOAuth]];
	[self updateAuthorization];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - view updates

- (void)updateAuthorization
{
	if ([MFMOAuth sharedOAuth].canAuthorize) {
		self.authorizationButton.title = NSLocalizedString(@"SIGN_OUT", @"");
	}
	else {
		self.authorizationButton.title = NSLocalizedString(@"SIGN_IN", @"");
	}
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    return 0;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    
//    // Configure the cell...
//    
//    return cell;
//}

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
	if (indexPath.row == 0) {
		MFMResourcePlaylist *resourcePlaylist = [MFMResourcePlaylist magicPlaylist];
		MFMPlayerManager *playerManager = [MFMPlayerManager sharedPlayerManager];
		playerManager.playlist = resourcePlaylist;
		
		PPRevealSideViewController *revealSideVC = (PPRevealSideViewController *)self.navigationController.parentViewController;
		[revealSideVC popViewControllerAnimated:YES];
	}
}

#pragma mark - Actions

- (IBAction)showLogin:(id)sender
{
	[[MFMOAuth sharedOAuth] signInWithNavigationController:self.navigationController];
}

- (IBAction)logout:(id)sender
{
	[[MFMOAuth sharedOAuth] signOut];
}

- (IBAction)toggleSignIn:(id)sender
{
	if ([MFMOAuth sharedOAuth].canAuthorize) {
		[self logout:sender];
	}
	else {
		[self showLogin:sender];
	}
}

#pragma mark - handle notification

- (void)handleOAuthStatusChanged:(NSNotification *)notification
{
	[self updateAuthorization];
}

#pragma mark - segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"ShowFavSongs"]) {
		MFMFavsViewController *vc = segue.destinationViewController;
		MFMResourceFavs *favs = [MFMResourceFavs favsWithUid:nil
													userName:nil
													 objType:MFMResourceObjTypeSong
													 favType:MFMFavTypeHeart
													fromPage:[NSNumber numberWithInt:1]
													 perPage:[NSNumber numberWithInteger:MFMResourcePerPageDefault]];
		
		vc.resourceCollection = favs;
	}
	else if ([segue.identifier isEqualToString:@"ShowFavMusics"]) {
		
	}
	else if ([segue.identifier isEqualToString:@"ShowFavRadios"]) {
		
	}
}

@end
