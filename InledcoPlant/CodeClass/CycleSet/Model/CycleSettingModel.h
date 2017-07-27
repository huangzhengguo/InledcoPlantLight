//
//  CycleSettingModel.h
//  InledcoPlant
//
//  Created by huang zhengguo on 2017/6/8.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CycleSettingModel : NSObject

// 设备编码
@property(nonatomic, copy) NSString *deviceTypeCode;

// 是否开启周期模式
@property(nonatomic, assign) BOOL isOpenCycleMode;

// 生长周期个数
@property(nonatomic, assign) NSInteger cycleCount;

// 周期开始日期
@property(nonatomic, strong) NSDate *cycleStartDate;
// 周期持续天数：按顺序存放所有周期持续的天数
@property(nonatomic, strong) NSMutableArray *cycleLengthsArray;
// 各个周期内打开关闭灯光类型
@property(nonatomic, strong) NSMutableArray *cycleRampTypeArray;
// 各个周期内打开灯光的时间
@property(nonatomic, strong) NSMutableArray *lightTurnOnArray;
// 各个周期内关闭灯光的时间
@property(nonatomic, strong) NSMutableArray *lightTurnOffArray;
// 各个周期内颜色百分比
@property(nonatomic, strong) NSMutableDictionary *lightColorPercentDic;

@end
