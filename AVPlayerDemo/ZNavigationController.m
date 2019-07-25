//
//  ZNavigationController.m
//  AVPlayerDemo
//
//  Created by zhl on 2019/7/25.
//  Copyright © 2019 wings. All rights reserved.
//

#import "ZNavigationController.h"

@interface ZNavigationController ()

@end

@implementation ZNavigationController
//是否允许转屏
- (BOOL)shouldAutorotate
{
    if ([self.topViewController conformsToProtocol:@protocol(ZHLControllerWillLandscape)]) {
        return [self.topViewController shouldAutorotate];
    }
    return NO;
}
//viewController所支持的全部旋转方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if ([self.topViewController conformsToProtocol:@protocol(ZHLControllerWillLandscape)]) {
        return [self.topViewController supportedInterfaceOrientations];
    }
    return UIInterfaceOrientationMaskPortrait;
}
//viewController初始显示的方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    if ([self.topViewController conformsToProtocol:@protocol(ZHLControllerWillLandscape)]) {
        return [self.topViewController preferredInterfaceOrientationForPresentation];
    }
    return UIInterfaceOrientationPortrait;
}
#pragma mark -----   life cycle method 生命周期（包含类方法等初始化）
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)dealloc {
    
}
#pragma mark - init UI


#pragma mark - event response  事件响应


#pragma mark - delegate 代理方法


#pragma mark - request 请求方法


#pragma mark - private method  私有事件


#pragma mark  - getter or  setter



@end
