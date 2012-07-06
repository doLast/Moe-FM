//
//  MFMPlayerViewController.m
//  Moe FM
//
//  Created by Greg Wang on 12-7-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MFMPlayerViewController.h"
#import "PPRevealSideViewController.h"
#import "MFMResource.h"
#import "MFMResourceWiki.h"
#import "MFMResourceSub.h"
#import "MFMResourceFav.h"
#import "MFMResourceFavs.h"

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
	
	// Decorate the songArtworkImage
	CALayer *layer = self.songArtworkImage.layer;
    [layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [layer setBorderWidth:4.0f];
    [layer setShadowColor: [[UIColor blackColor] CGColor]];
    [layer setShadowOpacity:0.5f];
    [layer setShadowOffset: CGSizeMake(1, 3)];
    [layer setShadowRadius:2.0];
    [self.songArtworkImage setClipsToBounds:NO];
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

#pragma mark - Actions

- (IBAction)showMenu:(UIBarButtonItem *)sender
{
	PPRevealSideViewController *revealSideViewController = (PPRevealSideViewController *)self.navigationController.parentViewController;
	[revealSideViewController pushOldViewControllerOnDirection:PPRevealSideDirectionTop withOffset:53 animated:YES];
}

- (IBAction)togglePlaybackState:(UIButton *)sender
{
//	NSString *urlStr = @"http://api.moefou.org/user/favs/sub.json?user_name=gregwym&obj_type=song&api_key=302182858672af62ebf4524ee8d9a06304f7db527";
//	NSURL *url = [NSURL URLWithString:urlStr];
	static MFMResourceFavs *resourceFavs;
	if (resourceFavs == nil) {
		resourceFavs = [MFMResourceFavs favsWithUid:nil userName:@"gregwym" objType:MFMFavObjTypeSong favType:MFMFavTypeHeart page:nil perpage:[NSNumber numberWithInt:2]];
	}
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self selector:@selector(handleNotification:) name:MFMResourceNotification object:resourceFavs];
	
	[resourceFavs startFetch];
}

- (IBAction)toggleFavourite:(UIButton *)sender
{
	
}

- (IBAction)toggleDislike:(UIButton *)sender
{
	
}

- (IBAction)nextTrack:(UIButton *)sender
{
	
}

- (void)handleNotification:(NSNotification *)notification
{
//	MFMResource *resource = [notification object];
//	NSDictionary *result = resource.resource;
//	NSLog(@"%@", result);
//	NSArray *wikis = [result objectForKey:@"wikis"];
//	for (NSDictionary *wiki in wikis) {
//		MFMResourceWiki *resourceWiki = [[MFMResourceWiki alloc] initWithResouce:wiki];
//		NSLog(@"%@", resourceWiki);
//	}
	
//	NSArray *subs = [result objectForKey:@"subs"];
//	for (NSDictionary *sub in subs) {
//		MFMResourceSub *resourceSub = [[MFMResourceSub alloc] initWithResouce:sub];
//		NSLog(@"%@", resourceSub);
//	}
	
//	NSArray *favs = [result objectForKey:@"favs"];
//	for (NSDictionary *fav in favs) {
//		MFMResourceFav *resourceFav = [[MFMResourceFav alloc] initWithResouce:fav];
//		NSLog(@"%@", resourceFav);
//	}
	
	MFMResourceFavs *resourceFavs = [notification object];
	NSLog(@"%@", resourceFavs);
}

@end
