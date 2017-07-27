//
//  DeviceParameterModel.h
//  InledcoPlant
//
//  Created by huang zhengguo on 2017/5/22.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 * 此模型用来保存设备的参数信息
 */

@interface DeviceParameterModel : NSObject

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

// 动态模式
@property(nonatomic, copy) NSString *dynaMode;

// 手动模式数据
@property(nonatomic, strong) NSMutableDictionary *manualValueDic;

// 用户自定义数据
@property(nonatomic, strong) NSMutableDictionary *userDefineValueDic;

// 自动模式时间点数据
@property(nonatomic, strong) NSMutableArray *timepointArray;

// 自动模式颜色设置信息
@property(nonatomic, strong) NSMutableDictionary *timepointValueDic;

@end
