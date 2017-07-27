//
//  DeviceDataType.h
//  InledcoPlant
//
//  Created by huang zhengguo on 2017/6/12.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceDataType : NSObject

//单例类实现
+(instancetype)defaultDeviceDataType;

// 设置类型编码和名称对照
@property(nonatomic, strong) NSDictionary *deviceCodeNameDic;
// 设备类型编码和图片对照
@property(nonatomic, strong) NSDictionary *deviceCodePicDic;
// 设备类型编码对应路数
@property(nonatomic, strong) NSDictionary *diviceCodeChannelNumDic;

@end
