//
//  MKIncrementalReloadView.m
//  Example
//
//  Created by Mingenesis on 7/13/16.
//  Copyright © 2016 Mingenesis. All rights reserved.
//

#import "MKIncrementalReloadView.h"
#import "MKIncrementalImage.h"

@interface MKIncrementalReloadView ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation MKIncrementalReloadView

@synthesize loading = _loading;

+ (CGFloat)minHeightForReload {
    return 80;
}

+ (CGFloat)heightForLoading {
    return 50;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectZero];
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:contentView];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:nil];
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:imageView];
    
    NSDictionary *vs = NSDictionaryOfVariableBindings(contentView);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView]|" options:0 metrics:nil views:vs]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[contentView(height)]|" options:0 metrics:@{@"height": @([[self class] heightForLoading])} views:vs]];
    
    [contentView addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [contentView addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
    self.imageView = imageView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!self.loading) {
        CGFloat progress = MIN(self.bounds.size.height / [[self class] minHeightForReload], 1);
        
        if (progress > 0) {
            self.imageView.image = [MKIncrementalImage imageForProgress:progress size:CGSizeMake(20, 20)];
        }
    }
}

- (void)setLoading:(BOOL)loading {
    _loading = loading;
    
    static NSArray *loadingImages;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        loadingImages = [MKIncrementalImage imagesForLoadingWithSize:CGSizeMake(20, 20)];
    });
    
    if (loading) {
        self.imageView.animationImages = loadingImages;
        [self.imageView startAnimating];
    }
    else {
        [self.imageView stopAnimating];
        self.imageView.animationImages = nil;
    }
}

@end
