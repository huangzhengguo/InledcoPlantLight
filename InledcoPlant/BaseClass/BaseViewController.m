//
//  BaseViewController.m
//  InledcoPlant
//
//  Created by huang zhengguo on 2017/1/18.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 设置导航栏背景颜色及标题颜色
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:117.0f / 255.0f green:172.0f / 255.0f blue:62.0f / 255.0f alpha:1];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    // 初始化数据库管理对象
    self.databaseManager = [DatabaseManager defaultDatabaseManager];
    
    // 初始化蓝牙操作对象
    self.blueToothManager = [BlueToothManager defaultBlueToothManager];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
