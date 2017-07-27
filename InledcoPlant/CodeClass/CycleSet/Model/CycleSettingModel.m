//
//  CycleSettingModel.m
//  InledcoPlant
//
//  Created by huang zhengguo on 2017/6/8.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

#import "CycleSettingModel.h"

@implementation CycleSettingModel

-(NSMutableArray *)cycleLengthsArray{
    if (_cycleLengthsArray == nil){
        self.cycleLengthsArray = [NSMutableArray array];
    }
    return _cycleLengthsArray;
}

- (NSMutableArray *)cycleRampTypeArray{
    if (_cycleRampTypeArray == nil){
        self.cycleRampTypeArray = [NSMutableArray array];
    }
    return _cycleRampTypeArray;
}

- (NSMutableArray *)lightTurnOnArray{
    if (_lightTurnOnArray == nil){
        self.lightTurnOnArray = [NSMutableArray array];
    }
    return _lightTurnOnArray;
}

- (NSMutableArray *)lightTurnOffArray{
    if (_lightTurnOffArray == nil){
        self.lightTurnOffArray = [NSMutableArray array];
    }
    return _lightTurnOffArray;
}

- (NSMutableDictionary *)lightColorPercentDic{
    if (_lightColorPercentDic == nil){
        self.lightColorPercentDic = [NSMutableDictionary dictionary];
    }
    return _lightColorPercentDic;
}

@end
