//
//  MFMPreferencesViewController.m
//  Moe FM
//
//  Created by Greg Wang on 12-9-11.
//
//

#import "MFMPreferencesViewController.h"
#import "PPRevealSideviewController.h"

#import "MFMNetworkManager.h"
#import "MFMOAuth.h"

@interface MFMPreferencesViewController ()

@end

@implementation MFMPreferencesViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	UIBarButtonItem *hideButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
	self.navigationItem.rightBarButtonItem = hideButton;
	
	self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.157809 green:0.492767 blue:0.959104 alpha:1];
}

- (void)setQuickDialogTableView:(QuickDialogTableView *)quickDialogTableView
{
	[super setQuickDialogTableView:quickDialogTableView];
	UIColor* bgColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"table-BG-pattern"]];
	[quickDialogTableView setBackgroundColor:bgColor];
}

- (void)cell:(UITableViewCell *)cell willAppearForElement:(QElement *)element atIndexPath:(NSIndexPath *)indexPath
{
	return;
}

- (IBAction)done:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)toggleCellularData:(id)sender
{
	QBooleanElement *element = sender;
	if (element.boolValue) {
		[[MFMNetworkManager sharedNetworkManager] setAllowedNetworkType:MFMNetworkTypeWWAN];
	}
	else {
		[[MFMNetworkManager sharedNetworkManager] setAllowedNetworkType:MFMNetworkTypeWifi];
	}
}

- (IBAction)toggleMoeFmSignIn:(id)sender
{
	QBooleanElement *element = sender;
	if (element.boolValue && ![MFMOAuth sharedOAuth].canAuthorize) {
		[[MFMOAuth sharedOAuth] signInWithNavigationController:self.navigationController];
	}
	else {
		[[MFMOAuth sharedOAuth] signOut];
	}
}

+ (QRootElement *)createElements
{
	QRootElement *root = [[QRootElement alloc] init];
	root.title = NSLocalizedString(@"PREFERENCES", @"");
	root.controllerName = @"MFMPreferencesViewController";
	root.grouped = YES;
	
	
	QSection *network = [[QSection alloc] initWithTitle:NSLocalizedString(@"NETWORK", @"")];
	[root addSection:network];
	
	QBooleanElement *allowCellularData = [[QBooleanElement alloc] initWithTitle:NSLocalizedString(@"ALLOW_CELLULAR_DATA_ACCESS", @"") BoolValue:[MFMNetworkManager sharedNetworkManager].allowedNetworkType > MFMNetworkTypeWifi];
	[allowCellularData setControllerAction:@"toggleCellularData:"];
	[network addElement:allowCellularData];
	
	
	QSection *account = [[QSection alloc] initWithTitle:NSLocalizedString(@"ACCOUNT", @"")];
	[root addSection:account];
	
	QBooleanElement *moeFmSign = [[QBooleanElement alloc] initWithTitle:NSLocalizedString(@"MOE_FM", @"") BoolValue:[MFMOAuth sharedOAuth].canAuthorize];
	[moeFmSign setControllerAction:@"toggleMoeFmSignIn:"];
	[account addElement:moeFmSign];
	
	NSArray *controlItems = [NSArray arrayWithObjects:NSLocalizedString(@"LEFT", @""), NSLocalizedString(@"RIGHT", @""), NSLocalizedString(@"BOTTOM", @""), nil];
	NSMutableArray *controlSelected = [NSMutableArray array];
	NSUInteger controlSetting = ((NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"MFMControlDirectionSetting"]).integerValue;
	if (controlSetting & PPRevealSideDirectionLeft) {
		[controlSelected addObject:[NSNumber numberWithInt:0]];
	}
	if (controlSetting & PPRevealSideDirectionRight) {
		[controlSelected addObject:[NSNumber numberWithInt:1]];
	}
	if (controlSetting & PPRevealSideDirectionBottom) {
		[controlSelected addObject:[NSNumber numberWithInt:2]];
	}
	
	NSLog(@"Selected: %@", controlSelected);
	QSelectSection *control = [[QSelectSection alloc] initWithItems:controlItems selectedIndexes:controlSelected title:NSLocalizedString(@"CONTROL", @"")];
	control.multipleAllowed = YES;
	[control setOnSelected:^{
		NSUInteger directions = 0;
		for (NSNumber *index in control.selectedIndexes) {
			if (index.integerValue == 0) {
				directions = directions | PPRevealSideDirectionLeft;
			}
			else if (index.integerValue == 1) {
				directions = directions | PPRevealSideDirectionRight;
			}
			else if (index.integerValue == 2) {
				 directions = directions | PPRevealSideDirectionBottom;
			}
		}
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:directions] forKey:@"MFMControlDirectionSetting"];
	}];
	[root addSection:control];
	
	return root;
}

+ (void)showPreferencesInViewController:(UIViewController *)viewController
{
	QRootElement *root = [MFMPreferencesViewController createElements];
	UINavigationController *preferences = [QuickDialogController controllerWithNavigationForRoot:root];
	[viewController presentModalViewController:preferences animated:YES];
}

@end
