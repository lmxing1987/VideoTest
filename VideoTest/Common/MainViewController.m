//
//  MainViewController.m
//  VideoTest
//  本demo演示横屏视频录像，欢迎访问www.crazyiter.com 探讨技术
//  Created by mxlai on 17-3-1.
//  Copyright (c) 2017年 crazyiter.com. All rights reserved.
//

#import "MainViewController.h"
#import "CaptureViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "SBCaptureToolKit.h"
#import <AVFoundation/AVFoundation.h>
#import "PlayViewController.h"
#import "AppDelegate.h"
@interface MainViewController ()
{
    UIButton *recordButton;
}
@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //62 42
    recordButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 62, 42)];
    [recordButton setImage:[UIImage imageNamed:@"g_tabbar_ic_video_nor.png"] forState:UIControlStateNormal];
    [recordButton setImage:[UIImage imageNamed:@"g_tabbar_ic_video_down@2x.png"] forState:UIControlStateHighlighted];
    [recordButton addTarget:self action:@selector(pressRecordButton:) forControlEvents:UIControlEventTouchUpInside];
    recordButton.center = CGPointMake(DEVICE_SIZE.width / 2, (DEVICE_SIZE.height - 42) / 2.0f - 5.0f + DELTA_Y);
    [self.view addSubview:recordButton];
    [self forceOrientationPortrait]; //强制横屏
}
- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    recordButton.center = CGPointMake(DEVICE_SIZE.width / 2, (DEVICE_SIZE.height - 42) / 2.0f - 5.0f + DELTA_Y);
}
- (void)pressRecordButton:(UIButton *)sender
{
    UINavigationController *navCon = [[UINavigationController alloc] init];
    navCon.navigationBarHidden = YES;
    
    CaptureViewController *captureViewCon = [[CaptureViewController alloc] initWithNibName:nil bundle:nil];
    [navCon pushViewController:captureViewCon animated:NO];
    [self presentViewController:navCon animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)shouldAutorotate{
    return YES;
}
/**
 *  强制竖屏
 */
-(void)forceOrientationPortrait{
    
    //这段代码，只能旋转屏幕不能达到强制竖屏的效果
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = UIInterfaceOrientationMaskPortrait;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
    
    AppDelegate *appdelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    appdelegate.isForcePortrait=YES;
    [appdelegate application:[UIApplication sharedApplication] supportedInterfaceOrientationsForWindow:self.view.window];
}

@end
