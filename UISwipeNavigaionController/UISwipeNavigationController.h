//
//  UISwipeNavigationController.h
//  CoolPop
//
//  Created by ryan on 13-1-29.
//  Copyright (c) 2013年 ryan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UISwipePopDelegate <NSObject>

- (BOOL)isSupportSwipePop;// default is NO;

@end

@interface UISwipeNavigationController : UINavigationController

@end
