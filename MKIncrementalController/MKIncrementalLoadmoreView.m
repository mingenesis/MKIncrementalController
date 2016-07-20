//
//  MKIncrementalLoadmoreView.m
//  Example
//
//  Created by Mingenesis on 7/14/16.
//  Copyright © 2016 Mingenesis. All rights reserved.
//

#import "MKIncrementalLoadmoreView.h"
#import "MKIncrementalImage.h"

@interface MKIncrementalLoadmoreView ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation MKIncrementalLoadmoreView

+ (instancetype)loadmoreViewWithState:(MKIncrementalControllerState)state {
    MKIncrementalLoadmoreView *view = [[MKIncrementalLoadmoreView alloc] initWithFrame:CGRectMake(0, 0, 10, 50)];
    static UIImage *nomoreImage;
    static NSArray *loadingImages;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        nomoreImage = [MKIncrementalImage imageForNoMoreWithSize:CGSizeMake(6, 6)];
        loadingImages = [MKIncrementalImage imagesForLoadingWithSize:CGSizeMake(20, 20)];
    });
    
    if (state == MKIncrementalControllerStateNoMore) {
        view.imageView.image = nomoreImage;
    }
    else if (state == MKIncrementalControllerStateLoadingMore) {
        view.imageView.animationImages = loadingImages;
        view.imageView.animationDuration = 1;
        [view.imageView startAnimating];
    }
    else if (state == MKIncrementalControllerStateReloading || state == MKIncrementalControllerStateNotLoading) {
//        view.imageView.image = nil;
    }
    
    return view;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:nil];
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:imageView];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
    self.imageView = imageView;
}

@end
