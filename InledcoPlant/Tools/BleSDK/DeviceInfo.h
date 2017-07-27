//
//  DeviceInfo.h
//  智能控制系统
//
//  Created by rf on 15/7/17.
//  Copyright (c) 2015年 wangli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface DeviceInfo : NSObject

@property (nonatomic,strong) CBPeripheral* cb;


@property (nonatomic,strong) NSString * macAddrss;// Mac address broadcasted by Bluetooth peripherals

@property (nonatomic,copy) NSString * UUIDString;//UUID of Bluetooth peripherals

@property (nonatomic,copy) NSString * localName;//Manufacturer identifier of the Bluetooth peripherals

@property (nonatomic,copy) NSString * name; //The name of the Bluetooth peripherals

@property (nonatomic,assign) NSInteger RSSI;

@property (nonatomic, strong) NSDictionary * advertisementDic;

@end
