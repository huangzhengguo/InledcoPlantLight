//
//  DeviceModel.h
//  InledcoPlant
//
//  Created by huang zhengguo on 2017/2/9.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLEManager.h"

@interface DeviceModel : NSObject
// 分组名称：默认由系统指定，用户可以修改保存:数据库存储用
@property (nonatomic, copy) NSString *deviceGroupName;

// 设备名称：用户自定义:数据库存储用：和localName应该保持一致
@property (nonatomic, copy) NSString *deviceName;

// 设备类别编码
@property (nonatomic, copy) NSString *deviceTypeCode;

// 下面是deviceinfo中的信息：不能存储到数据库中
@property (nonatomic, strong) CBPeripheral* cb;

// UUID of Bluetooth Peripherals
@property (nonatomic, copy) NSString *UUIDString;

// 扫描用：标记设备是否已经被选择
@property (nonatomic, assign) BOOL isSelected;

@end
