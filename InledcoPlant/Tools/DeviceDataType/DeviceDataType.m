//
//  DeviceDataType.m
//  InledcoPlant
//
//  Created by huang zhengguo on 2017/6/12.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

#import "DeviceDataType.h"



@implementation DeviceDataType

+(instancetype)defaultDeviceDataType{
    static DeviceDataType *deviceDataType = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        deviceDataType = [[DeviceDataType alloc] init];
    });
    
    return deviceDataType;
}

- (instancetype)init{
    if (self=[super init]){
        _deviceCodeNameDic = @{
                               @"9999":@"Plant Light"
                               };
        _deviceCodePicDic = @{
                              @"9999":@"led.png"
                              };
        _diviceCodeChannelNumDic = @{
                                     @"9999":@"5"
                                     };
    }
    
    return self;
}

@end
