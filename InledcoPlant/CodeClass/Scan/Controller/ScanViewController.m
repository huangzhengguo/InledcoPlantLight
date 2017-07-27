//
//  ScanViewController.m
//  InledcoPlant
//
//  Created by huang zhengguo on 2017/2/3.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

#import "ScanViewController.h"
#import "DeviceScanCell.h"

@interface ScanViewController () <UITableViewDelegate, UITableViewDataSource>

// 表视图
@property(nonatomic, strong) UITableView *tableView;

// 设备数据源
@property(nonatomic, strong) NSMutableArray *scanDeviceArray;

// 旋转图及扫描按钮
@property(nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property(nonatomic, strong) UIBarButtonItem *scanBarButtonItem;

// 保存按钮
@property(nonatomic, strong) UIButton *saveButton;

@end

@implementation ScanViewController

- (NSMutableArray *)scanDeviceArray{
    if(_scanDeviceArray == nil){
        self.scanDeviceArray = [NSMutableArray array];
    }
    
    return _scanDeviceArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // 设置界面布局
    [self setViews];
    [self setConstraints];
    
    __weak typeof(self) weakself = self;
    self.blueToothManager.scanDeviceBlock = ^(NSArray *deviceModelArray){
        // 赋值数据源
        weakself.scanDeviceArray = [deviceModelArray mutableCopy];
        // 刷新设备列表
        [weakself.tableView reloadData];
    };
    
    self.blueToothManager.stopScanDeviceBlock = ^{
        [weakself.activityIndicatorView stopAnimating];
        weakself.scanBarButtonItem.title = FGGetStringWithKey(@"Scan");
    };
    
    // 开始扫描
    [self startScanAction];
}

- (void)setViews{
    _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    UIBarButtonItem *actitityBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_activityIndicatorView];
    _scanBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:FGGetStringWithKey(@"Scan") style:UIBarButtonItemStylePlain target:self action:@selector(startScanAction)];
    [self.navigationItem setRightBarButtonItems:@[_scanBarButtonItem, actitityBarButtonItem]];
    
    _saveButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [_saveButton setBackgroundImage:[UIImage imageNamed:@"save.png"] forState:UIControlStateNormal];
    _saveButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_saveButton addTarget:self action:@selector(saveAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    // 代码编写约束
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:_tableView];
    [self.view addSubview:_saveButton];
}

- (void)setConstraints{
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0f constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0f constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0f constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_saveButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_saveButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-50]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_saveButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:50]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_saveButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:50]];
}

#pragma mark --- tableView代理方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.scanDeviceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DeviceScanCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DeviceScanCell"];
    if (cell == nil){
        cell = [[DeviceScanCell alloc] init];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    DeviceModel *deviceModel = [self.scanDeviceArray objectAtIndex:indexPath.row];
    cell.buttonClickBlock = ^(BOOL isSelected){
        deviceModel.isSelected = isSelected;
    };
    [cell SetCellModelWithIcon:@"LED.png" mainTitle:deviceModel.deviceName subTitle:deviceModel.deviceTypeCode selectedFlag:deviceModel.isSelected];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80.0f;
}

- (void)startScanAction{
    if ([_scanBarButtonItem.title isEqualToString:FGGetStringWithKey(@"Scan")]){
        _scanBarButtonItem.title = FGGetStringWithKey(@"Stop");
        [_activityIndicatorView startAnimating];
        [self.blueToothManager StartScanWithTime:5];
    }else{
        [self.blueToothManager StopScan];
    }
}

- (void)saveAction:(UIButton *)sender{
    for (DeviceModel *deviceModel in _scanDeviceArray) {
        if(deviceModel.isSelected == YES){
            // 设置是否选择为否
            deviceModel.isSelected = NO;
            // 保存到数据库
            NSDictionary *deviceDic = @{DEVICE_GROUPNAME:deviceModel.deviceGroupName,
                                        DEVICE_NAME:deviceModel.deviceName,
                                        DEVICE_TYPECODE:deviceModel.deviceTypeCode,
                                        DEVICE_UUID:deviceModel.UUIDString};
            [self.databaseManager insertIntoTableWithTableName:DEVICE_TABLE columnDic:deviceDic];
        }
    }
    
    // 返回设备列表界面
    [self.navigationController popViewControllerAnimated:YES];
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
