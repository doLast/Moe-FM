//
//  MFMHttpImageView.m
//  Moe FM
//
//  Created by Greg Wang on 12-8-21.
//
//

#import "MFMHttpImageView.h"
#import "MFMDataFetcher.h"

@interface MFMHttpImageView () <MFMDataFetcherDelegate>

@property (nonatomic, strong) UIImage *placeholderImage;
@property (nonatomic, strong) UIImage *highlightedPlaceholderImage;
@property (nonatomic, strong) MFMDataFetcher *fetcher;

@end

@implementation MFMHttpImageView

#pragma mark - Getter & Setter

@synthesize delegate = _delegate;
@synthesize imageURL = _imageURL;
@synthesize placeholderImage = _placeholderImage;
@synthesize highlightedPlaceholderImage = _highlightedPlaceholderImage;
@synthesize fetcher = _fetcher;

- (void)setImageURL:(NSURL *)imageURL
{
	if (imageURL == nil || imageURL == _imageURL) {
		return;
	}
	_imageURL = imageURL;
	[self startFetching];
}

#pragma mark - Constructors

- (void)awakeFromNib
{
	self.placeholderImage = self.image;
	self.highlightedPlaceholderImage = self.highlightedImage;
}

- (id)initWithImage:(UIImage *)image
{
	self = [super initWithImage:image];
	if (self != nil) {
		self.placeholderImage = image;
		self.highlightedPlaceholderImage = nil;
	}
	return self;
}

- (id)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage
{
	self = [super initWithImage:image highlightedImage:highlightedImage];
	if (self != nil) {
		self.placeholderImage = image;
		self.highlightedPlaceholderImage = highlightedImage;
	}
	return self;
}

#pragma mark - Actions

- (void)startFetching
{
	if (self.imageURL == nil) {
		return;
	}
	
	[self stopFetching];
	self.fetcher = [[MFMDataFetcher alloc] initWithURL:self.imageURL dataType:MFMDataTypeImage];
	
	NSLog(@"ImageView start fetching URL: %@", self.imageURL);
	[self.fetcher beginFetchWithDelegate:self];
}

- (void)stopFetching
{
	if (self.fetcher != nil) {
		MFMDataFetcher *oldFetcher = self.fetcher;
		self.fetcher = nil;
		[oldFetcher stop];
	}
	
//	self.image = self.placeholderImage;
//	self.highlightedImage = self.highlightedPlaceholderImage;
}

# pragma mark - MFMDataFetcherDelegate

- (void)fetcher:(MFMDataFetcher *)dataFetcher didFinishWithImage:(UIImage *)image
{
	if (self.delegate != nil && [self.delegate respondsToSelector:@selector(imageView:willFinishLoadingImage:)]) {
		[self.delegate imageView:self willFinishLoadingImage:image];
	}
	self.image = image;
	self.highlightedImage = image;
	if (self.delegate != nil && [self.delegate respondsToSelector:@selector(imageView:didFinishLoadingImage:)]) {
		[self.delegate imageView:self didFinishLoadingImage:image];
	}
}

- (void)fetcher:(MFMDataFetcher *)dataFetcher didFinishWithError:(NSError *)error
{
	NSLog(@"ImageView fail to load %@", self.imageURL);
	self.fetcher = nil;
	[self stopFetching];
	
	if (self.delegate != nil && [self.delegate respondsToSelector:@selector(imageView:didFailLoadingURL:)]) {
		[self.delegate imageView:self didFailLoadingURL:self.imageURL];
	}
}

@end