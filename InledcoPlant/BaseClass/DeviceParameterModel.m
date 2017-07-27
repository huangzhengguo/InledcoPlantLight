//
//  DeviceParameterModel.m
//  InledcoPlant
//
//  Created by huang zhengguo on 2017/5/22.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

#import "DeviceParameterModel.h"

@implementation DeviceParameterModel
// 懒加载部分
- (NSMutableDictionary *)manualValueDic{
    if (_manualValueDic == nil){
        self.manualValueDic = [NSMutableDictionary dictionary];
    }
    
    return _manualValueDic;
}

- (NSMutableDictionary *)userDefineValueDic{
    if (_userDefineValueDic == nil){
        self.userDefineValueDic = [NSMutableDictionary dictionary];
    }
    
    return _userDefineValueDic;
}

- (NSMutableArray *)timepointArray{
    if (_timepointArray == nil){
        self.timepointArray = [NSMutableArray array];
    }
    
    return _timepointArray;
}

- (NSMutableDictionary *)timepointValueDic{
    if (_timepointValueDic == nil){
        self.timepointValueDic = [NSMutableDictionary dictionary];
    }
    
    return _timepointValueDic;
}

@end
