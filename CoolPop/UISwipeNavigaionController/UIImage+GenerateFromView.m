//
//  UIImage+GenerateFromView.m
//  CoolPop
//
//  Created by ryan on 13-1-29.
//  Copyright (c) 2013年 ryan. All rights reserved.
//

#import "UIImage+GenerateFromView.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIImage (GenerateFromView)

+ (UIImage *)imageFromUIView:(UIView *)aView {
    float scale = 1.f;
    CGSize pageSize = aView.frame.size;
    if([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        scale = [UIScreen mainScreen].scale;
        UIGraphicsBeginImageContextWithOptions(pageSize, aView.opaque, scale);
    } else {
        UIGraphicsBeginImageContext(pageSize);
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, 1.0 / scale, 1.0 / scale);

    [aView.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    NSData *imageData = UIImagePNGRepresentation(image);
    [imageData writeToFile:@"/Users/ryan/Desktop/helo.png" atomically:YES];
    UIGraphicsEndImageContext();
    
    return image;

}

@end
