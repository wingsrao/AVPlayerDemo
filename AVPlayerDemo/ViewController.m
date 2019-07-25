//
//  ViewController.m
//  AVPlayerDemo
//
//  Created by zhl on 2019/7/25.
//  Copyright © 2019 wings. All rights reserved.
//

#import "ViewController.h"
#import "ZWKVideoPlayerVC.h"
#import "ZNavigationController.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *urlTF;
@property (nonatomic,assign) BOOL isLandscape;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)playClick:(id)sender {
    ZWKVideoPlayerVC *vc = [ZWKVideoPlayerVC new];
    vc.isLandscape = _isLandscape;//是否横屏视频
    vc.videoUrl = _urlTF.text;
    
    ZNavigationController *navi = [[ZNavigationController alloc]initWithRootViewController:vc];
    [self presentViewController:navi animated:YES completion:^{}];
}
- (IBAction)lanscapeClick:(id)sender {
    UISwitch *sw = sender;
    _isLandscape = sw.isOn;
}

@end
