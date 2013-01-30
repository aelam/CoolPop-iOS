//
//  UISwipeNavigationController.m
//  CoolPop
//
//  Created by ryan on 13-1-29.
//  Copyright (c) 2013年 ryan. All rights reserved.
//

#import "UISwipeNavigationController.h"
#import "UIImage+GenerateFromView.h"
#import <objc/message.h>
#import "NSObject+AssociativeObject.h"
#import <QuartzCore/QuartzCore.h>

static CGFloat kMinThreshold = 140;
static CGFloat kStartZoomRate = 0.95;

static NSString *const snapShotKey = @"snapShotKey";
static NSString *const snapShotViewKey = @"snapShotViewKey";

@interface UISwipeNavigationController ()

@property (nonatomic,assign) CGRect originFrame;

- (BOOL)isNeedSwipeResponse;
- (void)shresholdJudge;
- (void)dragAnimationFinished;


@end

@implementation UISwipeNavigationController

@synthesize originFrame = _originFrame;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CAGradientLayer *shadow = [CAGradientLayer layer];
    shadow.frame = CGRectMake(-10, 0, 10, self.view.frame.size.height);
    shadow.startPoint = CGPointMake(1.0, 0.5);
    shadow.endPoint = CGPointMake(0, 0.5);
    shadow.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:0.0 alpha:0.3f] CGColor], (id)[[UIColor clearColor] CGColor], nil];
    [self.view.layer addSublayer:shadow];

}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([self.viewControllers count]> 0 && [viewController respondsToSelector:@selector(isSupportSwipePop)]) {
        BOOL returnValue = ((BOOL (*)(id, SEL))objc_msgSend)(viewController, @selector(isSupportSwipePop));
        if (returnValue) {
            UIImage *image = [UIImage imageFromUIView:self.view];
            [viewController setAssociativeObject:image forKey:snapShotKey];
        }
    }
    
    [super pushViewController:viewController animated:animated];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    self.originFrame = self.view.frame;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (![self isNeedSwipeResponse]) {
        return;
    }
    
    UITouch *touch = [touches anyObject];
    CGPoint previousPoint = [touch previousLocationInView:self.view.window];
    CGPoint currentPoint = [touch locationInView:self.view.window];
    CGFloat x0 = currentPoint.x - previousPoint.x;
    
    if (CGRectGetMinX(self.view.frame) <= 0 && x0 < 0) {
        return;
    }
    CGPoint currentCenter = self.view.center;
    self.view.center = CGPointMake(currentCenter.x + x0, currentCenter.y);
    
    // 前一级ViewController 动画
    UIViewController *topViewController = self.topViewController;
    UIImageView *imageView = [topViewController associativeObjectForKey:snapShotViewKey];
    if (imageView == nil) {
        UIImage *snapshot = [topViewController associativeObjectForKey:snapShotKey];
        imageView = [[[UIImageView alloc] initWithImage:snapshot] autorelease];
        CALayer *mask = [CALayer layer];
        mask.frame = imageView.bounds;
        mask.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5].CGColor;
        imageView.layer.mask = mask;
        
        [topViewController setAssociativeObject:imageView forKey:snapShotViewKey];
        [self.view.superview addSubview:imageView];
        [self.view.superview bringSubviewToFront:self.view];
        imageView.transform = CGAffineTransformMakeScale(kStartZoomRate,kStartZoomRate);
        
    }

    float r = CGRectGetMinX(self.view.frame) / CGRectGetWidth(self.view.frame);
    CGFloat rate = kStartZoomRate + (1 - kStartZoomRate) * r;
    imageView.transform = CGAffineTransformMakeScale(rate,rate);
    imageView.layer.mask.backgroundColor = [UIColor colorWithWhite:1 alpha:MAX(r, 0.5)].CGColor;
    
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (![self isNeedSwipeResponse]) {
        return;
    }

    [self shresholdJudge];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if (![self isNeedSwipeResponse]) {
        return;
    }
    
    [self shresholdJudge];
}

- (BOOL)isNeedSwipeResponse {
    if ([self.topViewController respondsToSelector:@selector(isSupportSwipePop)]) {
        BOOL returnValue = ((BOOL (*)(id, SEL))objc_msgSend)(self.topViewController, @selector(isSupportSwipePop));
        if (!returnValue) {
            return NO;
        }
    }
    
    if (self.viewControllers.count <= 1) {
        return NO;
    }
    
    return YES;
}


- (void)shresholdJudge {
    if (CGRectGetMinX(self.view.frame) > kMinThreshold) {
        // pop
        [UIView animateWithDuration:0.3 animations:^{
            CGRect rect = self.view.frame;
            rect.origin.x = CGRectGetMaxX(self.view.frame);
            self.view.frame = rect;
            
            UIViewController *topViewController = self.topViewController;
            UIImageView *imageView = [topViewController associativeObjectForKey:snapShotViewKey];
            imageView.transform = CGAffineTransformIdentity;
            imageView.layer.mask.backgroundColor = [UIColor colorWithWhite:1 alpha:1].CGColor;

        } completion:^(BOOL finished) {
            [self dragAnimationFinished];
            [self popViewControllerAnimated:NO];
        }];
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect rect = self.view.frame;
            rect.origin.x = 0;
            self.view.frame = rect;
            UIViewController *topViewController = self.topViewController;
            UIImageView *imageView = [topViewController associativeObjectForKey:snapShotViewKey];
            imageView.transform = CGAffineTransformIdentity;
            imageView.layer.mask.backgroundColor = [UIColor colorWithWhite:1 alpha:1].CGColor;

        } completion:^(BOOL finished) {
            [self dragAnimationFinished];
        }];
    }
}

- (void)dragAnimationFinished {
    UIViewController *topViewController = self.topViewController;
    UIImageView *imageView = [topViewController associativeObjectForKey:snapShotViewKey];
    if (imageView) {
        [imageView removeFromSuperview];
        [topViewController setAssociativeObject:nil forKey:snapShotViewKey];
    }
    
    self.view.frame = self.originFrame;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [super dealloc];
}

@end
