//
//  TYRecordSuccessView.h
//  TYRecordDemo
//
//  Created by Tiny on 2019/2/22.
//  Copyright © 2019年 hxq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TYRecordSuccessView : UIView

@property (nonatomic ,copy) void (^sendBlock) (UIImage *image, NSString *videoPath);
@property (nonatomic ,copy) void (^cancelBlcok) (void);

/**
 设置图片或视频
 
 @param image 图片
 @param videoPath 视频地址
 @param orientation 方向
 */
- (void)setImage:(UIImage *)image videoPath:(NSString *)videoPath captureVideoOrientation:(AVCaptureVideoOrientation)orientation;

@end

NS_ASSUME_NONNULL_END
