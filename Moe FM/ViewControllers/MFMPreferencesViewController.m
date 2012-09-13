//
//  MFMPreferencesViewController.m
//  Moe FM
//
//  Created by Greg Wang on 12-9-11.
//
//

#import "MFMPreferencesViewController.h"

@interface MFMPreferencesViewController ()

@end

@implementation MFMPreferencesViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	UIBarButtonItem *hideButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
	self.navigationItem.rightBarButtonItem = hideButton;
}

- (IBAction)done:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];
}

+ (QRootElement *)createElements
{
	QRootElement *root = [[QRootElement alloc] init];
	root.title = NSLocalizedString(@"PREFERENCES", @"");
	root.controllerName = @"MFMPreferencesViewController";
	
	root.grouped = YES;
	QSection *section = [[QSection alloc] init];
	QLabelElement *label = [[QLabelElement alloc] initWithTitle:@"Hello" Value:@"world!"];
	
	[root addSection:section];
	[section addElement:label];
	
	return root;
}

+ (void)showPreferencesInViewController:(UIViewController *)viewController
{
	QRootElement *root = [MFMPreferencesViewController createElements];
	UINavigationController *preferences = [QuickDialogController controllerWithNavigationForRoot:root];
	[viewController presentModalViewController:preferences animated:YES];
}

@end
