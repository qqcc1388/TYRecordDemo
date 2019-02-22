//
//  TYRecordView.h
//  TYRecordDemo
//
//  Created by Tiny on 2019/2/21.
//  Copyright © 2019年 hxq. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TYRecordView : UIView

@property (nonatomic, copy) void (^dismiss)(void);

@property (nonatomic, copy) void (^recordSuccess)(UIImage *image,NSString *videoPath);


@end

NS_ASSUME_NONNULL_END
