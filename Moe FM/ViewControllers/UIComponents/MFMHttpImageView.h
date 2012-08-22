//
//  MFMHttpImageView.h
//  Moe FM
//
//  Created by Greg Wang on 12-8-21.
//
//

#import <UIKit/UIKit.h>

@class MFMHttpImageView;

@protocol MFMHttpImageViewDelegate <NSObject>

@optional
- (void)imageView:(MFMHttpImageView *)imageView willFinishLoadingImage:(UIImage *)image;
- (void)imageView:(MFMHttpImageView *)imageView didFinishLoadingImage:(UIImage *)image;
- (void)imageView:(MFMHttpImageView *)imageView didFailLoadingWithError:(NSError *)error;

@end

@interface MFMHttpImageView : UIImageView

@property (nonatomic, weak) id <MFMHttpImageViewDelegate> delegate;
@property (nonatomic, strong) NSURL *imageURL;

- (void)stopFetching;

@end
