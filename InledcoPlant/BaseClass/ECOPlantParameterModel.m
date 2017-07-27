//
//  ECOPlantParameterModel.m
//  InledcoPlant
//
//  Created by huang zhengguo on 2017/5/31.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

#import "ECOPlantParameterModel.h"

@implementation ECOPlantParameterModel

// 懒加载部分
- (NSMutableDictionary *)cycleDataDic{
    if (_cycleDataDic == nil){
        self.cycleDataDic = [NSMutableDictionary dictionary];
    }
    
    return _cycleDataDic;
}

@end
