//
//  ECOPlantParameterModel.h
//  InledcoPlant
//
//  Created by huang zhengguo on 2017/5/31.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ECOPlantParameterModel : NSObject

// 设备识别ID
@property(nonatomic, copy) NSString *UUIDString;

// 设备类型编码
@property(nonatomic, copy) NSString *deviceTypeCode;

// 通道数量
@property(nonatomic, assign) NSInteger channelNum;

// 帧头
@property(nonatomic, copy) NSString *headerStr;

// 命令码
@property(nonatomic, copy) NSString *commandStr;

// 运行模式
@property(nonatomic, copy) NSString *runMode;

// 设备开关状态
@property(nonatomic, copy) NSString *powerState;

// 周期模式是否开启
@property(nonatomic, assign) BOOL isOpenCycleMode;

// 生长周期个数
@property(nonatomic, assign) NSInteger cycleCount;

// 生长周日起始日期字符串
@property(nonatomic, copy) NSString *cycleStartDate;

// 每个周期对应的数据:每个周期的数据都以字符串的形式存储起来
@property(nonatomic, strong) NSMutableDictionary *cycleDataDic;

@end
