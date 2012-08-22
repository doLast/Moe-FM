//
//  MFMNetworkManager.h
//  Moe FM
//
//  Created by Greg Wang on 12-8-22.
//
//

#import <Foundation/Foundation.h>

typedef enum {
	MFMNetworkTypeWifi = 0,
	MFMNetworkTypeWWAN,
	MFMNetworkTypeAll,
	MFMNetworkTypeTotal
} MFMNetworkType;

@interface MFMNetworkManager : NSObject

@property (nonatomic) MFMNetworkType allowedNetworkType;
@property (nonatomic, readonly) BOOL allowConnection;

+ (MFMNetworkManager *)sharedNetworkManager;

@end
