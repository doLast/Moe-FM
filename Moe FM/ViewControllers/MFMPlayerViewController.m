//
//  MFMPlayerViewController.m
//  Moe FM
//
//  Created by Greg Wang on 12-7-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MFMPlayerViewController.h"
#import "PPRevealSideViewController.h"
#import "MFMPlayerManager.h"
#import "MFMResourceSong.h"

#import <QuartzCore/QuartzCore.h>


@interface MFMPlayerViewController ()

@end

@implementation MFMPlayerViewController

@synthesize navTitle = _navTitle;
@synthesize songNameLabel = _songNameLabel;
@synthesize songInfoLabel = _songInfoLabel;
@synthesize songProgressIndicator = _songProgressIndicator;
@synthesize songArtworkImage = _songArtworkImage;
@synthesize songArtworkLoadingIndicator = _songArtworkLoadingIndicator;
@synthesize songBufferingIndicator = _songBufferingIndicator;
@synthesize playButton = _playButton;
@synthesize favButton = _favButton;
@synthesize dislikeButton = _dislikeButton;
@synthesize nextButton = _nextButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	
	// Allow application to recieve remote control
	UIApplication *application = [UIApplication sharedApplication];
	if([application respondsToSelector:@selector(beginReceivingRemoteControlEvents)])
		[application beginReceivingRemoteControlEvents];
	[self becomeFirstResponder]; // this enables listening for events
	
	// Decorate the songArtworkImage
	CALayer *layer = self.songArtworkImage.layer;
    [layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [layer setBorderWidth:4.0f];
    [layer setShadowColor: [[UIColor blackColor] CGColor]];
    [layer setShadowOpacity:0.5f];
    [layer setShadowOffset: CGSizeMake(1, 3)];
    [layer setShadowRadius:2.0];
    [self.songArtworkImage setClipsToBounds:NO];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:MFMPlayerSongChangedNotification object:[MFMPlayerManager sharedPlayerManager]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:MFMPlayerStatusChangedNotification object:[MFMPlayerManager sharedPlayerManager]];
	
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)canBecomeFirstResponder
{
	return YES;
}

#pragma mark - Actions

- (IBAction)showMenu:(UIBarButtonItem *)sender
{
	PPRevealSideViewController *revealSideViewController = (PPRevealSideViewController *)self.navigationController.parentViewController;
	[revealSideViewController pushOldViewControllerOnDirection:PPRevealSideDirectionTop withOffset:53 animated:YES];
}

- (IBAction)togglePlaybackState:(UIButton *)sender
{
	MFMPlayerManager *playerManager = [MFMPlayerManager sharedPlayerManager];
	if ([playerManager pause] == NO) {
		NSLog(@"Toggle to Play");
		[playerManager play];
	}
}

- (IBAction)toggleFavourite:(UIButton *)sender
{
	
}

- (IBAction)toggleDislike:(UIButton *)sender
{
	
}

- (IBAction)nextTrack:(UIButton *)sender
{
	MFMPlayerManager *playerManager = [MFMPlayerManager sharedPlayerManager];
	[playerManager next];
}

#pragma mark - NotificationCenter

- (void)updateSongInfo
{
	MFMResourceSong *currentSong = [MFMPlayerManager sharedPlayerManager].currentSong;
	if (currentSong != nil) {
		self.songNameLabel.text = currentSong.subTitle;
		self.songInfoLabel.text = [NSString stringWithFormat:@"%@ / %@", currentSong.artist, currentSong.wikiTitle];
	}
}

- (void)handleNotification:(NSNotification *)notification
{
	if (notification.name == MFMPlayerSongChangedNotification) {
		[self updateSongInfo];
	}
	else if (notification.name == MFMPlayerStatusChangedNotification) {
		
	}
}

@end
