//
//  MFMAppDelegate.h
//  Moe FM
//
//  Created by Greg Wang on 12-4-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import "MFMPlayerViewController.h"
#import <UIKit/UIKit.h>
@class MFMPlayerViewController;


@interface MFMAppDelegate : UIResponder <UIApplicationDelegate>{
    //MFMPlayerViewController     *mfviewcontroller;
    UIViewController *viewcontroller;
    
}

@property (strong, nonatomic) UIWindow *window;
//@property (strong, nonatomic) IBOutlet MFMPlayerViewController *mfviewcontroller;
@property (strong, nonatomic) UIViewController *viewcontroller;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
