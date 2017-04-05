//
//  CaptureViewController.h
//  VideoTest
//  本demo演示横屏视频录像，欢迎访问www.crazyiter.com 探讨技术
//  Created by mxlai on 17-3-1.
//  Copyright (c) 2017年 crazyiter.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "SBCaptureDefine.h"
#import "SBVideoRecorder.h"

@interface CaptureViewController : UIViewController <SBVideoRecorderDelegate, UIAlertViewDelegate>

@end
