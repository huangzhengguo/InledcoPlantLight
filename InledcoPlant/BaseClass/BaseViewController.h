//
//  BaseViewController.h
//  InledcoPlant
//
//  Created by huang zhengguo on 2017/1/18.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FGLanguageTool.h"
#import "BlueToothManager.h"

@interface BaseViewController : UIViewController

// 数据库操作对象
@property(nonatomic,strong) DatabaseManager *databaseManager;

// 蓝牙操作对象
@property(nonatomic, strong) BlueToothManager *blueToothManager;

@end
