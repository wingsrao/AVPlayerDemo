//
//  ZHLQKVideoChangeRate.h
//  ZHLEnglishTeacher
//
//  Created by zhl on 2019/6/6.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
typedef void(^ActionBlock)(id obj);

@interface ZHLQKVideoChangeRate : UIView

@property (nonatomic,copy) ActionBlock changeRateBlock;

@end

NS_ASSUME_NONNULL_END
