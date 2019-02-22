//
//  ViewController.m
//  TYRecordDemo
//
//  Created by Tiny on 2019/2/21.
//  Copyright © 2019年 hxq. All rights reserved.
//

#import "ViewController.h"
#import "TYTestViewController.h"

@interface ViewController ()

@end

@implementation ViewController


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(100, 300, 150, 44)];
    [button setTitle:@"点击开始录制视频" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor redColor];
    [button addTarget:self action:@selector(itemCLick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];

}

-(void)itemCLick{
    TYTestViewController *testVc = [TYTestViewController new];
    [self presentViewController:testVc animated:YES completion:nil];
}

@end
