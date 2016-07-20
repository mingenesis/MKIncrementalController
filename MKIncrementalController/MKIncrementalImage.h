//
//  MKIncrementalImage.h
//  Example
//
//  Created by Mingenesis on 7/18/16.
//  Copyright © 2016 Mingenesis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MKIncrementalImage : NSObject

+ (UIImage *)imageForNoMoreWithSize:(CGSize)size;
+ (NSArray *)imagesForLoadingWithSize:(CGSize)size;
+ (UIImage *)imageForProgress:(CGFloat)progress size:(CGSize)size;

@end
