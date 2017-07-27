//
//  DeviceGroupViewController.m
//  InledcoPlant
//
//  Created by huang zhengguo on 2017/2/6.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

#import "DeviceGroupViewController.h"
#import "GroupListTableViewCell.h"
#import "GroupDeviceTableViewCell.h"
#import "DeviceGroupModel.h"

@interface DeviceGroupViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIView *leftBackgroundView;

@property (weak, nonatomic) IBOutlet UIView *rightBackgroundView;

@property (weak, nonatomic) IBOutlet UIButton *addGroupButton;

@property (weak, nonatomic) IBOutlet UIButton *displayAllButton;

@property (weak, nonatomic) IBOutlet UITableView *leftTableView;

@property (weak, nonatomic) IBOutlet UITableView *rightTableView;

@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

// 分组列表数据源
@property (nonatomic, strong) NSMutableArray *groupDataArray;

// 设备列表数据源
@property (nonatomic, strong) NSMutableArray *deviceDataArray;

@end

@implementation DeviceGroupViewController

- (NSMutableArray *)groupDataArray{
    if (_groupDataArray == nil){
        self.groupDataArray = [NSMutableArray array];
    }
    return _groupDataArray;
}

- (NSMutableArray *)deviceDataArray{
    if (_deviceDataArray == nil){
        self.deviceDataArray = [NSMutableArray array];
    }
    return _deviceDataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // 设置talbeview
    [self setTableviewWithSetting];
    
    // 初始化数据源
    [self prepareData];
    
    // 设置视图
    [self setViews];
}

- (void)setTableviewWithSetting{
    self.leftTableView.delegate = self;
    self.leftTableView.dataSource = self;
    self.leftTableView.backgroundColor = [UIColor clearColor];
    [self.leftTableView registerNib:[UINib nibWithNibName:@"GroupListTableViewCell" bundle:nil] forCellReuseIdentifier:@"GroupListTableViewCell"];
    
    self.rightTableView.delegate = self;
    self.rightTableView.dataSource = self;
    [self.rightTableView registerNib:[UINib nibWithNibName:@"GroupDeviceTableViewCell" bundle:nil] forCellReuseIdentifier:@"GroupDeviceTableViewCell"];
    self.rightTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

#pragma mark --- 数据初始化
- (void)prepareData{
    // 默认显示所有的分组及所有设备
    self.groupDataArray = [self.databaseManager findDataFromTableWithTableName:DEVICE_GROUP_TABLE groupName:nil];
    
    self.deviceDataArray = [self.databaseManager findDataFromTableWithTableName:DEVICE_TABLE groupName:nil];
    
    [self.leftTableView reloadData];
}

- (void)setViews{
    self.leftBackgroundView.layer.cornerRadius = 5;
    self.leftBackgroundView.backgroundColor = [UIColor colorWithRed:(151.0 / 255.0) green:(174.0 / 255.0) blue:(124.0 / 255.0) alpha:1];
    
    self.addGroupButton.layer.cornerRadius = self.addGroupButton.frame.size.height / 2;
}

#pragma mark --- 添加分组
- (IBAction)addGroupAction:(UIButton *)sender {
    __block EditAlertView *editAlertView = [[EditAlertView alloc] initWithTitle:@"Add Group"];
    
    editAlertView.confirmBlock = ^NSString *(NSString *saveText){
        
        // 去掉字符串尾部的空格和尾部的换行符
        saveText = [saveText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        // 名称不能为空
        if (saveText == nil || saveText.length == 0){
            
            // 提示名称不能为空
            return @"Group name should not null!";
        }

        // 是否已经存在该组名
        NSArray *existGroupArray = [self.databaseManager findDataFromTableWithTableName:DEVICE_GROUP_TABLE groupName:saveText];
        if (existGroupArray.count > 0){
            // 存在则返回
            return @"Group name has existed!";
        }
        
        // 创建Group模型并保存到数据源和数据库中
        DeviceGroupModel *groupModel = [[DeviceGroupModel alloc] init];
        groupModel.groupName = saveText;
        
        // 同步到数据库
        NSDictionary *groupDic = @{DEVICE_GROUP_NAME:saveText};
        [self.databaseManager insertIntoTableWithTableName:DEVICE_GROUP_TABLE columnDic:groupDic];
        
        // 刷新视图
        [self prepareData];
        
        return nil;
    };
    
    [self.view addSubview:editAlertView];
}

// 显示所有设备
- (IBAction)displayAllDeviceAction:(UIButton *)sender {
    // 刷新数据
    [self prepareData];
}

// 删除某一分组
- (IBAction)deleteGroupAction:(UIButton *)sender {
}

#pragma mark --- 代理方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (tableView == self.leftTableView){
        return self.groupDataArray.count;
    }
    return self.deviceDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.leftTableView){
        GroupListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GroupListTableViewCell" forIndexPath:indexPath];
        
        if (self.groupDataArray.count > 0){
            DeviceGroupModel *groupModel = [self.groupDataArray objectAtIndex:indexPath.row];
            // cell model赋值
            cell.groupModel = groupModel;
        }

        // 设置cell透明度
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        
        // 编辑分组block回调赋值
        cell.editGroup = ^(BOOL isSelected){
            // 根据数据源的状态进行判断是显示所有的设备还是进入设备编辑状态
            if (isSelected == YES){
                // 显示所有的设备
                self.deviceDataArray = [self.databaseManager findDataFromTableWithTableName:DEVICE_TABLE groupName:nil];
                [self.rightTableView reloadData];
            }
        };
        
        return cell;
    }else{
        
        GroupDeviceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GroupDeviceTableViewCell" forIndexPath:indexPath];

        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView == self.leftTableView){
        // 只响应点击左边分组信息点击事件:获取对应分组内的所有设备
        DeviceGroupModel *deviceGroupModel = [self.groupDataArray objectAtIndex:indexPath.row];
        
        // 查询对应group的设备
        self.deviceDataArray = [self.databaseManager findDataFromTableWithTableName:DEVICE_TABLE groupName:deviceGroupModel.groupName];
        
        [self.rightTableView reloadData];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView == self.leftTableView){
        
        return 44.0f;
    }
    
    return 139.0f;
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
