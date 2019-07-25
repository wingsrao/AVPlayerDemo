//
//  AVPlayerView.m
//  ZHLEnglishTeacher
//
//  Created by zhl on 2019/7/24.
//

#import "AVPlayerView.h"
@interface AVPlayerView(){
    AVPlayerLayer *_playerlayer;
}
@end
@implementation AVPlayerView

-(instancetype)initWithMoviePlayerLayer:(AVPlayerLayer *)playerLayer frame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _playerlayer = playerLayer;
        _playerlayer.backgroundColor =  [UIColor blackColor].CGColor;
        _playerlayer.videoGravity   = AVLayerVideoGravityResizeAspect;
        _playerlayer.contentsScale  = [UIScreen mainScreen].scale;
        [self.layer addSublayer:_playerlayer];
    }
    return self;
}

-(void)layoutSublayersOfLayer:(CALayer *)layer{
    [super layoutSublayersOfLayer:layer];
    _playerlayer.bounds   = self.layer.bounds;
    _playerlayer.position = self.layer.position;
}

@end
