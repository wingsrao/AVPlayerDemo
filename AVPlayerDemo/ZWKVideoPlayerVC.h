//
//  ZWKVideoPlayerVC.h
//  ZHLEnglishTeacher
//
//  Created by zhl on 2019/7/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
//播放mp4视频
@interface ZWKVideoPlayerVC : UIViewController
@property (nonatomic,assign) BOOL isLandscape;//横屏
@property (nonatomic,copy) NSString *videoUrl;//视频url

@end

NS_ASSUME_NONNULL_END
