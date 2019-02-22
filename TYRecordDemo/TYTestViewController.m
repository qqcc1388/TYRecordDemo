//
//  TYTestViewController.m
//  TYRecordDemo
//
//  Created by Tiny on 2019/2/22.
//  Copyright © 2019年 hxq. All rights reserved.
//

#import "TYTestViewController.h"
#import "TYRecordView.h"

@interface TYTestViewController ()

@end

@implementation TYTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    TYRecordView *recordView = [[TYRecordView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:recordView];
    __weak typeof(self) weakself = self;
    recordView.dismiss = ^{
        [weakself dismissViewControllerAnimated:YES completion:nil];
    };
    recordView.recordSuccess = ^(UIImage * _Nonnull image, NSString * _Nonnull videoPath) {
      //录制完成 结束
        NSLog(@"视频路径:%@",videoPath);
    };
}

-(void)dealloc{
    
    NSLog(@"%s",__func__);
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
