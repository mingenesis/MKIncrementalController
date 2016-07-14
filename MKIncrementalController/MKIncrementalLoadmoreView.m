//
//  MKIncrementalLoadmoreView.m
//  Example
//
//  Created by Mingenesis on 7/14/16.
//  Copyright © 2016 Mingenesis. All rights reserved.
//

#import "MKIncrementalLoadmoreView.h"

@interface MKIncrementalLoadmoreView ()

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation MKIncrementalLoadmoreView

+ (instancetype)loadmoreViewWithState:(MKIncrementalControllerState)state {
    MKIncrementalLoadmoreView *view = [[MKIncrementalLoadmoreView alloc] initWithFrame:CGRectMake(0, 0, 10, 50)];
    
    if (state == MKIncrementalControllerStateNoMore) {
        view.titleLabel.text = @"已全部加载";
    }
    else if (state == MKIncrementalControllerStateLoadingMore) {
        view.titleLabel.text = @"加载中…";
    }
    else if (state == MKIncrementalControllerStateReloading || state == MKIncrementalControllerStateNotLoading) {
        view.titleLabel.text = @"--";
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
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:titleLabel];
    
    NSDictionary *vs = NSDictionaryOfVariableBindings(titleLabel);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[titleLabel]|" options:0 metrics:nil views:vs]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[titleLabel]|" options:0 metrics:nil views:vs]];
    
    self.titleLabel = titleLabel;
}

@end
