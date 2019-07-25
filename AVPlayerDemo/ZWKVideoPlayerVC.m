//
//  ZWKVideoPlayerVC.m
//  ZHLEnglishTeacher
//
//  Created by zhl on 2019/7/24.
//

#import "ZWKVideoPlayerVC.h"
#import <AVFoundation/AVFoundation.h>
#import "AVPlayerView.h"
#import "ZHLQKVideoChangeRate.h"
#import "ZNavigationController.h"
#import "Masonry.h"

#define ZRGB(r,g,b,a)               [UIColor colorWithRed:(double)r/255.0f green:(double)g/255.0f blue:(double)b/255.0f alpha:a]
#define ZScreenWidth                        [[UIScreen mainScreen] bounds].size.width                       //屏幕宽度
#define ZScreenHeight                       [[UIScreen mainScreen] bounds].size.height
#define ZIsPad                              (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)          //是否是iPad
//判断iPhoneX，Xs（iPhoneX，iPhoneXs）
#define IS_IPHONE_X ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) && !ZIsPad : NO)
//判断iPhoneXr
#define IS_IPHONE_Xr ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(828, 1792), [[UIScreen mainScreen] currentMode].size) && !ZIsPad : NO)
//判断iPhoneXsMax
#define IS_IPHONE_Xs_Max ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2688), [[UIScreen mainScreen] currentMode].size)&& !ZIsPad : NO)

#define ZIsiPhoneX (IS_IPHONE_X || IS_IPHONE_Xr || IS_IPHONE_Xs_Max)
#define ZWeakSelf   __weak     typeof(self) weakSelf = self;
#define ZNavigationBarHeight                (ZIsiPhoneX ? 88.0f : 64.0f)
#define ZStatusBarHeight                    [UIApplication sharedApplication].statusBarFrame.size.height    //状态栏高度

@interface ZWKVideoPlayerVC ()<ZHLControllerWillLandscape,UIGestureRecognizerDelegate>

@property (nonatomic, weak) UIView *navView;//导航栏
@property (nonatomic, weak) UIView *bottomView;//底部进度
@property (nonatomic, strong) UIView *controlView;
@property (nonatomic, weak) UIButton *playPauseBtn;//播放暂停
@property (nonatomic, weak) UISlider *slider;//进度条
@property (nonatomic, weak) UILabel *currentTimeLabel;//当前播放到的时间
@property (nonatomic, weak) UILabel *totalTimeLabel;//总时间
@property (nonatomic,strong) UIButton *rateBtn;
@property (nonatomic, strong) ZHLQKVideoChangeRate *changeRateView;

@property (nonatomic,assign) float currentRate;//播放速率
@property (nonatomic, assign) BOOL hiddeStatusBar;//是否隐藏状态栏
@property (nonatomic, assign) BOOL canPlay;

@property (nonatomic,strong) AVPlayer      *avPlayer;
@property (nonatomic,strong) AVPlayerItem  *avPlayerItem;
@property (nonatomic,strong) AVPlayerLayer *avPlayerLayer;
@property (nonatomic,strong) id playbackObserver;


@end

@implementation ZWKVideoPlayerVC
- (BOOL)shouldAutorotate{
    return NO;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    if (self.isLandscape) {
        return UIInterfaceOrientationLandscapeRight;
    }
    return UIInterfaceOrientationPortrait;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    if (self.isLandscape) {
        return UIInterfaceOrientationMaskLandscapeRight;
    }
    return UIInterfaceOrientationMaskPortrait;
}

//隐藏、显示状态栏
- (BOOL)prefersStatusBarHidden {
    return self.hiddeStatusBar;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initPlayer];
    [self initUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self playPauseClick];
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)dealloc {
}

#pragma mark - initUI
- (void)initPlayer{
    
    _currentRate = 1.0;
    
    NSString *landscape = @"http://zhl-file.xxfz.com.cn/group1/M05/04/5C/dr5jH1xRbVKIXCk-AAAAPHE9ZY8AAG2_AP_86YAAABU706.mp4";
    NSString *portrait = @"http://zhl-file.xxfz.com.cn/group1/M05/03/F7/dr5jH1wa95eIXnVlAAAAPFWxYNEAAGR8AP_5NQAAABU337.mp4";
    if (self.videoUrl.length <= 0) {
        self.videoUrl = _isLandscape?landscape:portrait;
    }
    
    //创建视频播放器
//    NSString *filePath =[[NSBundle mainBundle]pathForResource:@"flash" ofType:@"mp4"];
    
    NSURL *sourceMovieURL = [NSURL fileURLWithPath:self.videoUrl];
    AVAsset *movieAsset = [AVURLAsset URLAssetWithURL:sourceMovieURL options:nil];
    self.avPlayerItem = [AVPlayerItem playerItemWithAsset:movieAsset];
//    self.avPlayerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:self.videoUrl]];
    self.avPlayer      = [AVPlayer playerWithPlayerItem:self.avPlayerItem];
    self.avPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
    self.avPlayerLayer.backgroundColor  = [UIColor redColor].CGColor;
    AVPlayerView *avPlayerView = [[AVPlayerView alloc] initWithMoviePlayerLayer:self.avPlayerLayer frame:self.view.bounds];
    [self.view addSubview:avPlayerView];

    //对item添加监听
    [self.avPlayerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self.avPlayerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [self.avPlayerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
//    [self.avPlayer play];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    //监听时间
    ZWeakSelf
    self.playbackObserver = [self.avPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
        CGFloat currentSecond = weakSelf.avPlayerItem.currentTime.value/self.avPlayerItem.currentTime.timescale;
        weakSelf.currentTimeLabel.text = [NSString stringWithFormat:@"%.2d:%.2ld" ,(int)(currentSecond/60) , lroundf(currentSecond)%60];
        weakSelf.slider.value = MIN(weakSelf.slider.maximumValue, currentSecond);
    }];
}

- (void)initUI{
    self.view.backgroundColor = UIColor.whiteColor;
    self.controlView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.controlView.backgroundColor = UIColor.clearColor;
    [self.view addSubview:self.controlView];
    
    // 单击的 Recognizer
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    singleTap.numberOfTapsRequired = 1; // 单击
    singleTap.numberOfTouchesRequired = 1;
    singleTap.delegate = self;
    [self.controlView addGestureRecognizer:singleTap];
    
    //navigationView
    UIView *navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ZScreenWidth, _isLandscape?64:ZNavigationBarHeight)];
    self.navView = navView;
    navView.backgroundColor = ZRGB(119,211,0,1.0f);
    [self.controlView addSubview:navView];
    //标题
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(64, ZStatusBarHeight, ZScreenWidth-128, 44)];
    [title setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18]];
    title.textColor = [UIColor whiteColor];
    title.textAlignment = NSTextAlignmentCenter;
    title.text = @"标题";
    [navView addSubview:title];
    //返回按钮
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom] ;
    [backBtn setImage:[UIImage imageNamed:@"z-nav-back"] forState:UIControlStateNormal];
    backBtn.frame = CGRectMake(_isLandscape?20:0, ZStatusBarHeight, 44, 44);
    [backBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [navView addSubview:backBtn];
    
    //bottomView
    float bh = ZIsiPhoneX?45+34:45;
    UIView *bottomToolView = [[UIView alloc] initWithFrame:CGRectMake(0, self.controlView.frame.size.height-bh, ZScreenWidth, bh)];
    self.bottomView = bottomToolView;
    bottomToolView.backgroundColor = ZRGB(0, 0, 0, 0.7);
    [self.controlView addSubview:bottomToolView];
    //当前时间
    UILabel *currentTimLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 45)];
    self.currentTimeLabel = currentTimLab;
    currentTimLab.text = @"00:00";
    currentTimLab.textAlignment = NSTextAlignmentCenter;
    currentTimLab.font = [UIFont systemFontOfSize:12];
    currentTimLab.textColor = [UIColor whiteColor];
    [bottomToolView addSubview:currentTimLab];
    
    //进度条
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(CGRectGetMaxX(currentTimLab.frame), 0, CGRectGetWidth(bottomToolView.frame)-CGRectGetMaxX(currentTimLab.frame)-40-75, 45)];
    self.slider = slider;
    [slider setThumbImage:[UIImage imageNamed:@"z_recording_video_progress"]  forState:UIControlStateNormal];
    slider.minimumTrackTintColor = ZRGB(29, 201, 223, 1.0);
    slider.maximumTrackTintColor = [UIColor whiteColor];
    [slider addTarget:self action:@selector(sliderDrug:) forControlEvents:UIControlEventValueChanged];
    [slider addTarget:self action:@selector(updateProgress:) forControlEvents:UIControlEventTouchUpInside];
    [bottomToolView addSubview:slider];
    //总时间
    UILabel *totleTimLab = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(bottomToolView.frame)-40-75, 0, 40, 45)];
    self.totalTimeLabel = totleTimLab;
    totleTimLab.text = @"00:00";
    totleTimLab.textAlignment = NSTextAlignmentCenter;
    totleTimLab.font = [UIFont systemFontOfSize:12];
    totleTimLab.textColor = [UIColor whiteColor];
    [bottomToolView addSubview:totleTimLab];
    
    //倍速
    UIButton *rateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.rateBtn = rateBtn;
    rateBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    rateBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    rateBtn.frame = CGRectMake(CGRectGetMaxX(totleTimLab.frame)+15, 10, 44, 24);
    rateBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    rateBtn.layer.borderWidth = 1;
    rateBtn.layer.cornerRadius = 3;
    [rateBtn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    [rateBtn setTitle:[NSString stringWithFormat:@"%.1fx",_currentRate] forState:(UIControlStateNormal)];
    [rateBtn addTarget:self action:@selector(showRateView) forControlEvents:(UIControlEventTouchUpInside)];
    [bottomToolView addSubview:rateBtn];
    
    //暂停继续
    UIButton *playPauseBtn = [[UIButton alloc] initWithFrame:CGRectMake((ZScreenWidth-67)/2, (ZScreenHeight-67)/2, 67, 67)];
    self.playPauseBtn = playPauseBtn;
    [playPauseBtn setImage:[UIImage imageNamed:@"z_recording_playpause"] forState:UIControlStateNormal];
    [playPauseBtn setImage:[UIImage imageNamed:@"z_recording_playpause_sel"] forState:UIControlStateSelected];
    playPauseBtn.selected = NO;
    [playPauseBtn addTarget:self action:@selector(playPauseClick) forControlEvents:UIControlEventTouchUpInside];
    [self.controlView addSubview:playPauseBtn];
    
}

#pragma mark - 事件
//暂停、继续
- (void)playPauseClick{
    if (!self.canPlay) {
        return;
    }
    if (self.slider.value >= self.slider.maximumValue) {//播放结束，从头开始放
        [self replay];
    }else{
        if (_playPauseBtn.selected) {//正在播放  执行暂停操作
            [self.avPlayer pause];
        }else{//已暂停  执行播放操作
            [self.avPlayer playImmediatelyAtRate:_currentRate];
        }
    }
    _playPauseBtn.selected = !_playPauseBtn.selected;
}

//视频重播
- (void)replay{
    self.slider.value = 0;
    [self.avPlayer seekToTime:kCMTimeZero];
    [self.avPlayer playImmediatelyAtRate:_currentRate];
}

- (void)playTime:(float)time{
    NSInteger dragedSeconds = floorf(time);
    CMTime dragedCMTime = CMTimeMake(dragedSeconds, 1);
    [self.avPlayer seekToTime:dragedCMTime];
    [self.avPlayer playImmediatelyAtRate:_currentRate];
}

//单击手势
- (void)handleSingleTap:(UITapGestureRecognizer *)sender{
    [UIView animateWithDuration:0.5 animations:^{
        if (self.bottomView.alpha == 0.0) {
            [self showHandleView];
        }else{
            [self hiddenControlView];
        }
    } completion:^(BOOL finish){
        
    }];
}
- (void)sliderDrug:(UISlider *)sender {//进度条拖动的时候 如果正在播放，就暂停播放、更新时间
    if (sender.value < self.slider.maximumValue) {
        _currentTimeLabel.text = [NSString stringWithFormat:@"%.2d:%.2ld" ,(int)(sender.value/60) , lroundf(sender.value)%60];
    }else{//为了保证拖到最后 不会出现左边时间大于总时间
        _currentTimeLabel.text = _totalTimeLabel.text;
    }
}
- (void)updateProgress:(UISlider *)sender {//进度条拖拽结束
    if (sender.value == 0) {//直接播放 不显示loading
        if (!_playPauseBtn.selected) {
            [self playPauseClick];
        }
    }else{//显示loading，播放对应时间点的视频
        [self playTime:sender.value];
    }
}

//返回按钮
- (void)backBtnClick{
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:^{
            [self releaseObj];
        }];
    }else{
        [self releaseObj];
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)releaseObj{
    [self.avPlayer pause];
    [self.avPlayer removeTimeObserver:self.playbackObserver];
    [self.avPlayer.currentItem cancelPendingSeeks];
    [self.avPlayer.currentItem.asset cancelLoading];
    [self.avPlayerLayer removeFromSuperlayer];
    self.avPlayerLayer = nil;
    self.avPlayer = nil;
}
//播放a完成
- (void)moviePlayDidEnd{
    self.slider.value = self.slider.maximumValue;
    self.currentTimeLabel.text = self.totalTimeLabel.text;
    [self.avPlayer pause];
    self.playPauseBtn.selected = NO;
}
//倍速
- (void)changeRateAction:(float)rate{
    _currentRate = rate;
    [self.avPlayer playImmediatelyAtRate:rate];
}
#pragma mark - private method  私有事件
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:@"loadedTimeRanges"]){
//        NSTimeInterval loadedTime = [self availableDurationWithplayerItem:playerItem];
    }else if ([keyPath isEqualToString:@"status"]){
        if (playerItem.status == AVPlayerItemStatusReadyToPlay){
            NSTimeInterval totalTime = CMTimeGetSeconds(playerItem.duration);
            self.slider.maximumValue = totalTime;
            self.totalTimeLabel.text = [NSString stringWithFormat:@"%.2d:%.2ld" ,(int)(totalTime/60) , lroundf(totalTime)%60];
            
            //自动播放
            self.canPlay = YES;
            [self playPauseClick];
            ZWeakSelf
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf hiddenControlView];
            });
        }else{
            //提示 视频加载失败
        }
    }else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
        //some code show loading
    }
}

- (NSTimeInterval)availableDurationWithplayerItem:(AVPlayerItem *)playerItem{
    NSArray *loadedTimeRanges = [playerItem loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    NSTimeInterval startSeconds = CMTimeGetSeconds(timeRange.start);
    NSTimeInterval durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}

#pragma mark - 自定义method
- (void)showRateView{
    self.changeRateView.hidden = !self.changeRateView.hidden;
}

- (void)hiddenControlView{//隐藏
    [UIView animateWithDuration:0.2 animations:^{
        self.navView.alpha = 0;
        self.bottomView.alpha = 0;
        self.playPauseBtn.alpha = 0;
        self.changeRateView.hidden = YES;
        
        self.hiddeStatusBar = YES;
        [self setNeedsStatusBarAppearanceUpdate];
    } completion:^(BOOL finished) {
    }];
}
- (void)showHandleView{//显示
    [UIView animateWithDuration:0.2 animations:^{
        self.navView.alpha = 1;
        self.bottomView.alpha = 1;
        self.playPauseBtn.alpha = 1;
        
        self.hiddeStatusBar = NO;
        [self setNeedsStatusBarAppearanceUpdate];
    } completion:^(BOOL finished) {
    }];
}
#pragma mark - getter & setter
- (ZHLQKVideoChangeRate *)changeRateView{
    if (!_changeRateView) {
        _changeRateView = [NSBundle.mainBundle loadNibNamed:NSStringFromClass([ZHLQKVideoChangeRate class]) owner:nil options:nil].lastObject;
        [self.view addSubview:_changeRateView];
        [_changeRateView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(288);
            make.height.mas_equalTo(42);
            make.right.mas_equalTo(-38);
            make.bottom.mas_equalTo(ZIsiPhoneX?-85:-50);
        }];
        ZWeakSelf
        _changeRateView.changeRateBlock = ^(id obj) {
            float rate = [obj floatValue];
            [weakSelf changeRateAction:rate];
            [weakSelf.rateBtn setTitle:[NSString stringWithFormat:@"%.1fx",rate] forState:(UIControlStateNormal)];
            weakSelf.changeRateView.hidden = YES;
            
        };
    }
    return _changeRateView;
}
@end
