//
//  DeviceViewController.m
//  InledcoPlant
//
//  Created by huang zhengguo on 2017/1/18.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

#import "DeviceViewController.h"
#import "BlueToothManager.h"
#import "FGLanguageTool.h"
#import "ScanViewController.h"
#import "DeviceTableViewHeaderView.h"
#import "ColorDimmingTableViewCell.h"
#import "CycleSetViewController.h"
#import "DeviceGroupViewController.h"
#import "DeviceModel.h"
#import "LGSideMenuController.h"
#import "UIViewController+LGSideMenuController.h"
#import "ManualDimmingView.h"
#import "ECOPlantParameterModel.h"
#import "DeviceDataType.h"

// cell类型枚举
typedef NS_ENUM(NSInteger, CellType) {
    ManualDimmingCell,
    DeviceInfoCell
};

@interface DeviceViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic, strong) LGSideMenuController *sideMenuController;

@property (weak, nonatomic) IBOutlet UITableView *tableview;

// 设备数据源
@property (nonatomic, strong) NSMutableArray *deviceDataArray;

// 区头视图数据源
@property (nonatomic, strong) NSMutableArray *headerViewArray;

// 由于该界面显示的是某一个分组的设备，所以需要一个变量记录当前组
@property (nonatomic, strong) NSString *currentGroupName;

// 记录展开索引
@property(nonatomic, assign) NSInteger selectIndex;

// 标记点击的是手动调试还是查看设备信息的按钮
@property(nonatomic, assign) CellType cellType;

// 设备参数模型
@property(nonatomic, strong) ECOPlantParameterModel *deviceParameterModel;

// 连接提示框
@property(nonatomic, strong) UIAlertController *connectingAlertController;

// 连接成功或失败提示框
@property(nonatomic, strong) UIAlertController *connectSuccessFailedAlertController;

// 连接设备提示框定时器
@property(nonatomic, strong) NSTimer *timer;

// 当前连接设备的uustring
@property(nonatomic, copy) NSString *deviceUUIDString;

// 连接设备的headerview
@property(nonatomic, strong) UIView *currentHeaderView;

// 连接成功后接收到的数据
@property(nonatomic, copy) NSString *receiveDataStr;

@end

@implementation DeviceViewController

// 懒加载
- (NSMutableArray *)headerViewArray{
    if (_headerViewArray == nil){
        self.headerViewArray = [NSMutableArray array];
    }
    return _headerViewArray;
}

// 设备数据源
- (NSMutableArray *)deviceDataArray{
    if(_deviceDataArray == nil){
        self.deviceDataArray = [NSMutableArray array];
    }
    return _deviceDataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 初始化当前分组
    self.currentGroupName = nil;
    
    // 设置TableView
    [self setTableviewWithSetting];
    
    // 初始化数据
    [self prepareData];
    
    // 设置视图相关的初始化
    [self setViews];
    
    // 设置侧边弹出菜单
    [self setSliderMenu];
}

#pragma mark --- 刷新数据
- (void)viewWillAppear:(BOOL)animated{
    // 视图将要出现的时候刷新数据
    [self prepareData];
}

#pragma mark --- 设置侧边弹出菜单
- (void)setSliderMenu{
//    UITableViewController *leftViewController = [UITableViewController new];
//    UITableViewController *rightViewController = [UITableViewController new];
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self];
//    
//    leftViewController.view.backgroundColor = [UIColor redColor];
//    rightViewController.view.backgroundColor = [UIColor greenColor];
//    
//    self.sideMenuController = [[LGSideMenuController alloc] initWithRootViewController:nav];
//    self.sideMenuController.leftViewController = leftViewController;
//    self.sideMenuController.rightViewController = rightViewController;
//    self.sideMenuController.view.backgroundColor = [UIColor blueColor];
//    
//    self.sideMenuController.leftViewWidth = 250.0;
//    self.sideMenuController.leftViewPresentationStyle = LGSideMenuPresentationStyleScaleFromBig;
//    
//    self.sideMenuController.rightViewWidth = 100.0;
//    self.sideMenuController.leftViewPresentationStyle = LGSideMenuPresentationStyleSlideBelow;
//    
//    UIWindow *window = [UIApplication sharedApplication].delegate.window;
//    
//    window.rootViewController = self.sideMenuController;
}

#pragma mark --- 数据初始化
- (void)prepareData{
    // 初始化设备参数
    self.deviceParameterModel = [[ECOPlantParameterModel alloc] init];
    // 从数据库读取数据
    self.deviceDataArray = [self.databaseManager findDataFromTableWithTableName:DEVICE_TABLE groupName:self.currentGroupName];
    
    // 创建区头视图
    [self createHeaderView];
    
    [self.tableview reloadData];
}

#pragma mark --- 创建区头视图
- (void)createHeaderView{
    // 由于有可能会重新刷新界面，需要清除原来数据
    [self.headerViewArray removeAllObjects];
    
    // 区头是根据数据源个数创建的，使用时不存在重用问题
    for(int i=0;i<self.deviceDataArray.count;i++){
        // 根据数据源的个数自定义区头:不能够在代理方法中调用alloc内存分配的方法，会造成内存泄漏，因为代理方法会重复执行
        DeviceTableViewHeaderView *headerView = [[DeviceTableViewHeaderView alloc] init];
        DeviceModel *deviceModel = [self.deviceDataArray objectAtIndex:i];
        
        // 如果是当前正在连接的设备，则设置可用
        if ([self.deviceUUIDString isEqualToString:deviceModel.UUIDString]){
            [self setSettingButtonEnable:YES headerView:headerView];
        }
        
        __weak typeof(self) weakself = self;
        headerView.lightNameLabel.text = deviceModel.deviceName;
        headerView.lockButtonAction = ^(NSInteger buttonTag, BOOL selected,UIView *headerView){
            // 只有在点击的时候才能对蓝牙管理对象进行设置
            self.blueToothManager.completeReceiveDataBlock = ^(NSString *receiveData) {
                weakself.currentHeaderView = headerView;
                weakself.deviceUUIDString = deviceModel.UUIDString;
                // 赋值设备编码
                weakself.deviceParameterModel.channelNum = [[[DeviceDataType defaultDeviceDataType].diviceCodeChannelNumDic objectForKey:deviceModel.deviceTypeCode] integerValue];
                weakself.deviceParameterModel.deviceTypeCode = deviceModel.deviceTypeCode;
                weakself.deviceParameterModel.UUIDString = deviceModel.UUIDString;
                // 保存接收到的数据
                weakself.receiveDataStr = receiveData;
                
                // 连接成功，设置按钮可用
                [weakself setSettingButtonEnable:YES headerView:headerView];
                
                // 取消连接提示
                [weakself removeConnectToDeviceAlertController];
                
                // 弹出连接成功的提示
                [weakself presentConnectDeviceSuccessOrFailedAlertController:YES titile:@""];
                
                // 设置锁定标题
                UILabel *lockTitle = [headerView viewWithTag:1006];
                
                lockTitle.text = FGGetStringWithKey(@"lockButtonTitle");
            };
            
            // 连接失败回调
            self.blueToothManager.connectDeviceFailedBlock = ^{
                // 取消连接提示
                [weakself removeConnectToDeviceAlertController];
                // 弹出连接失败的提示
                [weakself presentConnectDeviceSuccessOrFailedAlertController:NO titile:@""];
            };
            
            // 断开设备回调
            self.blueToothManager.disConnectDeviceBlock = ^{
                // 断开连接，设置按钮不可用
                if (weakself.currentHeaderView != nil){
                   [weakself setSettingButtonEnable:NO headerView:weakself.currentHeaderView];
                }
                
                // 设置锁定标题
                UILabel *lockTitle = [headerView viewWithTag:1006];
                
                lockTitle.text = FGGetStringWithKey(@"unlockButtonTitle");
            };
            
            if (selected == YES){
                // 断开已经连接的设备
                if (weakself.deviceUUIDString != nil){
                    [weakself.blueToothManager disConnectToDeviceWithUUID:weakself.deviceUUIDString];
                }
                // 开始连接设备
                [self.blueToothManager connectToDeviceWithUUID:deviceModel.UUIDString];
                
                // 在主界面弹出正在连接提示框
                [self presentConnectToDeviceAlertController];
            }else{
                [self.blueToothManager disConnectToDeviceWithUUID:deviceModel.UUIDString];
            }
        };
        
        [self.headerViewArray addObject:headerView];
    }
    
    // 初始化索引，设置为数据源数据的个数，默认所有都没有展开
    self.selectIndex = self.headerViewArray.count;
}

// 弹出正在连接设备
- (void)presentConnectToDeviceAlertController{
    [self presentViewController:self.connectingAlertController animated:YES completion:nil];
}

// 去除正在连接提示框
- (void)removeConnectToDeviceAlertController{
    [self.connectingAlertController dismissViewControllerAnimated:YES completion:nil];
}

// 弹出连接成功或者失败的提示
- (void)presentConnectDeviceSuccessOrFailedAlertController:(BOOL)connect titile:(NSString *)title{
    if (connect == YES){
        self.connectSuccessFailedAlertController.title = FGGetStringWithKey(@"connectSuccess");
    }else{
        self.connectSuccessFailedAlertController.title = FGGetStringWithKey(@"connectFailed");
    }
    
    // 显示一段时间，后自动消失
    self.timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(timerAction:) userInfo:nil repeats:NO];
    
    // 显示连接成功或失败信息
    [self presentViewController:self.connectSuccessFailedAlertController animated:YES completion:nil];
}

- (void)timerAction:(NSTimer *)timer{
    [self.connectSuccessFailedAlertController dismissViewControllerAnimated:YES completion:nil];
}

// 根据是连接设备还是断开设备，设置所有按钮的可用性
- (void)setSettingButtonEnable:(BOOL)enable headerView:(UIView *)headerView{
    // 设置所有按钮可用
    for (int i=0; i<5; i++) {
        UIButton *button = [headerView viewWithTag:(1000 + i)];
        // 对于锁定按钮，使用选择属性，对于其它按钮，使用使能属性
        if (i == 0){
            [button setSelected:!enable];
        }else{
            [button setEnabled:enable];
        }
    }
}

#pragma mark --- tableview初始化
- (void)setTableviewWithSetting{
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    [self.tableview registerNib:[UINib nibWithNibName:@"DeviceTableViewCell" bundle:nil] forCellReuseIdentifier:@"DeviceTableViewCell"];
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
}

#pragma mark --- 初始化视图
- (void)setViews{
    // 根据用户当前语言设置设置标题
    self.title = FGGetStringWithKey(@"DeviceTitle");
    
    // 设置导航栏左按钮：分组图标
    UIImage *image = [UIImage imageNamed:@"group.png"];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(setGroup:)];
    
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    
    self.connectingAlertController = [UIAlertController alertControllerWithTitle:FGGetStringWithKey(@"connectDecive") message:FGGetStringWithKey(@"connecting") preferredStyle:UIAlertControllerStyleAlert];
    
    self.connectSuccessFailedAlertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
}

- (void)setGroup:(UIBarButtonItem *)item{
    // 弹出左侧菜单栏
    [self.sideMenuController showLeftViewAnimated:YES completionHandler:nil];
}

#pragma mark --- 添加设备
- (IBAction)addDeviceAction:(UIBarButtonItem *)sender {
    // 扫描设备
    ScanViewController *scanViewController = [[ScanViewController alloc] init];
    
    [self.navigationController pushViewController:scanViewController animated:YES];
}

#pragma mark --- tableview代理方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return self.deviceDataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    // 根据点击的第几个区间的区头的信息，获取到相应的数据模型，加载展开数据
    if (section == self.selectIndex){
        return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    // 区别对待不同的cell
    switch (self.cellType) {
        case ManualDimmingCell:
        {
            ColorDimmingTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"ColorDimmingTableViewCell"];
            if (cell == nil){
                cell = [[ColorDimmingTableViewCell alloc] initWithChannelNum:self.deviceParameterModel.channelNum];
            }
            
            // 发送调光命令
            cell.passColorValueBlock = ^(NSInteger tag, float colorValue) {
                [self.blueToothManager sendCommandWithUUID:self.deviceParameterModel.UUIDString interval:50 channelNum:self.deviceParameterModel.channelNum colorIndex:(tag-1000) colorValue:colorValue];
            };
            
            // 设置cell不能被选择
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            return cell;
        }
            break;
            
        default:
        {
            ColorDimmingTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"ColorDimmingTableViewCell"];
            if (cell == nil){
                cell = [[ColorDimmingTableViewCell alloc] init];
            }
            
            // 发送调光命令
            cell.passColorValueBlock = ^(NSInteger tag, float colorValue) {
                [self.blueToothManager sendCommandWithUUID:self.deviceParameterModel.UUIDString interval:50 channelNum:self.deviceParameterModel.channelNum colorIndex:(tag-1000) colorValue:colorValue];
            };
            // 设置cell不能被选择
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            // 这里对cell赋值
            
            return cell;
        }
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 500.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 168.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    // 获取对应的区头
    DeviceTableViewHeaderView *headerView = [self.headerViewArray objectAtIndex:section];
    // 获取对应设备模型
    DeviceModel *deviceModel = [self.deviceDataArray objectAtIndex:section];
    
    headerView.buttonPasstag = ^(NSInteger tag,BOOL selected,UIView *headerView){
        // 获取按钮
        UIButton *button = [headerView viewWithTag:tag];
        if (tag == 1004){
            // 获取点击的区域
            self.selectIndex = section;
            self.cellType = ManualDimmingCell;
        }else if (tag == 1002){
            // 跳转到定时设置界面：这里是连接成功之后才调用的
            CycleSetViewController *cycleSetViewController = [[CycleSetViewController alloc] init];
            cycleSetViewController.deviceParameterModel = self.deviceParameterModel;
            
            self.currentHeaderView = headerView;
            self.deviceUUIDString = deviceModel.UUIDString;
            // 赋值设备编码
            self.deviceParameterModel.channelNum = [[[DeviceDataType defaultDeviceDataType].diviceCodeChannelNumDic objectForKey:deviceModel.deviceTypeCode] integerValue];
            self.deviceParameterModel.deviceTypeCode = deviceModel.deviceTypeCode;
            self.deviceParameterModel.UUIDString = deviceModel.UUIDString;
            
            [self.blueToothManager parseECOPlantDataFromReceiveData:self.receiveDataStr deviceInfoModel:self.deviceParameterModel];
            
            [self.navigationController pushViewController:cycleSetViewController animated:YES];
        }else if (tag == 1000){
            // 如果是点击的是锁定按钮，折叠展开的cell
            self.selectIndex = 10;
        }else if (tag == 1001){
            // 修改名称
            EditAlertView *editAlertView = [[EditAlertView alloc] initWithTitle:FGGetStringWithKey(@"RenameButtonTitle")];
        
            editAlertView.confirmBlock = ^NSString *(NSString *saveText){
                deviceModel.deviceName = saveText;
        
                // 保存到数据库
                [self.databaseManager updateDataWithTableName:DEVICE_TABLE colName:DEVICE_NAME conditionColName:DEVICE_UUID conditionCol:deviceModel.UUIDString data:saveText];
        
                // 刷新数据
                [self prepareData];
                
                // 成功返回nil
                return nil;
            };
            
            [self.view addSubview:editAlertView];
        }else if (tag == 1003){
            // 打开或者关闭灯光，还要改变开关按钮的选择状态
            if (button.selected == YES){
                [self.blueToothManager sendPowerOnCommand:deviceModel.UUIDString];
            }else{
                [self.blueToothManager sendPowerOffCommand:deviceModel.UUIDString];
            }
            
            [button setSelected:!button.selected];
        }else if (tag == 1005){
            // 点击查看设备信息按钮
            self.cellType = DeviceInfoCell;
        }
        [tableView reloadData];
    };
    
    return headerView;
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
