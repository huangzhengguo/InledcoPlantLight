//
//  ManualDimmingView.h
//  InledcoPlant
//
//  Created by huang zhengguo on 2017/5/22.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceParameterModel.h"

typedef void (^sliderValueBlock) (NSInteger,float);

@interface ManualDimmingView : UIView

// 颜色滑动条数组
@property(nonatomic, strong) NSMutableArray *colorSliderArray;

// 百分比数值Label数组
@property(nonatomic, strong) NSMutableArray *colorPercentLabelArray;

/*
 * 初始化手动调光视图
 *
 * @param frame 视图的大小
 * @param colorPercentArray 所有路颜色值数组
 */
- (instancetype)initWithFrame:(CGRect)frame colorPercentArray:(NSArray *)colorPercentArray textColor:(UIColor *)textColor;
- (void)updateManualDimmingViewWith:(NSArray *)colorPercentArray;
// 滑动条block
@property(nonatomic, copy) sliderValueBlock colorDimmingBlock;

// 滑动条滑动结束
@property(nonatomic, copy) sliderValueBlock colorDimmingEndBlock;

@end
