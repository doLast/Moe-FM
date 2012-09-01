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
#import "MFMResourceCell.h"

#import "MFMResourcePlaylist.h"
#import "MFMResourceFavs.h"
#import "MFMOAuth.h"

@interface MFMMenuViewController ()

@property (nonatomic, strong) NSArray *menuItems;

@end


@implementation MFMMenuViewController

@synthesize authorizationButton = _authorizationButton;
@synthesize menuItems = _menuItems;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.title = NSLocalizedString(@"APP_NAME", @"");
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOAuthStatusChanged:) name:MFMOAuthStatusChangedNotification object:[MFMOAuth sharedOAuth]];
	[self updateAuthorization];
	
	self.menuItems = [NSArray arrayWithObjects:@"RANDOM_PLAY", @"FAV_SONGS", @"FAV_MUSICS", @"FAV_RADIOS", nil];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.menuItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MenuCell";
    MFMResourceCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell.titleLabel.text = NSLocalizedString([self.menuItems objectAtIndex:indexPath.row], @"");
    
    return cell;
}

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
	else if (![MFMOAuth sharedOAuth].canAuthorize) {
		[[MFMOAuth sharedOAuth] signInWithNavigationController:self.navigationController];
	}
	else if (indexPath.row == 1) {
		[self performSegueWithIdentifier:@"ShowFavSongs" sender:self];
	}
	else if (indexPath.row == 2) {
		[self performSegueWithIdentifier:@"ShowFavMusics" sender:self];
	}
	else if (indexPath.row == 3) {
		[self performSegueWithIdentifier:@"ShowFavRadios" sender:self];
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
		MFMResourceFavs *favs = [MFMResourceFavs favsWithUid:nil userName:nil objType:MFMResourceObjTypeSong favType:MFMFavTypeHeart perPage:MFMResourcePerPageDefault];
		
		vc.resourceCollection = favs;
		vc.title = NSLocalizedString(@"FAV_SONGS", @"");
	}
	else if ([segue.identifier isEqualToString:@"ShowFavMusics"]) {
		MFMFavsViewController *vc = segue.destinationViewController;
		MFMResourceFavs *favs = [MFMResourceFavs favsWithUid:nil userName:nil objType:MFMResourceObjTypeMusic favType:MFMFavTypeHeart perPage:MFMResourcePerPageDefault];
		vc.resourceCollection = favs;
		vc.title = NSLocalizedString(@"FAV_MUSICS", @"");
	}
	else if ([segue.identifier isEqualToString:@"ShowFavRadios"]) {
		MFMFavsViewController *vc = segue.destinationViewController;
		MFMResourceFavs *favs = [MFMResourceFavs favsWithUid:nil userName:nil objType:MFMResourceObjTypeRadio favType:MFMFavTypeHeart perPage:MFMResourcePerPageDefault];
		vc.resourceCollection = favs;
		vc.title = NSLocalizedString(@"FAV_RADIOS", @"");
	}
}

@end
