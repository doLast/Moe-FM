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
@property (nonatomic, readonly) NSCache *imageCache;

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

- (NSCache *)imageCache
{
	static NSCache * imageCache = nil;
	if (imageCache == nil) {
		imageCache = [[NSCache alloc] init];
		imageCache.countLimit = 500;
	}
	return imageCache;
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

- (void)dealloc
{
	[self stopFetching];
}

#pragma mark - Actions

- (void)resetImage
{
	self.image = self.placeholderImage;
	self.highlightedImage = self.highlightedImage;
}

- (void)startFetching
{
	if (self.imageURL == nil) {
		return;
	}
	[self stopFetching];
	
	UIImage *image = [self.imageCache objectForKey:self.imageURL];
	if (image != nil) {
//		NSLog(@"ImageView loaded from cache for URL: %@", self.imageURL);
		[self fetcher:nil didFinishWithImage:image];
		return;
	}
	
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
	
	if (dataFetcher != nil) {
		[self.imageCache setObject:image forKey:self.imageURL];
		NSLog(@"Image cached for URL: %@", self.imageURL);
	}
	
	self.image = image;
	self.highlightedImage = image;
	if (self.delegate != nil && [self.delegate respondsToSelector:@selector(imageView:didFinishLoadingImage:)]) {
		[self.delegate imageView:self didFinishLoadingImage:image];
	}
	self.fetcher = nil;
}

- (void)fetcher:(MFMDataFetcher *)dataFetcher didFinishWithError:(NSError *)error
{
	NSLog(@"ImageView fail to load %@", self.imageURL);
	[self stopFetching];
	
	if (self.delegate != nil && [self.delegate respondsToSelector:@selector(imageView:didFailLoadingURL:)]) {
		[self.delegate imageView:self didFailLoadingWithError:error];
	}
	self.fetcher = nil;
}

@end
