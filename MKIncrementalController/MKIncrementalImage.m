//
//  MKIncrementalImage.m
//  Example
//
//  Created by Mingenesis on 7/18/16.
//  Copyright © 2016 Mingenesis. All rights reserved.
//

#import "MKIncrementalImage.h"

static CGFloat valueForEaseInOut(CGFloat progress) {
    return 0.5 * (1 + sin((2 * progress - 1) * M_PI_2));
};

@implementation MKIncrementalImage

+ (UIImage *)imageForNoMoreWithSize:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    UIBezierPath *path;
    
    [[UIColor colorWithWhite:0 alpha:0.1] setFill];
    path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, size.width, size.height)];
    [path fill];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (NSArray *)imagesForLoadingWithSize:(CGSize)size {
    NSUInteger count = 30;
    CGFloat width = MIN(size.width, size.height);
    CGPoint center = CGPointMake(0.5 * width, 0.5 * width);
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:count];
    
    for (NSUInteger idx = 0; idx < count; idx ++) {
        CGFloat offset = 5 * M_PI_2 * valueForEaseInOut(idx / (count * 1.0));
        CGFloat startAngle = MAX(- M_PI_2, - M_PI + offset);
        CGFloat endAngle = MIN(- M_PI_2 + offset, 3 * M_PI_2);
        
        UIGraphicsBeginImageContextWithOptions(size, NO, 0);
        UIBezierPath *path;
        
        if (startAngle == endAngle) {
            endAngle -= 2 * M_PI;
        }
        
        [[UIColor colorWithWhite:0 alpha:0.5] setFill];
        path = [UIBezierPath bezierPathWithArcCenter:center radius:0.5 * width startAngle:startAngle endAngle:endAngle clockwise:NO];
        [path addLineToPoint:center];
        [path fill];
        
        [[UIColor colorWithWhite:0.8 alpha:1] setFill];
        path = [UIBezierPath bezierPathWithArcCenter:center radius:0.5 * width startAngle:startAngle endAngle:endAngle clockwise:YES];
        [path addLineToPoint:center];
        [path fill];
        
        path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0.1 * width, 0.1 * width, 0.8 * width, 0.8 * width)];
        [path fillWithBlendMode:kCGBlendModeClear alpha:1];
        
        [images addObject:UIGraphicsGetImageFromCurrentImageContext()];
        UIGraphicsEndImageContext();
    }
    
    return images;
}

+ (UIImage *)imageForProgress:(CGFloat)progress size:(CGSize)size {
    CGFloat width = MIN(size.width, size.height);
    CGPoint center = CGPointMake(0.5 * width, 0.5 * width);
    
    CGFloat offset = 2 * M_PI * progress;
    CGFloat startAngle = - M_PI_2;
    CGFloat endAngle = - M_PI_2 + offset;
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    UIBezierPath *path;
    
    [[UIColor colorWithWhite:0 alpha:0.5 * progress] setFill];
    path = [UIBezierPath bezierPathWithArcCenter:center radius:0.5 * width startAngle:startAngle endAngle:endAngle clockwise:YES];
    [path addLineToPoint:center];
    [path fill];
    
    path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0.1 * width, 0.1 * width, 0.8 * width, 0.8 * width)];
    [path fillWithBlendMode:kCGBlendModeClear alpha:1];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
