//
//  MFMPlaybackControlViewController.h
//  Moe FM
//
//  Created by Greg Wang on 12-8-21.
//
//

#import <UIKit/UIKit.h>

@interface MFMPlaybackControlViewController : UIViewController

@property (assign, nonatomic) IBOutlet UIButton *playButtonR;
@property (assign, nonatomic) IBOutlet UIButton *favButtonR;
@property (assign, nonatomic) IBOutlet UIButton *dislikeButtonR;
@property (assign, nonatomic) IBOutlet UIButton *nextButtonR;
@property (assign, nonatomic) IBOutlet UIButton *playButtonL;
@property (assign, nonatomic) IBOutlet UIButton *favButtonL;
@property (assign, nonatomic) IBOutlet UIButton *dislikeButtonL;
@property (assign, nonatomic) IBOutlet UIButton *nextButtonL;

@end
