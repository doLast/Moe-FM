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

@property (retain, nonatomic) PPRevealSideViewController *revealSideViewController;

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
	
	UINavigationController *playerController = [self.storyboard instantiateViewControllerWithIdentifier:@"PlayerNavigation"];
	UINavigationController *menuController = [self.storyboard instantiateViewControllerWithIdentifier:@"MenuNavigation"];
	
	PPRevealSideViewController *revealSideViewController = [[PPRevealSideViewController alloc] initWithRootViewController:playerController];
	[revealSideViewController preloadViewController:menuController forSide:PPRevealSideDirectionTop withOffset:53];
	revealSideViewController.panInteractionsWhenClosed = PPRevealSideInteractionContentView | PPRevealSideInteractionNavigationBar;
	
	revealSideViewController.delegate = self;
	
	self.revealSideViewController = revealSideViewController;
	
	[self presentViewController:self.revealSideViewController animated:NO completion:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - PPRevealSideViewController delegate

//- (void) pprevealSideViewController:(PPRevealSideViewController *)controller willPushController:(UIViewController *)pushedController {
//    
//}
//
//- (void) pprevealSideViewController:(PPRevealSideViewController *)controller didPushController:(UIViewController *)pushedController {
//    
//}
//
//- (void) pprevealSideViewController:(PPRevealSideViewController *)controller willPopToController:(UIViewController *)centerController {
//    
//}
//
//- (void) pprevealSideViewController:(PPRevealSideViewController *)controller didPopToController:(UIViewController *)centerController {
//    
//}
//
//- (void) pprevealSideViewController:(PPRevealSideViewController *)controller didChangeCenterController:(UIViewController *)newCenterController {
//    
//}
//
//- (BOOL) pprevealSideViewController:(PPRevealSideViewController *)controller shouldDeactivateDirectionGesture:(UIGestureRecognizer*)gesture forView:(UIView*)view {
//    return NO;    
//}

- (PPRevealSideDirection)pprevealSideViewController:(PPRevealSideViewController*)controller directionsAllowedForPanningOnView:(UIView*)view {
	
    return PPRevealSideDirectionTop;
}



@end
