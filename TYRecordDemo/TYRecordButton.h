//
//  TYRecordButton.h
//  TYRecordDemo
//
//  Created by Tiny on 2019/2/22.
//  Copyright © 2019年 hxq. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TYRecordButton : UIButton

@property (nonatomic ,assign) CGFloat progress;

- (void)resetScale;

- (void)setScale;

@end

NS_ASSUME_NONNULL_END
