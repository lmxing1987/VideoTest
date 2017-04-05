//
//  AppDelegate.h
//  VideoTest
//  本demo演示横屏视频录像，欢迎访问www.crazyiter.com 探讨技术
//  Created by mxlai on 17-3-1.
//  Copyright (c) 2017年 crazyiter.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MainViewController *mainViewController;
/**
 *  是否强制横屏
 */
@property  BOOL isForceLandscape;
/**
 *  是否强制竖屏
 */
@property  BOOL isForcePortrait;
@end
