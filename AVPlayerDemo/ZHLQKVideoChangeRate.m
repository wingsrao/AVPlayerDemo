//
//  ZHLQKVideoChangeRate.m
//  ZHLEnglishTeacher
//
//  Created by zhl on 2019/6/6.
//

#import "ZHLQKVideoChangeRate.h"
@interface ZHLQKVideoChangeRate()
@property (weak, nonatomic) IBOutlet UIButton *btn08;
@property (weak, nonatomic) IBOutlet UIButton *btn10;
@property (weak, nonatomic) IBOutlet UIButton *btn15;
@property (weak, nonatomic) IBOutlet UIButton *btn20;

@end

@implementation ZHLQKVideoChangeRate

- (void)awakeFromNib{
    [super awakeFromNib];
    [self checkedBtn:_btn10];
}

- (IBAction)btn08Click:(id)sender {
    [self checkedBtn:_btn08];
    if (_changeRateBlock) {
        _changeRateBlock(@0.8);
    }
}
- (IBAction)btn10Click:(id)sender {
    [self checkedBtn:_btn10];
    if (_changeRateBlock) {
        _changeRateBlock(@1.0);
    }
}
- (IBAction)btn15Click:(id)sender {
    [self checkedBtn:_btn15];
    if (_changeRateBlock) {
        _changeRateBlock(@1.5);
    }
}
- (IBAction)btn20Click:(id)sender {
    [self checkedBtn:_btn20];
    if (_changeRateBlock) {
        _changeRateBlock(@2.0);
    }
}

- (void)checkedBtn:(UIButton *)btn{
    _btn08.layer.borderWidth = 0;
    _btn10.layer.borderWidth = 0;
    _btn15.layer.borderWidth = 0;
    _btn20.layer.borderWidth = 0;
    
    btn.layer.borderColor = [UIColor whiteColor].CGColor;
    btn.layer.borderWidth = 1;
    btn.layer.cornerRadius = 3;
}


@end
