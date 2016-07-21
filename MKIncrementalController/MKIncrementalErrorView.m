//
//  MKIncrementalErrorView.m
//  Example
//
//  Created by Mingenesis on 7/14/16.
//  Copyright © 2016 Mingenesis. All rights reserved.
//

#import "MKIncrementalErrorView.h"

NSString * const MKIncrementalErrorDomain = @"MKIncrementalErrorDomain";

@interface MKIncrementalErrorView ()

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation MKIncrementalErrorView

+ (instancetype)errorViewWithError:(NSError *)error {
    MKIncrementalErrorView *view = [[MKIncrementalErrorView alloc] initWithFrame:CGRectMake(0, 0, 10, 50)];
    
    view.titleLabel.text = error.localizedDescription;
    
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
    titleLabel.numberOfLines = 0;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:titleLabel];
    
    NSDictionary *vs = NSDictionaryOfVariableBindings(titleLabel);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[titleLabel]|" options:0 metrics:nil views:vs]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[titleLabel]|" options:0 metrics:nil views:vs]];
    
    self.titleLabel = titleLabel;
}

@end
