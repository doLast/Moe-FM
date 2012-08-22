//
//  MFMNetworkManager.m
//  Moe FM
//
//  Created by Greg Wang on 12-8-22.
//
//

#import "MFMNetworkManager.h"
#import "Reachability.h"

@interface MFMNetworkManager ()

@property (nonatomic) BOOL allowConnection;
@property (nonatomic, strong) Reachability *reachability;

@end

@implementation MFMNetworkManager

@synthesize allowConnection = _allowConnection;
@synthesize allowedNetworkType = _allowedNetworkType;

- (void)setAllowedNetworkType:(MFMNetworkType)allowedNetworkType
{
	_allowedNetworkType	= allowedNetworkType;
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
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
		self.reachability = [Reachability reachabilityForInternetConnection];
		self.allowedNetworkType = MFMNetworkTypeWifi;
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
