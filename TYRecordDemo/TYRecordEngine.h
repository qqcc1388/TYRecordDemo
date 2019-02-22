//
//  TYRecordEngine.h
//  TYRecordDemo
//
//  Created by Tiny on 2019/2/21.
//  Copyright © 2019年 hxq. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVCaptureVideoPreviewLayer.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TYRecordEngineDelegate <NSObject>

- (void)recordProgress:(CGFloat)progress;

@end

@interface TYRecordEngine : NSObject

@property (atomic, assign, readonly) BOOL isCapturing;//正在录制
@property (atomic, assign, readonly) BOOL isPaused;//是否暂停
@property (atomic, assign, readonly) CGFloat currentRecordTime;//当前录制时间
@property (atomic, assign) CGFloat maxRecordTime;//录制最长时间
@property (weak, nonatomic) id<TYRecordEngineDelegate>delegate;
@property (atomic, strong) NSString *videoPath;//视频路径
@property (nonatomic, readonly,getter=isRunning) BOOL isRunning; // 捕捉图像

//捕获到的视频呈现的layer
- (AVCaptureVideoPreviewLayer *)previewLayer;
//启动录制功能
- (void)startUp;
//关闭录制功能
- (void)shutdown;
//开始录制
- (void) startCapture;
//暂停录制
- (void) pauseCapture;
/**
 停止录制
 
 @param isSuccess 是否是成功的录制操作
 @param handler 返回视频第一帧图像和视频在磁盘中的路径
 */
- (void) stopCaptureWithStatus:(BOOL)isSuccess handler:(void (^)(UIImage *movieImage,NSString *path))handler;
//继续录制
- (void) resumeCapture;
//开启闪光灯
- (void)openFlashLight;
//关闭闪光灯
- (void)closeFlashLight;
//切换前后置摄像头
- (void)changeCameraInputDeviceisFront:(BOOL)isFront;
//将mov的视频转成mp4
- (void)changeMovToMp4:(NSURL *)mediaURL dataBlock:(void (^)(UIImage *movieImage,NSString *path))handler;
/**
 设置对焦点和曝光度
 
 @param focusMode 对焦模式
 @param exposureMode 曝光模式
 @param point 点击的位置
 */
-(void)focusWithMode:(AVCaptureFocusMode)focusMode exposureMode:(AVCaptureExposureMode)exposureMode atPoint:(CGPoint)point;
@end

NS_ASSUME_NONNULL_END
