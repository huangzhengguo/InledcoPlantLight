//
//  CycleSetViewController.m
//  InledcoPlant
//
//  Created by huang zhengguo on 2017/2/3.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

#import "CycleSetViewController.h"
#import "FGLanguageTool.h"
#import "StringRelatedManager.h"
#import "CycleSettingModel.h"
#import "ManualDimmingView.h"

@interface CycleSetViewController ()<UIPickerViewDelegate,UIPickerViewDataSource>

// 名称
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
// 开始日期标签
@property (weak, nonatomic) IBOutlet UILabel *startDateLabel;
// 周期天数标签
@property (weak, nonatomic) IBOutlet UILabel *cycleLengthLabel;
// 开关灯类型标签
@property (weak, nonatomic) IBOutlet UILabel *rampTypeLabel;
// 打开标签
@property (weak, nonatomic) IBOutlet UILabel *turnOnLabel;
// 关闭标签
@property (weak, nonatomic) IBOutlet UILabel *turnOffLabel;
// 用来放调光界面
@property (weak, nonatomic) IBOutlet UIView *colorSettingView;
// 周期时长
@property (weak, nonatomic) IBOutlet UITextField *cycleLengthTextField;
// 开关灯类型
@property (weak, nonatomic) IBOutlet UIPickerView *rampTypePickerView;
@property (weak, nonatomic) IBOutlet UIDatePicker *turnOnDatePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *turnOffDatePicker;
// 开始日期选择器
@property (weak, nonatomic) IBOutlet UIDatePicker *startDatePicker;
// 灯管关闭灯光的类型
@property(nonatomic, strong) NSArray *rampTypeArray;

// 周期设置模型
@property(nonatomic, strong) CycleSettingModel *cycleSettingModel;

// 滑动调光界面
@property(nonatomic, strong) ManualDimmingView *manualDimmingView;

// 周期模式总开关
@property(nonatomic, strong) UISwitch *cycleModeEnableSwitch;

// 周期菜单视图
@property (weak, nonatomic) IBOutlet UIView *cycleMenuView;

// 可以滑动的菜单
@property (nonatomic, strong) UIScrollView *menuScrollView;

// 增加周期的按钮
@property (nonatomic, strong) UIButton *addCycleButton;

// 临时周期个数
@property (nonatomic, assign) NSInteger cycleCount;

// 上次选择的周期按钮
@property (nonatomic, strong) UIButton *lastCycleButton;

// 删除指定周期按钮
@property (weak, nonatomic) IBOutlet UIButton *deleteCycleButton;

// 当前周期索引
@property (nonatomic, assign) NSInteger currentCycleIndex;

// 日期格式对象
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

// 界面是否已经加载完毕
@property (nonatomic, assign) BOOL isViewDidLoad;

@end

@implementation CycleSetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.rampTypeArray = @[FGGetStringWithKey(@"immediately"),FGGetStringWithKey(@"quickly"),FGGetStringWithKey(@"normally"),FGGetStringWithKey(@"slowly")];
    
    // 初始化界面是否已经加载完毕
    self.isViewDidLoad = NO;
    
    // 全局日期格式对象
    self.dateFormatter = [[NSDateFormatter alloc] init];
    
    // 打开关闭灯光类型
    self.rampTypePickerView.delegate = self;
    self.rampTypePickerView.dataSource = self;
    
    [self.rampTypePickerView reloadAllComponents];
    
    // 初始化临时周期个数
    self.cycleCount = self.deviceParameterModel.cycleCount;
    
    // 初始化当前周期索引
    self.currentCycleIndex = 0;
    
    // 解析数据
    [self parseCycleModel:self.deviceParameterModel];
    
    // 设置导航栏
    [self setNavigationBar];
    
    // 设置界面布局
    [self setViews];
    
    // 初始化界面
    [self updateCycleViewWithCycleIndex:0];
    
    // 设置蓝牙管理对象
    __weak typeof(self) weakself = self;
    self.blueToothManager.completeReceiveDataBlock = ^(NSString *receiveData,SendCommandType commandType) {
        // 接收到数据之后，刷新界面
        // 重新解析数据
        [weakself.blueToothManager parseECOPlantDataFromReceiveData:receiveData deviceInfoModel:weakself.deviceParameterModel];
        
        // 重新设置周期数
        weakself.cycleCount = weakself.deviceParameterModel.cycleCount;
        
        // 初始化当前周期索引
        weakself.currentCycleIndex = 0;
        
        // 重新解析模型
        [weakself parseCycleModel:weakself.deviceParameterModel];
        
        // 重新设置视图
        [weakself setViews];
        [weakself updateCycleViewWithCycleIndex:0];
    };
}

#pragma mark --- 只有在这里初始化才能获取到通过约束布局的控件的真正的大小
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    // 初始化滑动调光界面
    [self addColorDimmingViewWithCycleIndex:0];
    
    self.isViewDidLoad = YES;
}

// 设置导航栏
- (void)setNavigationBar{
    // 设置保存配置按钮
    UIBarButtonItem *saveBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveConfiguration:)];
    self.cycleModeEnableSwitch = [[UISwitch alloc] init];
    UIBarButtonItem *enableCycleButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.cycleModeEnableSwitch];
    [self.cycleModeEnableSwitch addTarget:self action:@selector(cycleModeEnableSwitchAction:) forControlEvents:UIControlEventValueChanged];
    
    // 设置周期模式是否开启
    if (self.cycleSettingModel.isOpenCycleMode == YES){
        self.cycleModeEnableSwitch.on = YES;
    }else{
        self.cycleModeEnableSwitch.on = NO;
    }
    
    self.navigationItem.rightBarButtonItems = @[saveBarButtonItem,enableCycleButtonItem];
}

// 设置界面
- (void)setViews{
    // 设置周期菜单背景色为蓝色
    self.cycleMenuView.backgroundColor = [UIColor blueColor];
    
    // 添加滑动菜单和增加周期按钮
    self.addCycleButton = [[UIButton alloc] initWithFrame:CGRectMake(KWIDTH - 28.0, 0, 28, 28)];
    [self.addCycleButton setImage:[UIImage imageNamed:@"add.png"] forState:UIControlStateNormal];
    [self.addCycleButton addTarget:self action:@selector(addCycleAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.cycleMenuView addSubview:self.addCycleButton];
    
    // 添加滑动菜单
    self.menuScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, KWIDTH-28, 28)];
    [self.menuScrollView setShowsHorizontalScrollIndicator:NO];
    self.menuScrollView.scrollEnabled = YES;
    [self.cycleMenuView addSubview:self.menuScrollView];
    
    // 创建周期选择菜单
    [self createCycleMenuView];
    
    self.startDateLabel.text = [NSString stringWithFormat:@"%@",FGGetStringWithKey(@"startdatetitle")];
}

#pragma mark --- 创建周期菜单
- (void)createCycleMenuView{
    for (UIView *menuButton in self.menuScrollView.subviews) {
        if ([menuButton isKindOfClass:[UIButton class]]){
            [menuButton removeFromSuperview];
        }
    }
    // 根据周期个数设置菜单个数
    // 设置内容视图宽度
    [self.menuScrollView setContentSize:CGSizeMake(self.cycleCount * KWIDTH / 4.0f, 28)];
    for (int i=0; i<self.cycleCount; i++) {
        UIButton *titleButton = [[UIButton alloc] initWithFrame:CGRectMake(i * 100, 0, 100, 28)];
        
        if (i == 0){
            [titleButton setSelected:YES];
            self.lastCycleButton = titleButton;
        }
        [titleButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [titleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [titleButton setTitle:[NSString stringWithFormat:@"Cycle-%@",@(i+1)] forState:UIControlStateNormal];
        titleButton.tag = 1000 + i;
        [titleButton addTarget:self action:@selector(cycleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.menuScrollView addSubview:titleButton];
    }
}

#pragma mark --- 更新周期界面
- (void)updateCycleViewWithCycleIndex:(NSInteger)cycleIndex{
    // 设置周期开始日期：第一个周期之后的每个周期
    NSDate *date = self.cycleSettingModel.cycleStartDate;
    for (int i=0; i<cycleIndex; i++) {
        date = [date dateByAddingTimeInterval:[[self.cycleSettingModel.cycleLengthsArray objectAtIndex:i] integerValue] * 24 * 60 * 60];
    }
    self.startDatePicker.date = date;
    
    // 设置周期时长
    self.cycleLengthTextField.text = [NSString stringWithFormat:@"%@",@([[self.cycleSettingModel.cycleLengthsArray objectAtIndex:cycleIndex] integerValue])];
    
    // 设置打开关闭灯光的类型
    [self.rampTypePickerView selectRow:[[self.cycleSettingModel.cycleRampTypeArray objectAtIndex:cycleIndex] integerValue] inComponent:0 animated:NO];
    
    // 设置周期内打开和关闭时间
    self.dateFormatter.dateFormat = @"HH:mm";
    self.turnOnDatePicker.date = [self.dateFormatter dateFromString:[self.cycleSettingModel.lightTurnOnArray objectAtIndex:cycleIndex]];
    self.turnOffDatePicker.date = [self.dateFormatter dateFromString:[self.cycleSettingModel.lightTurnOffArray objectAtIndex:cycleIndex]];
    
    // 更新调光界面
    if (self.isViewDidLoad == YES){
       [self addColorDimmingViewWithCycleIndex:cycleIndex];
    }
    
    // 如果选择的不是第一个周期，设置周期开始日期不可用
    if (self.currentCycleIndex != 0){
        self.startDatePicker.enabled = NO;
        self.deleteCycleButton.enabled = YES;
    }else{
        self.startDatePicker.enabled = YES;
        self.deleteCycleButton.enabled = NO;
    }
}

#pragma mark --- 增加周期方法
- (void)addCycleAction:(UIButton *)sender{
    if (self.cycleCount >= 8){
        // 弹出提示框
        UIAlertController *maxCycleCountAlert = [UIAlertController alertControllerWithTitle:FGGetStringWithKey(@"maxCycleCount") message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:FGGetStringWithKey(@"confirm") style:UIAlertActionStyleDefault handler:nil];
        
        [maxCycleCountAlert addAction:confirmAction];
        
        [self presentViewController:maxCycleCountAlert animated:YES completion:nil];
        return;
    }
    // 设置临时周期个数增加1
    self.cycleCount = self.cycleCount + 1;
    UIButton *titleButton = [[UIButton alloc] initWithFrame:CGRectMake((self.cycleCount-1)*100, 0, 100, 28)];
    [titleButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [titleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [titleButton setTitle:[NSString stringWithFormat:@"Cycle-%@",@(self.cycleCount)] forState:UIControlStateNormal];
    
    // 这个tag值应该是最后一个标签值加上1
    titleButton.tag = self.cycleCount - 1 + 1000;
    [titleButton addTarget:self action:@selector(cycleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.menuScrollView setContentSize:CGSizeMake(self.cycleCount * 100, 28)];
    [self.menuScrollView addSubview:titleButton];
    
    // 菜单滚动到当前位置
    if ((self.cycleCount)*100 > (KWIDTH-28)){
        [self.menuScrollView setContentOffset:CGPointMake((self.cycleCount)*100 - KWIDTH + 28, 0) animated:YES];
    }
    
    // 新增周期数据，并且填充当前周期界面
    self.dateFormatter.dateFormat = @"HH:mm";
    
    // 周期默认长度10天
    [self.cycleSettingModel.cycleLengthsArray addObject:@(10)];
    // 默认打开关闭灯光类型
    [self.cycleSettingModel.cycleRampTypeArray addObject:@(0)];
    // 默认打开灯光时间
    [self.cycleSettingModel.lightTurnOnArray addObject:@"06:00"];
    // 默认关闭灯光时间
    [self.cycleSettingModel.lightTurnOffArray addObject:@"18:00"];
    // 增加默认各路颜色设置
    NSMutableArray *colorPercentArray = [NSMutableArray array];
    for (int i=0; i<self.deviceParameterModel.channelNum; i++) {
        // 设置默认值:50%
        [colorPercentArray addObject:@(50)];
    }
    [self.cycleSettingModel.lightColorPercentDic setObject:colorPercentArray forKey:@(self.cycleCount - 1)];
    
    // 刷新界面
    [self updateCycleViewWithCycleIndex:self.currentCycleIndex];
    
    // 选择当前新增的按钮
    [self cycleButtonAction:titleButton];
}

#pragma mark --- 选择周期按钮方法
- (void)cycleButtonAction:(UIButton *)sender{
    KMYLOG(@"当前是第%ld个周期！",sender.tag - 1000);
    
    // 如果上次选择的周期按钮不为空，则设置为不选择
    if (self.lastCycleButton != nil){
        [self.lastCycleButton setSelected:NO];
    }
    
    // 选择当前周期，并且记录上一个点击的按钮
    [sender setSelected:YES];
    self.lastCycleButton = sender;
    
    // 更新当前周期索引
    self.currentCycleIndex = sender.tag - 1000;
    
    // 刷新界面
    [self updateCycleViewWithCycleIndex:self.currentCycleIndex];
}

#pragma mark --- 关闭打开周期模式方法
- (void)cycleModeEnableSwitchAction:(UISwitch *)sender{
    if (sender.on == YES){
        // 打开周期模式
        [self.blueToothManager sendAutoModeCommand:self.deviceParameterModel.UUIDString];
    }else{
        // 关闭周期模式
        [self.blueToothManager sendManualModeCommand:self.deviceParameterModel.UUIDString];
    }
}

#pragma mark --- 保存配置
- (void)saveConfiguration:(UIBarButtonItem *)sender{
    // 保存配置，把设备参数转换成命令，并发送到设备
    NSMutableString *commandStr = [@"6807" mutableCopy];

    // 拼接是否开启周期模式
    if (self.cycleSettingModel.isOpenCycleMode == YES){
        [commandStr appendString:@"01"];
    }else{
        [commandStr appendString:@"00"];
    }
    
    // 生长周期数
    [commandStr appendString:[StringRelatedManager convertToHexStringWithString:[NSString stringWithFormat:@"%ld",self.cycleCount]]];
    
    // 生长周期起始日期
    [commandStr appendString:[StringRelatedManager convertDateToHexString:self.cycleSettingModel.cycleStartDate]];
    
    // 周期设置数据
    for (int i=0; i<self.cycleCount; i++) {
        // 周期长度
        [commandStr appendFormat:@"%02x",[[self.cycleSettingModel.cycleLengthsArray objectAtIndex:i] intValue]];
        
        // 打开灯光时间
        [commandStr appendString:[StringRelatedManager convertDateStrToHexStr:[self.cycleSettingModel.lightTurnOnArray objectAtIndex:i]]];
        
        // 关闭灯光时间
        [commandStr appendString:[StringRelatedManager convertDateStrToHexStr:[self.cycleSettingModel.lightTurnOffArray objectAtIndex:i]]];
        
        // 打开关闭灯光的类型
        [commandStr appendString:[NSString stringWithFormat:@"%02x",[[self.cycleSettingModel.cycleRampTypeArray objectAtIndex:i] intValue]]];
        
        // 各路颜色百分比
        NSArray *colorPercentArray = [self.cycleSettingModel.lightColorPercentDic objectForKey:@(i)];
        for (id colorPercent in colorPercentArray) {
            [commandStr appendFormat:@"%02x",[colorPercent intValue] / 10];
        }
    }
    
    KMYLOG(@"commandStr=%@",commandStr);
    // 发送命令到设备
    [self.blueToothManager sendCommandWithUUID:self.deviceParameterModel.UUIDString commandStr:commandStr commandType:OTHER_COMMAND isXOR:YES];
}

#pragma mark --- 增加颜色设置界面
- (void)addColorDimmingViewWithCycleIndex:(NSInteger)cycleIndex{
    // 从模型中解析到各路颜色值，根据颜色值数组创建滑动调光界面
    if (self.manualDimmingView != nil){
        // 更新界面
        [self.manualDimmingView updateManualDimmingViewWith:[self.cycleSettingModel.lightColorPercentDic objectForKey:@(cycleIndex)]];
        return;
    }
    
    self.manualDimmingView = [[ManualDimmingView alloc] initWithFrame:CGRectMake(0, 0, self.colorSettingView.bounds.size.width, self.colorSettingView.frame.size.height) colorPercentArray:[self.cycleSettingModel.lightColorPercentDic objectForKey:@(cycleIndex)] textColor:[UIColor blackColor]];
    __weak typeof(self) weakself = self;
    self.manualDimmingView.colorDimmingBlock = ^(NSInteger tag, float value) {
        // 对模型中的各路颜色赋值
        NSMutableArray *colorPercentArray = [weakself.cycleSettingModel.lightColorPercentDic objectForKey:@(cycleIndex)];
        colorPercentArray[tag - 1000] = @((int)value);
    };
    
    [self.colorSettingView addSubview:self.manualDimmingView]; 
}

// 解析周期模型数据
- (void)parseCycleModel:(ECOPlantParameterModel *)deviceParameterModel{
    // 初始化周期模型
    self.cycleSettingModel = [[CycleSettingModel alloc] init];
    // 是否开启周期模式
    self.cycleSettingModel.isOpenCycleMode = deviceParameterModel.isOpenCycleMode;
    // 生长周期个数
    self.cycleSettingModel.cycleCount = deviceParameterModel.cycleCount;
    // 设置周期起始日期
    self.dateFormatter.dateFormat = @"yyyy-MM-dd";
    self.cycleSettingModel.cycleStartDate = [self.dateFormatter dateFromString:[StringRelatedManager convertHexDateToString:deviceParameterModel.cycleStartDate]];
    
    self.dateFormatter.dateFormat = @"HH:mm";
    NSString *cycleStr = @"";
    NSInteger cycleIndex = 0;
    for (NSString *key in deviceParameterModel.cycleDataDic.allKeys) {
        NSMutableArray *colorPercentArray = [NSMutableArray array];
        cycleStr = [deviceParameterModel.cycleDataDic objectForKey:key];
        // 解析周期持续天数
        [self.cycleSettingModel.cycleLengthsArray addObject:@(strtol([[cycleStr substringWithRange:NSMakeRange(0, 2)] UTF8String], 0, 16))];
        // 解析打开灯光的时间：存储格式使用字符串HH:mm
        [self.cycleSettingModel.lightTurnOnArray addObject:[StringRelatedManager convertHexTimeToString:[cycleStr substringWithRange:NSMakeRange(2, 4)]]];
        // 解析关闭灯光的时间：存储格式使用字符串HH:mm
        [self.cycleSettingModel.lightTurnOffArray addObject:[StringRelatedManager convertHexTimeToString:[cycleStr substringWithRange:NSMakeRange(6, 4)]]];
        // 解析打开关闭灯光类型
        [self.cycleSettingModel.cycleRampTypeArray addObject:@(strtol([[cycleStr substringWithRange:NSMakeRange(10, 2)] UTF8String], 0, 16))];
        // 解析各路颜色百分比
        for (int i=0; i<deviceParameterModel.channelNum; i++) {
            [colorPercentArray addObject:@(strtol([[cycleStr substringWithRange:NSMakeRange(12 + 2*i, 2)] UTF8String], 0, 16) * 10)];
        }
        [self.cycleSettingModel.lightColorPercentDic setObject:colorPercentArray forKey:@(cycleIndex)];
        cycleIndex++;
    }
}

#pragma mark --- 设置周期开始日期
- (IBAction)cycleStartDateAction:(UIDatePicker *)sender {
    // 开始日期只有一个
    self.dateFormatter.dateFormat = @"yyyy-MM-dd";
    
    NSString *dateStr = [self.dateFormatter stringFromDate:sender.date];
    
    self.cycleSettingModel.cycleStartDate = [self.dateFormatter dateFromString:dateStr];
}

#pragma mark --- 设置周期长度
- (IBAction)cycleLengthAction:(UITextField *)sender {
    NSMutableArray *cycleLengthsArray = self.cycleSettingModel.cycleLengthsArray;
    [cycleLengthsArray replaceObjectAtIndex:self.currentCycleIndex withObject:@([sender.text integerValue])];
}

#pragma mark --- 每天打开灯的时间
- (IBAction)turnOnAction:(UIDatePicker *)sender {
    // 更新对应周期的开关状态
    NSString *currentCycleTurnOnDate = [self.cycleSettingModel.lightTurnOnArray objectAtIndex:self.currentCycleIndex];
    // 如果获取到数据为空则直接返回
    if (currentCycleTurnOnDate == nil){
        return;
    }
    
    self.dateFormatter.dateFormat = @"HH:mm";
    self.cycleSettingModel.lightTurnOnArray[self.currentCycleIndex] = [self.dateFormatter stringFromDate:self.turnOnDatePicker.date];
}

#pragma mark --- 每天关闭灯的时间
- (IBAction)turnOffAction:(UIDatePicker *)sender {
    // 更新对应周期的开关状态
    NSString *currentCycleTurnOffDate = [self.cycleSettingModel.lightTurnOffArray objectAtIndex:self.currentCycleIndex];
    // 如果获取到数据为空则直接返回
    if (currentCycleTurnOffDate == nil){
        return;
    }
    
    self.dateFormatter.dateFormat = @"HH:mm";
    self.cycleSettingModel.lightTurnOffArray[self.currentCycleIndex] = [self.dateFormatter stringFromDate:self.turnOnDatePicker.date];
}

#pragma mark --- 删除当前周期数据
- (IBAction)deleteCycleAction:(UIButton *)sender {
    // 从数据模型中删除对应周期的数据，并且删除菜单中对应的周期按钮
    // 删除周期持续时长
    [self.cycleSettingModel.cycleLengthsArray removeObjectAtIndex:self.currentCycleIndex];
    
    // 删除开关灯类型
    [self.cycleSettingModel.cycleRampTypeArray removeObjectAtIndex:self.currentCycleIndex];
    
    // 删除打开灯光的时间
    [self.cycleSettingModel.lightTurnOnArray removeObjectAtIndex:self.currentCycleIndex];
    
    // 删除关闭灯光的时间
    [self.cycleSettingModel.lightTurnOffArray removeObjectAtIndex:self.currentCycleIndex];
    
    // 删除各路颜色数据
    [self.cycleSettingModel.lightColorPercentDic removeObjectForKey:@(self.currentCycleIndex)];
    
    // 更新当前周期个数
    self.cycleCount = self.cycleCount - 1;
    
    // 更新数据:删除一个周期后，自动选择该周期的上一个周期
    self.currentCycleIndex = self.cycleCount - 1;
    
    // 重新创建周期选择菜单
    [self createCycleMenuView];
    
    // 选择前一个周期
    UIButton *button = [self.menuScrollView viewWithTag:(self.currentCycleIndex + 1000)];
    if (button != nil){
        [self cycleButtonAction:button];
    }
    
    // 更新视图
    [self updateCycleViewWithCycleIndex:self.currentCycleIndex];
}


#pragma mark --- UIPickerView代理方法：这里要区分是周期持续天数还是关闭灯光的类型
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.rampTypeArray.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [self.rampTypeArray objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    self.cycleSettingModel.cycleRampTypeArray[self.currentCycleIndex] = @(row);
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
