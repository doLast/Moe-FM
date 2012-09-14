//
//  MFMPreferencesViewController.h
//  Moe FM
//
//  Created by Greg Wang on 12-9-11.
//
//

#import <UIKit/UIKit.h>

@interface MFMPreferencesViewController : QuickDialogController <QuickDialogStyleProvider>

+ (void)showPreferencesInViewController:(UIViewController *)viewController;

@end
