//
//  MKIncrementalErrorView.h
//  Example
//
//  Created by Mingenesis on 7/14/16.
//  Copyright © 2016 Mingenesis. All rights reserved.
//

#import <UIKit/UIKit.h>

FOUNDATION_EXPORT NSString * const MKIncrementalErrorDomain;

NS_ENUM(NSInteger) {
    MKIncrementalErrorEmpty = -1,
};

@interface MKIncrementalErrorView : UIView

+ (instancetype)errorViewWithError:(NSError *)error;

@end
