//
//  TYRecordView.m
//  TYRecordDemo
//
//  Created by Tiny on 2019/2/21.
//  Copyright © 2019年 hxq. All rights reserved.
//

#import "TYRecordView.h"
#import "TYRecordEngine.h"
#import "TYRecordButton.h"
#import "TYRecordSuccessView.h"
#import "SGMotionManager.h"

#define TIMER_INTERVAL 0.5 //定时器时间间隔
#define RECORD_TIME 0.5 //开始录制视频的时间
#define VIDEO_MIN_TIME 3 // 录制视频最短时间

@interface TYRecordView ()<TYRecordEngineDelegate>

@property (nonatomic ,strong) NSTimer *timer;// 定时器

@property (nonatomic ,assign) BOOL isEndRecord;// 录制结束

@property (strong, nonatomic) TYRecordEngine  *recordEngine;

@property (nonatomic ,strong) UIImageView *focusView;// 对焦图片

@property (nonatomic, strong) UIButton *changeCameraBT; //切换前后摄像头

@property (nonatomic, strong) UIButton *flashLightBT;  //闪光灯

@property (nonatomic, strong) UIButton *closeViedoBT;  //关闭按钮

@property (nonatomic, strong) TYRecordButton *recordBT;   //录制按钮

@property (nonatomic ,strong) TYRecordSuccessView *preview;// 拍摄成功预览视图


@property (nonatomic ,assign) NSTimeInterval timeInterval;// 时长

@end

@implementation TYRecordView

- (TYRecordEngine *)recordEngine {
    if (_recordEngine == nil) {
        _recordEngine = [[TYRecordEngine alloc] init];
        _recordEngine.delegate = self;
    }
    return _recordEngine;
}

- (NSTimer *)timer{
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:TIMER_INTERVAL target:self selector:@selector(caculateTime) userInfo:nil repeats:YES];
    }
    return _timer;
}

- (UIImageView *)focusView{
    if (!_focusView) {
        _focusView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"camera_focus_red"]];
        _focusView.bounds = CGRectMake(0, 0, 40, 40);
        [self addSubview:_focusView];
    }
    return _focusView;
}

- (UIButton *)changeCameraBT{
    if (!_changeCameraBT) {
        _changeCameraBT = [UIButton new];
        [_changeCameraBT setImage:[UIImage imageNamed:@"btn_record_flip"] forState:UIControlStateNormal];
    }
    return _changeCameraBT;
}

-(UIButton *)closeViedoBT{
    if (!_closeViedoBT) {
        _closeViedoBT = [UIButton new];
        [_closeViedoBT setImage:[UIImage imageNamed:@"btn_record_close"] forState:UIControlStateNormal];
    }
    return _closeViedoBT;
}

-(UIButton *)flashLightBT{
    if (!_flashLightBT) {
        _flashLightBT = [UIButton new];
        [_flashLightBT setImage:[UIImage imageNamed:@"btn_video_flash_close"] forState:UIControlStateNormal];
        [_flashLightBT setImage:[UIImage imageNamed:@"btn_video_flash_open"] forState:UIControlStateSelected];
    }
    return _flashLightBT;
}

-(TYRecordButton *)recordBT{
    if (!_recordBT) {
        _recordBT = [[TYRecordButton alloc]initWithFrame:CGRectMake(0, 0, 156/2, 156/2)];
        _recordBT.center = CGPointMake(self.center.x, self.bounds.size.height - 97);
        
        [_recordBT addTarget:self action:@selector(toucheUpInsideOrOutSide:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
        [_recordBT addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
    }
    return _recordBT;
}

- (TYRecordSuccessView *)preview{
    if (!_preview) {
        _preview = [[TYRecordSuccessView alloc]initWithFrame:self.bounds];
        __weak typeof(self) weakself = self;
        [_preview setSendBlock:^(UIImage *image,NSString *videoPath){
//            [weakself sendWithImage:image videoPath:videoPath];
            if (weakself.recordSuccess) {
                weakself.recordSuccess(image, videoPath);
            }
        }];
        [_preview setCancelBlcok:^{
            [weakself cancel];
        }];
        [self addSubview:_preview];
    }
    return _preview;
}

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    
    // 监听设备方向
    [[SGMotionManager sharedManager] startDeviceMotionUpdates];
    [SGMotionManager sharedManager].delegate = self;;
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_9_0
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
#endif
    
    if (_recordEngine == nil) {
        [self.recordEngine previewLayer].frame = self.bounds;
        [self.layer insertSublayer:[self.recordEngine previewLayer] atIndex:0];
    }
    [self.recordEngine startUp];
    
    //设置UI
    //关闭按钮
    [self addSubview:self.closeViedoBT];
    [self.closeViedoBT addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    self.closeViedoBT.frame = CGRectMake(10, 20, 40, 40);
    
    //灯光
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
    [self addSubview:self.flashLightBT];
    self.flashLightBT.frame = CGRectMake(screenW - 40 - 10, 20, 40, 40);
    [self.flashLightBT addTarget:self action:@selector(flashLightAction) forControlEvents:UIControlEventTouchUpInside];
    
    //切换前后摄像头
    [self addSubview:self.changeCameraBT];
    self.changeCameraBT.frame = CGRectMake(screenW - 40*2 -10 - 5, 20, 40, 40);
    [self.changeCameraBT addTarget:self action:@selector(changeCameraAction) forControlEvents:UIControlEventTouchUpInside];
    
    //开始录制按钮
    [self addSubview:self.recordBT];

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [self addGestureRecognizer:tapGesture];
}

#pragma mark -显示或隐藏界面
// 显示所有操作按钮
- (void)showAllOperationViews{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.recordBT setHidden:NO];
        [self.closeViedoBT setHidden:NO];
        [self.flashLightBT setHidden:NO];
        [self.changeCameraBT setHidden:NO];
    });
}
// 隐藏所有操作按钮
- (void)hideAllOperationViews{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.recordBT setHidden:YES];
        [self.closeViedoBT setHidden:YES];
        [self.flashLightBT setHidden:YES];
        [self.changeCameraBT setHidden:YES];
    });
}
// 拍摄结束后显示退出按钮和切换摄像头按钮
- (void)showExitAndSwitchViews{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.closeViedoBT setHidden:NO];
        [self.flashLightBT setHidden:NO];
        [self.changeCameraBT setHidden:NO];
    });
}
// 开始拍摄时隐藏退出和切换摄像头按钮
- (void)hideExitAndSwitchViews{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.closeViedoBT setHidden:YES];
        [self.flashLightBT setHidden:YES];
        [self.changeCameraBT setHidden:YES];
    });
}

// 按钮按下事件
- (void)touchDown:(UIButton *)button{
    NSLog(@"按下按钮");
    [self hideExitAndSwitchViews];
    [self removeTimer];
    [self timer];
}

- (void)toucheUpInsideOrOutSide:(UIButton *)button{
    NSLog(@"抬起按钮:__timeInterval==:%f",_timeInterval);
    [self removeTimer];
    if (_timeInterval >= RECORD_TIME && _timeInterval < RECORD_TIME + VIDEO_MIN_TIME) {
        // 录制时间太短
        NSLog(@"录制时间太短");
        [self stopRecord:NO];
//        [self alart];//提示用户
        [self.recordBT resetScale];
    } else if (_timeInterval < RECORD_TIME) {
        // 拍照
        NSLog(@"拍照");
        [self.recordBT setEnabled:NO];
        [self hideAllOperationViews];
//        [self takephoto];
    } else {
        // 拍摄视频
        NSLog(@"结束录制");
        if (!_isEndRecord) {
            [self.recordBT setEnabled:NO];
            [self stopRecord:YES];
        }
    }
    _timeInterval = 0;
}

// 计时
- (void)caculateTime{
    
    _timeInterval += TIMER_INTERVAL;
    NSLog(@"计时器:_timeInterval:%f",_timeInterval);
    if (_timeInterval == RECORD_TIME) {
        NSLog(@"开始录制视频");
        [self.recordBT setScale];
        [self startRecord];
    } else if (_timeInterval >= RECORD_TIME + VIDEO_MIN_TIME) {
        [self removeTimer];
    }
}

// 移除定时器
- (void)removeTimer{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}
/**
 设置对焦光标位置
 
 @param point 光标位置
 */
-(void)setFocusCursorWithPoint:(CGPoint)point{
    self.focusView.center=point;
    self.focusView.transform=CGAffineTransformMakeScale(1.5, 1.5);
    self.focusView.alpha=1.0;
    [UIView animateWithDuration:1.0 animations:^{
        self.focusView.transform=CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.focusView.alpha=0;
        
    }];
}

- (void)tapGesture:(UITapGestureRecognizer *)tapGesture{
    NSLog(@"点击屏幕");
    if (!self.recordEngine.isRunning) return;
    CGPoint point = [tapGesture locationInView:self];
    [self setFocusCursorWithPoint:point];
    CGPoint camaraPoint = [self.recordEngine.previewLayer captureDevicePointOfInterestForPoint:point];
    [self.recordEngine focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposureMode:AVCaptureExposureModeContinuousAutoExposure atPoint:camaraPoint];
}

-(void)closeAction{
    if (self.dismiss) {
        self.dismiss();
    }
}

//开关闪光灯
- (void)flashLightAction {
    if (self.changeCameraBT.selected == NO) {
        self.flashLightBT.selected = !self.flashLightBT.selected;
        if (self.flashLightBT.selected == YES) {
            [self.recordEngine openFlashLight];
        }else {
            [self.recordEngine closeFlashLight];
        }
    }
}

//切换前后摄像头
- (void)changeCameraAction {
    self.changeCameraBT.selected = !self.changeCameraBT.selected;
    if (self.changeCameraBT.selected == YES) {
        //前置摄像头
        [self.recordEngine closeFlashLight];
        self.flashLightBT.selected = NO;
        [self.recordEngine changeCameraInputDeviceisFront:YES];
    }else {
        [self.recordEngine changeCameraInputDeviceisFront:NO];
    }
}

//录制下一步点击事件
//- (IBAction)stopRecordAction{
//    if (_recordEngine.videoPath.length > 0) {
//        //        __weak typeof(self) weakSelf = self;
//        [self.recordEngine stopCaptureHandler:^(UIImage *movieImage) {
//            //            weakSelf.playerVC = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:weakSelf.recordEngine.videoPath]];
//            //            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playVideoFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:[weakSelf.playerVC moviePlayer]];
//            //            [[weakSelf.playerVC moviePlayer] prepareToPlay];
//            //
//            //            [weakSelf presentMoviePlayerViewControllerAnimated:weakSelf.playerVC];
//            //            [[weakSelf.playerVC moviePlayer] play];
//        }];
//    }else {
//        NSLog(@"请先录制视频~");
//    }
//}


#pragma mark -录制视频
- (void)startRecord{
    if (self.recordEngine.isCapturing) {
        [self.recordEngine resumeCapture];
    }else {
        [self.recordEngine startCapture];
    }
}


- (void)stopRecord:(BOOL)isSuccess{
    
    _isEndRecord = NO;
    [self.recordBT setProgress:0];
    if (isSuccess) {
        [self hideAllOperationViews];
    } else {
        [self showExitAndSwitchViews];
    }
    __weak typeof(self) weakself = self;
    [self.recordEngine stopCaptureWithStatus:isSuccess handler:^(UIImage *movieImage,NSString *filePath) {
        NSLog(@"第一帧:image:%@",movieImage);
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself.recordEngine shutdown];
            [weakself.preview setImage:nil videoPath:filePath captureVideoOrientation:[[SGMotionManager sharedManager] currentVideoOrientation]];
        });
    }];
}

#pragma mark -SGRecordEngineDelegate(录制进度回调)
- (void)recordProgress:(CGFloat)progress{
    NSLog(@"progress:%f",progress);
    if (progress >= 0) {
        [self.recordBT setProgress:progress];
    }
    if ((int)progress == 1) {
        _isEndRecord = YES;
        [self stopRecord:YES];
    }
}

#pragma mark -相机,麦克风权限
- (void)authorizationStatus{
    AVAuthorizationStatus videoStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        if (granted) {
            NSLog(@"允许访问相机权限");
        } else {
            NSLog(@"不允许相机访问");
        }
    }];
    
    AVAuthorizationStatus audioStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
        if (granted) {
            NSLog(@"允许麦克风权限");
        } else {
            NSLog(@"不允麦克风访问");
        }
    }];
    
}


#pragma mark - 发送 or 重拍
// 点击发送
- (void)sendWithImage:(UIImage *)image videoPath:(NSString *)videoPath{
    NSLog(@"发送");
//    [self exitRecordController];
}
// 点击重拍
- (void)cancel{
    NSLog(@"重拍");
    if (_preview) {
        [_preview removeFromSuperview];
        _preview = nil;
    }
    [self.recordBT resetScale];
    [self.recordBT setEnabled:YES];
    [self showAllOperationViews];
    [self.recordEngine startUp];
}

-(void)dealloc{
    // 停止监听设备方向
    [SGMotionManager sharedManager].delegate = nil;
    [[SGMotionManager sharedManager] stopDeviceMotionUpdates];
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_9_0
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
#endif
    [self removeTimer];
    [self.recordEngine shutdown];
}

@end
