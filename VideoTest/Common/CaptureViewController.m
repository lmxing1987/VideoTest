//
//  CaptureViewController.m
//  VideoTest
//  本demo演示横屏视频录像，欢迎访问www.crazyiter.com 探讨技术
//  Created by mxlai on 17-3-1.
//  Copyright (c) 2017年 crazyiter.com. All rights reserved.
//

#import "CaptureViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SBCaptureToolKit.h"
#import "SBVideoRecorder.h"
#import "PlayViewController.h"
#import "MBProgressHUD.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <MediaPlayer/MediaPlayer.h>
#import "AppDelegate.h"
#define TIMER_INTERVAL 0.05f

#define TAG_ALERTVIEW_CLOSE_CONTROLLER 10086

@interface CaptureViewController ()
{

}
@property (strong, nonatomic) UIView *maskView;
@property (strong, nonatomic) SBVideoRecorder *recorder;
@property (strong, nonatomic) UIButton *okButton;
@property (strong, nonatomic) UIButton *closeButton;
@property (strong, nonatomic) UIButton *switchButton;
@property (strong, nonatomic) UIButton *settingButton;
@property (strong, nonatomic) UIButton *recordButton;
@property (strong, nonatomic) UIButton *flashButton;
@property (strong, nonatomic) MBProgressHUD *hud;
@property (assign, nonatomic) BOOL initalized;
@property (assign, nonatomic) BOOL isProcessingData;
@property (strong, nonatomic) UIView *preview;
@property (strong, nonatomic) UIImageView *focusRectView;
@property (strong, nonatomic) UILabel *timeLB;
@property (strong, nonatomic) UILabel *totalTimeLB;
@property (assign, nonatomic) BOOL isfromOk;
@end

@implementation CaptureViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = color(16, 16, 16, 1);
    
    self.maskView = [self getMaskView];
    [self.view addSubview:_maskView];

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    AppDelegate *appdelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    appdelegate.isForcePortrait=NO;
    appdelegate.isForceLandscape=YES;
    [self forceOrientationLandscape]; //强制横屏
    self.isfromOk=NO;
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    AppDelegate *appdelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    appdelegate.isForcePortrait=NO;
    appdelegate.isForceLandscape=NO;
    [self forceOrientationPortrait];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_initalized) {
        return;
    }
    
    [self initPreview];
    [self initRecorder];
    [SBCaptureToolKit createVideoFolderIfNotExist];
    [self initRecordButton];
    [self initOKButton];
    [self initTopLayout];
    
    [self hideMaskView];
    
    self.initalized = YES;
}
- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.preview.frame=CGRectMake(0, 0, DEVICE_SIZE.width, DEVICE_SIZE.height);
    _recorder.preViewLayer.frame = CGRectMake(0, 0, DEVICE_SIZE.width, DEVICE_SIZE.height);
    CGFloat buttonW = 80.0f;
    self.recordButton.frame= CGRectMake((DEVICE_SIZE.width - buttonW) / 2.0, DEVICE_SIZE.height-buttonW-15, buttonW, buttonW);
    CGFloat okButtonW = 50;
    self.okButton.frame=CGRectMake(self.view.frame.size.width-okButtonW-15, 0, okButtonW, okButtonW);
    self.switchButton.frame=CGRectMake(self.view.frame.size.width - (buttonW + 10) * 2 - 10, 5, buttonW, buttonW);
    self.flashButton.frame=CGRectMake(self.view.frame.size.width - (buttonW + 10), 5, buttonW, buttonW);
    self.focusRectView.frame=CGRectMake(0, 0, 90, 90);
    
    CGPoint center = _okButton.center;
    center.y = self.recordButton.center.y;
    self.okButton.center = center;
//    self.maskView.frame=CGRectMake(0, 0, DEVICE_SIZE.width, DEVICE_SIZE.height + DELTA_Y);
    self.timeLB.frame=CGRectMake((DEVICE_SIZE.width-120)/2.0-60,10, 120, 15);
    self.totalTimeLB.frame=CGRectMake((DEVICE_SIZE.width-120)/2.0+60,10, 120, 15);
    _recorder.preViewLayer.connection.videoOrientation = [self videoOrientationFromCurrentDeviceOrientation];
    [_recorder setVideoOrientation:[self videoOrientationFromCurrentDeviceOrientation]];
     self.closeButton.frame=CGRectMake(10, 5, buttonW, buttonW);
}
- (AVCaptureVideoOrientation) videoOrientationFromCurrentDeviceOrientation {
    
    switch (self.interfaceOrientation) {
        case UIInterfaceOrientationPortrait: {
            return AVCaptureVideoOrientationPortrait;
        }
        case UIInterfaceOrientationLandscapeLeft: {
            return AVCaptureVideoOrientationLandscapeLeft;
        }
        case UIInterfaceOrientationLandscapeRight: {
            return AVCaptureVideoOrientationLandscapeRight;
        }
        case UIInterfaceOrientationPortraitUpsideDown: {
            return AVCaptureVideoOrientationPortraitUpsideDown;
        }
    }
    
    return AVCaptureVideoOrientationLandscapeLeft;
}
- (void)initPreview
{
    self.preview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_SIZE.width, DEVICE_SIZE.height)];
    _preview.clipsToBounds = YES;
    [self.view insertSubview:_preview belowSubview:_maskView];
}

- (void)initRecorder
{
    self.recorder = [[SBVideoRecorder alloc] init];
    _recorder.delegate = self;
    _recorder.preViewLayer.frame = CGRectMake(0, 0, DEVICE_SIZE.width, DEVICE_SIZE.height);
    [self.preview.layer addSublayer:_recorder.preViewLayer];
}

- (void)initRecordButton
{
    CGFloat buttonW = 80.0f;
    self.recordButton = [[UIButton alloc] initWithFrame:CGRectMake((DEVICE_SIZE.width - buttonW) / 2.0, DEVICE_SIZE.height-buttonW-15, buttonW, buttonW)];
    [_recordButton setImage:[UIImage imageNamed:@"video_longvideo_btn_shoot.png"] forState:UIControlStateNormal];
    [_recordButton setImage:[UIImage imageNamed:@"video_longvideo_btn_pause.png"] forState:UIControlStateSelected];
    [self.recordButton addTarget:self action:@selector(recordAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:_recordButton belowSubview:_maskView];
    self.closeButton.frame=CGRectMake(10, 5, buttonW, buttonW);
}
- (void)recordAction:(UIButton*)sender{
    if (!self.recordButton.isSelected) { //选中开始录像
            NSString *filePath = [SBCaptureToolKit getVideoSaveFilePathString];
            [_recorder startRecordingToOutputFileURL:[NSURL fileURLWithPath:filePath]];
    }else{ ///停止
          [_recorder stopCurrentVideoRecording];
    }
}
- (void)initOKButton
{
    CGFloat okButtonW = 50;
    self.okButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, okButtonW, okButtonW)];
    _okButton.enabled = NO;
    
    [_okButton setBackgroundImage:[UIImage imageNamed:@"record_icon_hook_normal_bg.png"] forState:UIControlStateNormal];
    [_okButton setBackgroundImage:[UIImage imageNamed:@"record_icon_hook_highlighted_bg.png"] forState:UIControlStateHighlighted];
    
    [_okButton setImage:[UIImage imageNamed:@"record_icon_hook_normal.png"] forState:UIControlStateNormal];
    
    [SBCaptureToolKit setView:_okButton toOrigin:CGPointMake(self.view.frame.size.width - okButtonW - 10, self.view.frame.size.height - okButtonW - 10)];
    
    [_okButton addTarget:self action:@selector(pressOKButton) forControlEvents:UIControlEventTouchUpInside];
    
    CGPoint center = _okButton.center;
    center.y = _recordButton.center.y;
    _okButton.center = center;
    
    [self.view insertSubview:_okButton belowSubview:_maskView];
}

- (void)initTopLayout
{
    CGFloat buttonW = 35.0f;
    
    //关闭
    self.closeButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 5, buttonW, buttonW)];
    [_closeButton setImage:[UIImage imageNamed:@"record_close_normal.png"] forState:UIControlStateNormal];
    [_closeButton setImage:[UIImage imageNamed:@"record_close_disable.png"] forState:UIControlStateDisabled];
    [_closeButton setImage:[UIImage imageNamed:@"record_close_highlighted.png"] forState:UIControlStateSelected];
    [_closeButton setImage:[UIImage imageNamed:@"record_close_highlighted.png"] forState:UIControlStateHighlighted];
    [_closeButton addTarget:self action:@selector(pressCloseButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:_closeButton belowSubview:_maskView];
    
    //前后摄像头转换
    self.switchButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - (buttonW + 10) * 2 - 10, 5, buttonW, buttonW)];
    [_switchButton setImage:[UIImage imageNamed:@"record_lensflip_normal.png"] forState:UIControlStateNormal];
    [_switchButton setImage:[UIImage imageNamed:@"record_lensflip_disable.png"] forState:UIControlStateDisabled];
    [_switchButton setImage:[UIImage imageNamed:@"record_lensflip_highlighted.png"] forState:UIControlStateSelected];
    [_switchButton setImage:[UIImage imageNamed:@"record_lensflip_highlighted.png"] forState:UIControlStateHighlighted];
    [_switchButton addTarget:self action:@selector(pressSwitchButton) forControlEvents:UIControlEventTouchUpInside];
    _switchButton.enabled = [_recorder isFrontCameraSupported];
    [self.view insertSubview:_switchButton belowSubview:_maskView];
    
    //setting
//    self.settingButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - (buttonW + 10), 5, buttonW, buttonW)];
//    [_settingButton setImage:[UIImage imageNamed:@"record_tool_normal.png"] forState:UIControlStateNormal];
//    [_settingButton setImage:[UIImage imageNamed:@"record_tool_disable.png"] forState:UIControlStateDisabled];
//    [_settingButton setImage:[UIImage imageNamed:@"record_tool_highlighted.png"] forState:UIControlStateSelected];
//    [_settingButton setImage:[UIImage imageNamed:@"record_tool_highlighted.png"] forState:UIControlStateHighlighted];
//    [self.view insertSubview:_settingButton belowSubview:_maskView];
    self.flashButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - (buttonW + 10), 5, buttonW, buttonW)];
    [_flashButton setImage:[UIImage imageNamed:@"record_flashlight_normal.png"] forState:UIControlStateNormal];
    [_flashButton setImage:[UIImage imageNamed:@"record_flashlight_disable.png"] forState:UIControlStateDisabled];
    [_flashButton setImage:[UIImage imageNamed:@"record_flashlight_highlighted.png"] forState:UIControlStateHighlighted];
    [_flashButton setImage:[UIImage imageNamed:@"record_flashlight_highlighted.png"] forState:UIControlStateSelected];
    _flashButton.enabled = _recorder.isTorchSupported;
    [_flashButton addTarget:self action:@selector(pressFlashButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:_flashButton belowSubview:_maskView];
    
    //focus rect view
    self.focusRectView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 90, 90)];
    _focusRectView.image = [UIImage imageNamed:@"touch_focus_not.png"];
    _focusRectView.alpha = 0;
    [self.preview addSubview:_focusRectView];
    
    self.timeLB=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 15)];
    self.timeLB.backgroundColor=[UIColor clearColor];
    self.timeLB.text=@"当前 00:00:00";
    self.timeLB.font=[UIFont systemFontOfSize:14];
    self.timeLB.textColor=[UIColor colorWithRed:255 green:255 blue:255 alpha:1.0];
    [self.view insertSubview:self.timeLB belowSubview:_maskView];
    
    self.totalTimeLB=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 15)];
    self.totalTimeLB.backgroundColor=[UIColor clearColor];
    self.totalTimeLB.text=@"总时长 00:00:00";
    self.totalTimeLB.font=[UIFont systemFontOfSize:14];
    self.totalTimeLB.textColor=[UIColor colorWithRed:255 green:255 blue:255 alpha:1.0];
    [self.view insertSubview:self.totalTimeLB belowSubview:_maskView];

}

- (void)pressCloseButton
{
    if ([_recorder getVideoCount] > 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"放弃这个视频真的好么?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"放弃", nil];
        alertView.tag = TAG_ALERTVIEW_CLOSE_CONTROLLER;
        [alertView show];
    } else {
        [self dropTheVideo];
    }
}

- (void)pressSwitchButton
{
    _switchButton.selected = !_switchButton.selected;
    if (_switchButton.selected) {//换成前摄像头
        if (_flashButton.selected) {
            [_recorder openTorch:NO];
            _flashButton.selected = NO;
            _flashButton.enabled = NO;
        } else {
            _flashButton.enabled = NO;
        }
    } else {
        _flashButton.enabled = [_recorder isFrontCameraSupported];
    }
    
    [_recorder switchCamera];
}

- (void)pressFlashButton
{
    _flashButton.selected = !_flashButton.selected;
    [_recorder openTorch:_flashButton.selected];
}

- (void)pressOKButton
{
    if (_isProcessingData) {
        return;
    }
    if (self.recordButton.isSelected) { //先停止
        self.isfromOk=YES;
        [_recorder stopCurrentVideoRecording];
    }else{
        [self okAction];
    }

}
- (void)okAction{
    if (!self.hud) {
        self.hud = [[MBProgressHUD alloc] initWithView:self.view];
        _hud.labelText = @"努力处理中";
    }
    [_hud show:YES];
    [self.view addSubview:_hud];
    
    [_recorder mergeVideoFiles];
    self.isProcessingData = YES;
}
//放弃本次视频，并且关闭页面
- (void)dropTheVideo
{
    [_recorder deleteAllVideo];
    [self dismissViewControllerAnimated:YES completion:nil];
}

//删除最后一段视频
- (void)deleteLastVideo
{
    if ([_recorder getVideoCount] > 0) {
        [_recorder deleteLastVideo];
    }
}

- (void)hideMaskView
{
    [UIView animateWithDuration:0.5f animations:^{
        CGRect frame = self.maskView.frame;
        frame.origin.y = self.maskView.frame.size.height;
        self.maskView.frame = frame;
    }];
}

- (UIView *)getMaskView
{
    UIView *maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_SIZE.width, DEVICE_SIZE.height + DELTA_Y)];
    maskView.backgroundColor = color(30, 30, 30, 0.1);
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, DEVICE_SIZE.width, DEVICE_SIZE.height)];
    label.font = [UIFont systemFontOfSize:50.0f];
    label.textColor = color(100, 100, 100, 1);
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"加载中...";
    label.backgroundColor = [UIColor clearColor];
    
    [maskView addSubview:label];
    
    return maskView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)showFocusRectAtPoint:(CGPoint)point
{
    _focusRectView.alpha = 1.0f;
    _focusRectView.center = point;
    _focusRectView.transform = CGAffineTransformMakeScale(1.5f, 1.5f);
    [UIView animateWithDuration:0.2f animations:^{
        _focusRectView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    } completion:^(BOOL finished) {
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
        animation.values = @[@0.5f, @1.0f, @0.5f, @1.0f, @0.5f, @1.0f];
        animation.duration = 0.5f;
        [_focusRectView.layer addAnimation:animation forKey:@"opacity"];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3f animations:^{
                _focusRectView.alpha = 0;
            }];
        });
    }];
//    _focusRectView.transform = CGAffineTransformMakeScale(1.5f, 1.5f);
//    _focusRectView.center = point;
//    [UIView animateWithDuration:0.3f animations:^{
//        _focusRectView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
//        _focusRectView.alpha = 1.0f;
//    } completion:^(BOOL finished) {
//        [UIView animateWithDuration:0.1f animations:^{
//            _focusRectView.alpha = 0.0f;
//        }];
//    }];
}



#pragma mark - SBVideoRecorderDelegate
- (void)videoRecorder:(SBVideoRecorder *)videoRecorder didStartRecordingToOutPutFileAtURL:(NSURL *)fileURL
{
    NSLog(@"正在录制视频: %@", fileURL);
     [self.recordButton setSelected:YES];
}

- (void)videoRecorder:(SBVideoRecorder *)videoRecorder didFinishRecordingToOutPutFileAtURL:(NSURL *)outputFileURL duration:(CGFloat)videoDuration totalDur:(CGFloat)totalDur error:(NSError *)error
{
    if (error) {
        NSLog(@"录制视频错误:%@", error);
    } else {
        NSLog(@"录制视频完成: %@", outputFileURL);
    }
    [self.recordButton setSelected:NO];
    if (self.isfromOk) {
        [self okAction];
        self.isfromOk=NO;
    }
//    if (totalDur >= MAX_VIDEO_DUR) {
//        [self pressOKButton];
//    }
}

- (void)videoRecorder:(SBVideoRecorder *)videoRecorder didRemoveVideoFileAtURL:(NSURL *)fileURL totalDur:(CGFloat)totalDur error:(NSError *)error
{
    if (error) {
        NSLog(@"删除视频错误: %@", error);
    } else {
        NSLog(@"删除了视频: %@", fileURL);
        NSLog(@"现在视频长度: %f", totalDur);
    }
    
    _okButton.enabled = (totalDur >= MIN_VIDEO_DUR);
}

- (void)videoRecorder:(SBVideoRecorder *)videoRecorder didRecordingToOutPutFileAtURL:(NSURL *)outputFileURL duration:(CGFloat)videoDuration recordedVideosTotalDur:(CGFloat)totalDur
{
    _okButton.enabled = (videoDuration + totalDur >= MIN_VIDEO_DUR);
    double minutesElapsed = floor(fmod(videoDuration/ 60.0,60.0));
    double secondsElapsed = floor(fmod(videoDuration,60.0));
    double hourElapsed = floor(videoDuration/ 3600.0);
    self.timeLB.text = [NSString stringWithFormat:@"当前 %02.0f:%02.0f:%02.0f", hourElapsed,minutesElapsed, secondsElapsed];
    
    CGFloat total=totalDur+videoDuration;
    double minutesElapsed1 = floor(fmod(total/ 60.0,60.0));
    double secondsElapsed1 = floor(fmod(total,60.0));
    double hourElapsed1 = floor(total/ 3600.0);
    self.totalTimeLB.text = [NSString stringWithFormat:@"总时长 %02.0f:%02.0f:%02.0f", hourElapsed1,minutesElapsed1, secondsElapsed1];
    
}

- (void)videoRecorder:(SBVideoRecorder *)videoRecorder didFinishMergingVideosToOutPutFileAtURL:(NSURL *)outputFileURL
{
    [_hud hide:YES];
    self.isProcessingData = NO;
    PlayViewController *playCon = [[PlayViewController alloc] initWithNibName:nil bundle:nil withVideoFileURL:outputFileURL];
    [self.navigationController pushViewController:playCon animated:YES];
}

#pragma mark - Touch Event
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_isProcessingData) {
        return;
    }

    
    UITouch *touch = [touches anyObject];
    
    CGPoint touchPoint  = [touch locationInView:self.view];//previewLayer 的 superLayer所在的view
    if (CGRectContainsPoint(_recorder.preViewLayer.frame, touchPoint)) {
        [self showFocusRectAtPoint:touchPoint];
        [_recorder focusInPoint:touchPoint];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_isProcessingData) {
        return;
    }
    

}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case TAG_ALERTVIEW_CLOSE_CONTROLLER:
        {
            switch (buttonIndex) {
                case 0:
                {
                }
                    break;
                case 1:
                {
                    [self dropTheVideo];
                }
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma  mark 横屏设置
/**
 *  强制横屏
 */
-(void)forceOrientationLandscape{
    //这段代码，只能旋转屏幕不能达到强制横屏的效果
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = UIInterfaceOrientationLandscapeRight;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
    //加上代理类里的方法，旋转屏幕可以达到强制横屏的效果
    AppDelegate *appdelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    appdelegate.isForceLandscape=YES;
    [appdelegate application:[UIApplication sharedApplication] supportedInterfaceOrientationsForWindow:self.view.window];
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



















