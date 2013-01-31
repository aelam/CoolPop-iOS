//
//  UISwipeNavigationController.m
//  CoolPop
//
//  Created by ryan on 13-1-29.
//  Copyright (c) 2013年 ryan. All rights reserved.
//

#import <objc/message.h>
#import <objc/runtime.h>

#import "UISwipeNavigationController.h"
#import "UIImage+GenerateFromView.h"
#import "NSObject+AssociativeObject.h"
#import <QuartzCore/QuartzCore.h>

#define CACHE_IN_MEMORY 0

static CGFloat kMinThreshold = 140;
static CGFloat kStartZoomRate = 0.95;

static NSString *const snapShotKey = @"snapShotKey";
static NSString *const snapShotViewKey = @"snapShotViewKey";

@interface UISwipeNavigationController ()

@property (nonatomic, assign) CGRect originFrame;
@property (nonatomic, retain) UIImageView *leftSnapshotView;


- (BOOL)isNeedSwipeResponse;
- (void)shresholdJudge;
- (void)dragAnimationFinished:(BOOL)popSuccess;

- (NSString *)snapshotPathForController:(UIViewController *)controller;
- (UIImageView *)leftSnapshotView;
- (void)resetLeftSnapshotView;

- (void)touchesBegan;
- (void)touchesEnded;

- (void)touchesMovedWithPanGesture:(UIPanGestureRecognizer *)gestureRecognizer;

- (IBAction)handlePan:(UIPanGestureRecognizer *)gestureRecognizer;


@end

@implementation UISwipeNavigationController

@synthesize originFrame = _originFrame;
@synthesize leftSnapshotView = _leftSnapshotView;

+ (NSString *)snapshotCachePath {
    return [NSHomeDirectory() stringByAppendingString:@"/Library/Caches/PopSnapshots"];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Leftborder shadow
    CAGradientLayer *shadow = [CAGradientLayer layer];
    shadow.frame = CGRectMake(-10, 0, 10, self.view.frame.size.height);
    shadow.startPoint = CGPointMake(1.0, 0.5);
    shadow.endPoint = CGPointMake(0, 0.5);
    shadow.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:0.0 alpha:0.3f] CGColor], (id)[[UIColor clearColor] CGColor], nil];
    [self.view.layer addSublayer:shadow];

    self.originFrame = self.view.frame;

    self.leftSnapshotView.hidden = YES;
    
    UIPanGestureRecognizer *gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.view addGestureRecognizer:gestureRecognizer];

}

- (IBAction)handlePan:(UIPanGestureRecognizer *)gestureRecognizer {
    if (![self isNeedSwipeResponse]) {
        return;
    }

    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        
        [self touchesMovedWithPanGesture:gestureRecognizer];
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded
               || gestureRecognizer.state == UIGestureRecognizerStateFailed
               || gestureRecognizer.state == UIGestureRecognizerStateCancelled
               || gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        [self touchesEnded];
    }
    
}



#pragma mark -
#pragma mark - Push Action
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([self.viewControllers count]> 0 && [viewController respondsToSelector:@selector(isSupportSwipePop)]) {
        BOOL returnValue = ((BOOL (*)(id, SEL))objc_msgSend)(viewController, @selector(isSupportSwipePop));
        if (returnValue) {
            UIImage *image = [UIImage imageFromUIView:self.view];
            [self saveSnapshot:image forViewController:viewController];
        }
    }
    
    [super pushViewController:viewController animated:animated];
}


- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    [self removeSnapshotForViewController:self.topViewController];
    return [super popViewControllerAnimated:animated];
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    NSArray *popedController = [self popToViewController:viewController animated:animated];
    for (UIViewController *vc in popedController) {
        [self removeSnapshotForViewController:vc];
    }
    return popedController;
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated {
    NSArray *popedController = [self popToRootViewControllerAnimated:animated];
    for (UIViewController *vc in popedController) {
        [self removeSnapshotForViewController:vc];
    }
    return popedController;
}


#pragma mark - 
#pragma mark - Touch Action
- (void)touchesBegan {
    self.originFrame = self.view.frame;
}

- (void)touchesEnded {
    if (![self isNeedSwipeResponse]) {
        return;
    }
    
    [self shresholdJudge];
}

- (void)touchesMovedWithPanGesture:(UIPanGestureRecognizer *)gestureRecognizer {
    UIView *piece = [gestureRecognizer view];
    CGPoint translation = [gestureRecognizer translationInView:[piece superview]];

    CGFloat x0 = CGRectGetMinX(piece.frame) + translation.x;
    if (x0 <= 0 || x0 >= CGRectGetWidth(piece.frame)) {
        return;
    }
    
    [piece setCenter:CGPointMake([piece center].x + translation.x, [piece center].y)];
    [gestureRecognizer setTranslation:CGPointZero inView:[piece superview]];

    // 前一级ViewController 动画
    UIViewController *topViewController = self.topViewController;
    
    if (![self.view.superview.subviews containsObject:self.leftSnapshotView]) {
        [self.view.superview addSubview:_leftSnapshotView];
        [self.view.superview insertSubview:_leftSnapshotView belowSubview:self.view];
    }
    
    if (self.leftSnapshotView.hidden) {
        self.leftSnapshotView.hidden = NO;
        UIImage *snapshot = [self snapshotForViewController:topViewController];
        self.leftSnapshotView.image = snapshot;
    }
    
    float r = CGRectGetMinX(self.view.frame) / CGRectGetWidth(self.view.frame);
    CGFloat rate = kStartZoomRate + (1 - kStartZoomRate) * r;
    self.leftSnapshotView.transform = CGAffineTransformMakeScale(rate,rate);
    self.leftSnapshotView.layer.mask.backgroundColor = [UIColor colorWithWhite:1 alpha:MAX(r, 0.5)].CGColor;

}

#pragma mark -
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
            UIImageView *imageView = self.leftSnapshotView;
            imageView.transform = CGAffineTransformIdentity;
            imageView.layer.mask.backgroundColor = [UIColor colorWithWhite:1 alpha:1].CGColor;

        } completion:^(BOOL finished) {
            [self dragAnimationFinished:YES];
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
            [self dragAnimationFinished:NO];
        }];
    }
}

- (void)dragAnimationFinished:(BOOL)popSuccess {

    [self resetLeftSnapshotView];
    
    if (popSuccess) {
        [self removeSnapshotForViewController:self.topViewController];        
    }
    
    self.view.frame = self.originFrame;
}

#pragma mark - 
#pragma mark - snapshot
- (void)saveSnapshot:(UIImage *)image forViewController:(UIViewController *)controller {
#if CACHE_IN_MEMORY
    [controller setAssociativeObject:image forKey:snapShotKey];    
#else
    NSString *snapshotPath = [self snapshotPathForController:controller];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:[UISwipeNavigationController snapshotCachePath] isDirectory:NULL]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[UISwipeNavigationController snapshotCachePath] withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    
    NSData *imageData = UIImagePNGRepresentation(image);
    [imageData writeToFile:snapshotPath atomically:YES];
#endif
}

- (UIImage *)snapshotForViewController:(UIViewController *)controller {
#if CACHE_IN_MEMORY
    return [controller associativeObjectForKey:snapShotKey];
#else
    NSString *snapshotPath = [self snapshotPathForController:controller];
    UIImage *image = [UIImage imageWithContentsOfFile:snapshotPath];
    return image;
#endif

}

- (void)removeSnapshotForViewController:(UIViewController *)controller {
    self.leftSnapshotView.hidden = YES;
    
#if CACHE_IN_MEMORY
    UIImage *image = [controller associativeObjectForKey:snapShotKey];
    if (image) {
        [controller setAssociativeObject:nil forKey:snapShotKey];
    }
#else
    NSString *snapshotPath = [self snapshotPathForController:controller];
    [[NSFileManager defaultManager] removeItemAtPath:snapshotPath error:nil];
#endif

}

- (NSString *)snapshotPathForController:(UIViewController *)controller {
    NSString *snapshotPath = [[UISwipeNavigationController snapshotCachePath] stringByAppendingFormat:@"/<%p>.png",controller,nil];
    return snapshotPath;
}


- (UIImageView *)leftSnapshotView {
    if (_leftSnapshotView == nil) {
        _leftSnapshotView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        CALayer *mask = [CALayer layer];
        mask.frame = _leftSnapshotView.bounds;
        mask.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5].CGColor;
        _leftSnapshotView.layer.mask = mask;

    }
    return _leftSnapshotView;
}

- (void)resetLeftSnapshotView {
    self.leftSnapshotView.transform = CGAffineTransformIdentity;
    self.leftSnapshotView.image = nil;
    self.leftSnapshotView.hidden = YES;
    self.leftSnapshotView.layer.mask.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5].CGColor;
}


#pragma mark -
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    self.leftSnapshotView = nil;
    [super dealloc];
}

@end
