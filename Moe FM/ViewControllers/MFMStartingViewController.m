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
@property (nonatomic, weak) UIViewController *leftControlViewController;
@property (nonatomic, weak) UIViewController *rightControlViewController;
@property (nonatomic, weak) UIViewController *bottomControlViewController;

@end

@implementation MFMStartingViewController

@synthesize revealSideViewController = _revealSideViewController;
@synthesize playerNavigationController = _playerNavigationController;
@synthesize menuNavigationController = _menuNavigationController;
@synthesize leftControlViewController = _leftControlViewController;
@synthesize rightControlViewController = _rightControlViewController;
@synthesize bottomControlViewController = _bottomControlViewController;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	
	// Default Control Direction
	[[NSUserDefaults standardUserDefaults]
	 registerDefaults:[NSDictionary
					   dictionaryWithObjectsAndKeys:
					   [NSNumber numberWithInteger:PPRevealSideDirectionBottom], @"MFMControlDirectionSetting", nil]];
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
	UIViewController *leftControl = [self.storyboard instantiateViewControllerWithIdentifier:@"LeftPlaybackControl"];
	UIViewController *rightControl = [self.storyboard instantiateViewControllerWithIdentifier:@"RightPlaybackControl"];
	UIViewController *bottomControl = [self.storyboard instantiateViewControllerWithIdentifier:@"BottomPlaybackControl"];
	PPRevealSideViewController *revealSideViewController = [[PPRevealSideViewController alloc] initWithRootViewController:player];
	
	CGSize viewSize = self.view.bounds.size;
	[revealSideViewController preloadViewController:menu forSide:PPRevealSideDirectionTop withOffset:53];
	[revealSideViewController preloadViewController:leftControl forSide:PPRevealSideDirectionLeft withOffset:viewSize.width - 70];
	[revealSideViewController preloadViewController:rightControl forSide:PPRevealSideDirectionRight withOffset:viewSize.width - 70];
	[revealSideViewController preloadViewController:bottomControl forSide:PPRevealSideDirectionBottom withOffset:viewSize.height - 70];
	
	revealSideViewController.panInteractionsWhenClosed = PPRevealSideInteractionContentView | PPRevealSideInteractionNavigationBar;
	revealSideViewController.delegate = self;
	
	self.revealSideViewController = revealSideViewController;
	self.playerNavigationController = player;
	self.menuNavigationController = menu;
	self.leftControlViewController = leftControl;
	self.rightControlViewController = rightControl;
	self.bottomControlViewController = bottomControl;
	
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
	NSUInteger controlSetting = ((NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"MFMControlDirectionSetting"]).integerValue;
    return PPRevealSideDirectionTop | controlSetting;
}



@end
