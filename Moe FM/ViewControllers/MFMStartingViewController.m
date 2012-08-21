//
//  MFMStartingViewController.m
//  Moe FM
//
//  Created by Greg Wang on 12-7-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MFMStartingViewController.h"
#import "PPRevealSideViewController.h"

@interface MFMStartingViewController ()

@property (nonatomic, strong) PPRevealSideViewController *revealSideViewController;
@property (nonatomic, weak) UINavigationController *playerNavigationController;
@property (nonatomic, weak) UINavigationController *menuNavigationController;
@property (nonatomic, weak) UIViewController *playbackControlViewController;

@end

@implementation MFMStartingViewController

@synthesize revealSideViewController = _revealSideViewController;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	UINavigationController *player = [self.storyboard instantiateViewControllerWithIdentifier:@"PlayerNavigation"];
	UINavigationController *menu = [self.storyboard instantiateViewControllerWithIdentifier:@"MenuNavigation"];
	UIViewController *playbackControl = [self.storyboard instantiateViewControllerWithIdentifier:@"PlaybackControl"];
	PPRevealSideViewController *revealSideViewController = [[PPRevealSideViewController alloc] initWithRootViewController:player];
	
	[revealSideViewController preloadViewController:menu forSide:PPRevealSideDirectionTop withOffset:53];
	[revealSideViewController preloadViewController:playbackControl forSide:PPRevealSideDirectionLeft withOffset:250];
	[revealSideViewController preloadViewController:playbackControl forSide:PPRevealSideDirectionRight withOffset:250];
	
	revealSideViewController.panInteractionsWhenClosed = PPRevealSideInteractionContentView | PPRevealSideInteractionNavigationBar;
	revealSideViewController.delegate = self;
	
	self.revealSideViewController = revealSideViewController;
	self.playerNavigationController = player;
	self.menuNavigationController = menu;
	self.playbackControlViewController = playbackControl;
	
	[self presentViewController:self.revealSideViewController animated:NO completion:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - PPRevealSideViewController delegate

- (void) pprevealSideViewController:(PPRevealSideViewController *)controller willPushController:(UIViewController *)pushedController {
	if (pushedController == self.menuNavigationController) {
		[self.playerNavigationController setNavigationBarHidden:NO animated:YES];
		[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
	}
}

//- (void) pprevealSideViewController:(PPRevealSideViewController *)controller didPushController:(UIViewController *)pushedController {
//	
//}

//- (void) pprevealSideViewController:(PPRevealSideViewController *)controller willPopToController:(UIViewController *)centerController {
//    
//}

- (void) pprevealSideViewController:(PPRevealSideViewController *)controller didPopToController:(UIViewController *)centerController {
	[self.playerNavigationController setNavigationBarHidden:YES animated:YES];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
}

//- (void) pprevealSideViewController:(PPRevealSideViewController *)controller didChangeCenterController:(UIViewController *)newCenterController {
//    
//}

//- (BOOL) pprevealSideViewController:(PPRevealSideViewController *)controller shouldDeactivateDirectionGesture:(UIGestureRecognizer*)gesture forView:(UIView*)view {
//    return NO;    
//}

- (PPRevealSideDirection)pprevealSideViewController:(PPRevealSideViewController*)controller directionsAllowedForPanningOnView:(UIView*)view {	
    return PPRevealSideDirectionTop | PPRevealSideDirectionLeft | PPRevealSideDirectionRight;
}



@end
