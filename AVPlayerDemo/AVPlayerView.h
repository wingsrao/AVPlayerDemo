//
//  AVPlayerView.h
//  ZHLEnglishTeacher
//
//  Created by zhl on 2019/7/24.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface AVPlayerView : UIView
@property (nonatomic ,strong) AVPlayer *player;
-(instancetype)initWithMoviePlayerLayer:(AVPlayerLayer *)playerLayer frame:(CGRect)frame;
@end

NS_ASSUME_NONNULL_END
