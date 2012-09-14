//
//  MFMNetworkManager.m
//  Moe FM
//
//  Created by Greg Wang on 12-8-22.
//
//

#import "MFMNetworkManager.h"
#import "Reachability.h"

NSString * MFMAllowedNetworkTypeSetting = @"MFMAllowedNetworkTypeSetting";

@interface MFMNetworkManager ()

@property (nonatomic) BOOL allowConnection;
@property (nonatomic, strong) Reachability *reachability;

@end

@implementation MFMNetworkManager

@synthesize allowConnection = _allowConnection;

- (MFMNetworkType)allowedNetworkType
{
	NSNumber *networkType = [[NSUserDefaults standardUserDefaults] objectForKey:MFMAllowedNetworkTypeSetting];
	return networkType.intValue;
}

- (void)setAllowedNetworkType:(MFMNetworkType)allowedNetworkType
{
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:allowedNetworkType] forKey:MFMAllowedNetworkTypeSetting];
	[self updateReachability:self.reachability];
}

+ (MFMNetworkManager *)sharedNetworkManager
{
	static MFMNetworkManager *networkManager = nil;
	if (networkManager == nil) {
		networkManager = [[MFMNetworkManager alloc] init];
	}
	return networkManager;
}

- (MFMNetworkManager *)init
{
	self = [super init];
	if (self != nil) {
		// Default network preferences
		[[NSUserDefaults standardUserDefaults]
		 registerDefaults:[NSDictionary
						   dictionaryWithObjectsAndKeys:
						   [NSNumber numberWithInt:MFMNetworkTypeWifi], MFMAllowedNetworkTypeSetting, nil]];
		
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
		self.reachability = [Reachability reachabilityForInternetConnection];
		[self.reachability startNotifier];
		[self updateReachability:self.reachability];
	}
	return self;
}

//Called by Reachability whenever status changes.
- (void) reachabilityChanged: (NSNotification* )notification
{
	Reachability* curReach = notification.object;
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
	
	[self updateReachability:curReach];
}

- (void) updateReachability:(Reachability *)curReach
{
	NetworkStatus networkStatus = [curReach currentReachabilityStatus];

	if(networkStatus == ReachableViaWWAN && self.allowedNetworkType >= MFMNetworkTypeWWAN){
		self.allowConnection = YES;
	}
	else if(networkStatus == ReachableViaWiFi && self.allowedNetworkType >= MFMNetworkTypeWifi){
		self.allowConnection = YES;
	}
	else {
		self.allowConnection = NO;
	}
}

@end
