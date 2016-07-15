//
//  MKIncrementalReloadView.m
//  Example
//
//  Created by Mingenesis on 7/13/16.
//  Copyright © 2016 Mingenesis. All rights reserved.
//

#import "MKIncrementalReloadView.h"

@implementation MKIncrementalReloadView

+ (CGFloat)minHeightForReload {
    return 50;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor redColor];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)startLoading {
    
}

- (void)stopLoading {
    
}

@end
