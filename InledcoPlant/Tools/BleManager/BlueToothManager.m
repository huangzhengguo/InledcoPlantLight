//
//  BlueToothManager.m
//  InledcoPlant
//
//  Created by huang zhengguo on 2017/5/15.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

#import "BlueToothManager.h"
#import "BLEManager.h"
#import "DeviceInfo.h"
#import "DatabaseManager.h"
#import "StringRelatedManager.h"

// 发起连接设备的时长，超过该时长则视为扫描结束
#define CONNECTIONINTERVAL 2.0f
// 扫描时为了获取设备类型编码设置的连接时长
#define SCAN_CONNECTION_INTERVAL 2.5f
// 尝试连接的最大次数，超过此数则视为连接失败
#define MAXCONNECTIONCOUNT 3

@interface BlueToothManager()<BLEManagerDelegate>

// 数据库管理对象
@property(nonatomic, strong) DatabaseManager *databaseManager;
// 蓝牙管理对象
@property(nonatomic, strong) BLEManager *bleManager;
// 扫描定时器
@property(nonatomic, strong) NSTimer *scanTimer;
// 连接定时器
@property(nonatomic, strong) NSTimer *connectTimer;
// 连接设备定时器
@property(nonatomic, strong) NSTimer *connTimer;
@property(nonatomic, assign) NSInteger connectCount;
// 设备模型数组：包含所有扫描到的设备数据
@property(nonatomic, strong) NSMutableArray *deviceModelArray;
// 设备模型数组：只包含解析到类型编码设备数据
@property(nonatomic, strong) NSMutableArray *deviceWithTypeCodeModelArray;
// 接收数据完成标记
@property(nonatomic, assign) BOOL isReceiveAllData;
// 存储接收数据
@property(nonatomic, strong) NSString *receivedData;
// 发送命令类型
@property(nonatomic, assign) SendCommandType currentCommandType;
// OTA返回数据长度记录
@property(nonatomic, assign) NSInteger OTADataLength;
// 当前连接的设备的索引
@property(nonatomic, assign) NSInteger currentToConnectDeviceIndex;
// 发送调光命令间隔时间
@property(nonatomic, assign) double lastDimmSendTime;

@end

@implementation BlueToothManager

// 设备模型数组
- (NSMutableArray *)deviceModelArray{
    if (_deviceModelArray == nil){
        self.deviceModelArray = [NSMutableArray array];
    }
    
    return _deviceModelArray;
}

- (NSMutableArray *)deviceWithTypeCodeModelArray{
    if (_deviceWithTypeCodeModelArray == nil){
        self.deviceWithTypeCodeModelArray = [NSMutableArray array];
    }
    return _deviceWithTypeCodeModelArray;
}

// 类方法使用+号表示
+(instancetype)defaultBlueToothManager{
    static BlueToothManager *blueToothManager = nil;
    if (blueToothManager != nil){
        // 设置代理，保证代理方法只在该类中执行
        blueToothManager.bleManager.delegate = blueToothManager;
        blueToothManager.lastDimmSendTime = 0;
    }
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 初始化属性
        blueToothManager = [[BlueToothManager alloc] init];
        blueToothManager.lastDimmSendTime = 0;
        blueToothManager.isReceiveAllData = NO;
        blueToothManager.OTADataLength = 0;
        blueToothManager.connectCount = 0;
        blueToothManager.currentCommandType = OTHER_COMMAND;
        blueToothManager.receivedData = @"";
        blueToothManager.bleManager = [BLEManager defaultManager];
        blueToothManager.bleManager.delegate = blueToothManager;
        blueToothManager.databaseManager = [DatabaseManager defaultDatabaseManager];
    });
    
    return blueToothManager;
}

/*
 * 扫描及连接设备方法
 * 1.开始扫描- (void)StartScanWithTime:(NSInteger)time
 * 2.停止扫描- (void)StopScan
 * 3.连接到设备- (void)connectToDeviceWithUUID:(NSString *)UUID
 * 4.断开设备连接- (void)disConnectToDeviceWithUUID:(NSString *)UUID
 */
- (void)StartScanWithTime:(NSInteger)time{
    // 清除记忆：否则无法再次扫描到已经扫描过的设备
    [self.bleManager.dev_DICARRAY removeAllObjects];
    // 设置定时器开始扫描
    self.scanTimer = [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(StopScan) userInfo:nil repeats:NO];
    [self.bleManager scanDeviceTime:time];
    [self.bleManager manualStopScanDevice];
    [self.bleManager scanDeviceTime:time];
}

- (void)StopScan{
    // 取消定时器
    if (self.scanTimer != nil){
        [self.scanTimer invalidate];
        self.scanTimer = nil;
    }
    
    // 停止扫描
    [self.bleManager manualStopScanDevice];
    
    // 停止后的代理
    if (self.stopScanDeviceBlock){
        self.stopScanDeviceBlock();
    }
}

#pragma mark --- 蓝牙代理方法
- (void)scanDeviceRefrash:(NSMutableArray *)array{
    // 标记命令类型
    self.currentCommandType = SCAN_CONNECT_DEVICE_COMMAND;
    // 扫描到的设备信息保存在Array数组中
    [self.deviceModelArray removeAllObjects];
    [self.deviceWithTypeCodeModelArray removeAllObjects];
    
    // 解析扫描到的设备后：删除后刷新扫描列表
    if (self.scanDeviceBlock){
        self.scanDeviceBlock(self.deviceWithTypeCodeModelArray);
    }
    
    if (self.connectTimer != nil){
        [self.connectTimer invalidate];
        self.connectTimer = nil;
    }
    
    // 开始解析数据
    BOOL isContainInDatasource = NO;
    for (DeviceInfo *deviceInfo in array) {
        // 查找数据库中是否已经保存在数据库中
        NSArray *array = [self.databaseManager findDataFromTableWithTableName:DEVICE_TABLE colName:DEVICE_UUID colValue:deviceInfo.UUIDString];
        if (array.count > 0){
            // 如果数据库中已经存在存在则跳过
            continue;
        }
        
        // 查找数据源中是否已经存在
        for (DeviceModel *savedInfo in self.deviceModelArray) {
            
            if ([deviceInfo.UUIDString isEqualToString:savedInfo.UUIDString]){
                isContainInDatasource = YES;
            }
        }
        
        if (isContainInDatasource == YES){
            continue;
        }
        
        // 构建设备模型
        DeviceModel *deviceModel = [[DeviceModel alloc] init];
        
        deviceModel.deviceGroupName = DEFAULT_GROUPNAME;
        deviceModel.deviceName = deviceInfo.localName;
        deviceModel.UUIDString = deviceInfo.UUIDString;
        deviceModel.cb = [self.bleManager getDeviceByUUID:deviceInfo.UUIDString];
        deviceModel.isSelected = NO;
        
        [self.deviceModelArray addObject:deviceModel];
        
        deviceModel = nil;
        isContainInDatasource = NO;
    }
    
    // 如果超时不再进入扫描回调，则执行连接设备
    self.connectTimer = [NSTimer scheduledTimerWithTimeInterval:SCAN_CONNECTION_INTERVAL target:self selector:@selector(connectToDeviceWithDeviceArray:) userInfo:nil repeats:NO];
}

#pragma mark --- 连接扫描到的设备，只保存那些能够连接上获取到设备类型编码的数据
- (void)connectToDeviceWithDeviceArray:(NSTimer *)timer{
    self.currentToConnectDeviceIndex = 0;
    if (self.deviceModelArray.count > self.currentToConnectDeviceIndex){
        DeviceModel *deviceModel = [self.deviceModelArray objectAtIndex:self.currentToConnectDeviceIndex];
        [self.bleManager connectToDevice:[self.bleManager getDeviceByUUID:deviceModel.UUIDString]];
    }
}

#pragma mark --- 连接设备
- (void)connectToDeviceWithUUID:(NSString *)UUID{
    // 初始化连接次数
    self.connectCount = 0;
    // 初始化连接设备的定时器
    self.connTimer = [NSTimer scheduledTimerWithTimeInterval:CONNECTIONINTERVAL target:self selector:@selector(sendConnectCommandToDevice:) userInfo:UUID repeats:YES];
    // 连接到设备
    self.isReceiveAllData = NO;
}

- (void)sendConnectCommandToDevice:(NSTimer *)timer{
    // 还应该对连接设备的次数进行计数，连接超过最大次数则视为连接失败
    if (++self.connectCount > MAXCONNECTIONCOUNT){
        [self.connTimer invalidate];
        self.connTimer = nil;
        KMYLOG(@"连接失败!");
        // 调用连接失败的block
        if (self.connectDeviceFailedBlock){
            self.connectDeviceFailedBlock();
        }
        
        return;
    }
    KMYLOG(@"正在连接设备，第%ld次！",self.connectCount);
    // 解析定时器携带的数据
    NSString *uuid = timer.userInfo;
    
    // 获取设备
    CBPeripheral *cb = [self.bleManager getDeviceByUUID:uuid];
    if ([self.bleManager.dev_DICARRAY containsObject:cb] == NO){
        [self.bleManager.dev_DICARRAY addObject:cb];
    }
    // 应该考虑到连接失败的情况，然后进行多次连接，暂时没有考虑
    [self.bleManager connectToDevice:cb];
}

- (void)disConnectToDeviceWithUUID:(NSString *)UUID{
    // 获取设备
    CBPeripheral *cb = [self.bleManager getDeviceByUUID:UUID];
    // 把设备添加到蓝牙管理对象数组中
    if ([self.bleManager.dev_DICARRAY containsObject:cb] == NO){
        [self.bleManager.dev_DICARRAY addObject:cb];
    }
    // 断开设备连接
    [self.bleManager disconnectDevice:cb];
}

#pragma mark --- 连接回调
- (void)connectDeviceSuccess:(CBPeripheral *)device error:(NSError *)error{
    // 如果是扫描时候为了获取设备编码连接设备
    if (self.currentCommandType == SCAN_CONNECT_DEVICE_COMMAND){
        // 读取广播数据
        [self.bleManager readDeviceAdvertData:device];
        
        return;
    }
    
    // 清空连接有关的信息
    if (self.connTimer != nil){
        [self.connTimer invalidate];
        self.connTimer = nil;
    }
    
    // 连接成功
    KMYLOG(@"连接成功;错误信息=%@",error);
    // 向设备发送同步时间命令，获取设备参数，会接收到两份返回的数据
    [self sendTimeSynchronizationCommand:device];
}

#pragma mark --- 断开设备
- (void)didDisconnectDevice:(CBPeripheral *)device error:(NSError *)error{
    if (self.currentCommandType == SCAN_CONNECT_DEVICE_COMMAND){
        // 再去连接下一个设备
        KMYLOG(@"断开设备成功，连接下一个设备");
        if (self.deviceModelArray.count > (++self.currentToConnectDeviceIndex)){
            DeviceModel *scanDeviceModel = [self.deviceModelArray objectAtIndex:self.currentToConnectDeviceIndex];
            [self.bleManager connectToDevice:[self.bleManager getDeviceByUUID:scanDeviceModel.UUIDString]];
        }
        return;
    }
    
    // 断开成功
    KMYLOG(@"断开设备");
    if (self.disConnectDeviceBlock){
        self.disConnectDeviceBlock();
    }
}

#pragma mark --- 接收到广播数据回调
- (void)receiveDeviceAdvertData:(NSString *)dataStr device:(CBPeripheral *)device{
    KMYLOG(@"获取广播数据成功");
    DeviceModel *scanDeviceModel = [self.deviceModelArray objectAtIndex:self.currentToConnectDeviceIndex];
    [self parsekCBAdvDataManufacturerData:dataStr model:scanDeviceModel];
    
    // 添加设备到要显示的数据源中
    if (scanDeviceModel.deviceTypeCode != nil && scanDeviceModel.deviceTypeCode.length > 0){
        [self.deviceWithTypeCodeModelArray addObject:scanDeviceModel];
    }
    
    // 解析扫描到的设备后
    if (self.scanDeviceBlock){
        self.scanDeviceBlock(self.deviceWithTypeCodeModelArray);
    }
    
    // 断开设备
    [self.bleManager disconnectDevice:device];
}

- (void)parsekCBAdvDataManufacturerData:(NSString *)dataStr model:(DeviceModel *)scanDeviceModel{
    if (dataStr == nil || dataStr.length < 4){
        return;
    }
    
    NSString *typeStrCode = [dataStr substringWithRange:NSMakeRange(0, 4)];
    
    //赋值设备类型编码
    scanDeviceModel.deviceTypeCode = typeStrCode;

}

#pragma mark --- 接收到设备数据
- (void)receiveDeviceDataSuccess_1:(NSData *)data device:(CBPeripheral *)device{
    // 处理OTA部分
    if (self.currentCommandType == OTA_COMMAND || self.currentCommandType == READBLEINFOR_COMMAND || self.currentCommandType == ERASURE_COMMAND || self.currentCommandType == WRITE_COMMAND || self.currentCommandType == RESTART_COMMAND){
        [self processOTAReceiveData:data commandType:self.currentCommandType];
        
        self.receivedData = @"";
        return;
    }
    /*
     * 此处判断数据是否已经接收完毕；如果接收完毕则不再接收数据；防止同一类型的命令多次接收数据
     */
    if (self.isReceiveAllData == YES){
        return;
    }
    
    // 接收完数据之后，取消正在连接设备的提示
    self.receivedData = [self.receivedData stringByAppendingString:[StringRelatedManager hexToStringWithData:data]];
    if ([[StringRelatedManager calculateXORWithString:[self.receivedData substringToIndex:self.receivedData.length-2]] isEqualToString:[self.receivedData substringFromIndex:self.receivedData.length-2]]){
        // 输出接收到的完整的数据
        KMYLOG(@"self.receivedData=%@",self.receivedData);
        switch (self.currentCommandType) {
            case TIMESYNCHRONIZATION_COMMAND:
            case POWERON_COMMAND:
            case POWEROFF_COMMAND:
            case MANUALMODE_COMMAND:
            case AUTOMODE_COMMAND:{
                // 返回的是设备信息
                if (self.completeReceiveDataBlock){
                    // 把解析到的数据传递出去
                    self.completeReceiveDataBlock(self.receivedData, self.currentCommandType);
                }
                break;
            }
            // 没有返回数据的命令
            case MANUAL_DIMMING_COMMAND:
                break;
            default:
                break;
        }
        // 检验数据接收完毕
        self.isReceiveAllData = YES;
        self.receivedData = @"";
    }
}

#pragma mark --- OTA功能部分数据解析
- (void)processOTAReceiveData:(NSData *)data commandType:(SendCommandType)commandType{
    // 获取数据长度数值
    if (self.receivedData.length == 0 && [StringRelatedManager hexToStringWithData:data].length > 4){
        self.OTADataLength = strtol([[[StringRelatedManager hexToStringWithData:data] substringWithRange:NSMakeRange(2, 2)] UTF8String], 0, 16);
    }
    
    self.receivedData = [self.receivedData stringByAppendingString:[StringRelatedManager hexToStringWithData:data]];
    
    switch (self.currentCommandType) {
        case OTA_COMMAND:
        {
            // 处理OTA升级命令
            if (self.completeOTABlock && ([self.receivedData isEqualToString:@"6800000068"] || [self.receivedData isEqualToString:@"6801000001"])){
                self.completeOTABlock(self.receivedData);
                self.receivedData = @"";
            }
        }
            break;
        case READBLEINFOR_COMMAND:{
            // 处理获取蓝牙信息命令
            if (self.queryBLEInfoBlock && self.OTADataLength == (self.receivedData.length - 8) / 2){
                self.queryBLEInfoBlock(self.receivedData);
                self.receivedData = @"";
            }
        }
            break;
        case ERASURE_COMMAND:{
            // 处理擦除闪存命令
            if (self.erasureMemoryBlock && self.OTADataLength == (self.receivedData.length - 8) / 2){
                self.erasureMemoryBlock(self.receivedData);
            }
        }
            break;
        case WRITE_COMMAND:{
            if (self.writeMemoryBlock && self.OTADataLength == (self.receivedData.length - 8) / 2){
                self.writeMemoryBlock(self.receivedData);
            }
        }
            break;
        case RESTART_COMMAND:{
            if (self.restartDeviceBlock && self.OTADataLength == (self.receivedData.length - 8) / 2){
                self.restartDeviceBlock(self.receivedData);
            }
        }
            break;
        default:
            break;
    }
}

/*
 * 发送命令方法
 * 0.发送命令，不包含校验码
 * 1.发送同步设备时间
 * 2.发送打开灯光命令
 * 3.发送关闭灯光命令
 * 4.发送手动模式命令
 * 5.发送自动模式命令
 * 6.发送读取时间命令
 * 7.发送查找设备命令
 * 8.发送OTA升级命令
 */

#pragma mark --- 0.发送调光命令
- (void)sendCommandWithUUID:(NSString *)uuidString interval:(long)interval channelNum:(NSInteger)channelNum colorIndex:(NSInteger)colorIndex colorValue:(float)colorValue{
    // 如果两次发送命令的时间间隔小于interval，则直接返回
    if (([NSDate date].timeIntervalSince1970 * 1000 - self.lastDimmSendTime) < interval){
        return;
    }
    
    int colorIntValue = floor(colorValue);
    NSString *colorStr = [NSString stringWithFormat:@"%04x",colorIntValue];
    NSMutableString *commandStr = [@"6804" mutableCopy];
    for (int i=0;i<channelNum;i++){
        [commandStr appendString:@"FFFF"];
    }
    
    [commandStr replaceCharactersInRange:NSMakeRange(4+colorIndex*4, 4) withString:colorStr];
    
    [self sendCommandWithUUID:uuidString commandStr:commandStr commandType:MANUAL_DIMMING_COMMAND isXOR:YES];
    
    self.lastDimmSendTime = [NSDate date].timeIntervalSince1970 * 1000;
}

#pragma mark --- 0.发送命令
- (void)sendCommandWithUUID:(NSString *)uuid commandStr:(NSString *)commandStr commandType:(SendCommandType)commandType isXOR:(BOOL)isXOR{
    self.currentCommandType = commandType;
    self.isReceiveAllData = NO;
    CBPeripheral *device = [self.bleManager getDeviceByUUID:uuid];
    KMYLOG(@"发送命令=%@",commandStr);
    // 1.计算校验码
    NSString *xorStr = [StringRelatedManager calculateXORWithString:commandStr];
    if (xorStr.length == 1){
        
        xorStr = [NSString stringWithFormat:@"0%@",xorStr];
    }
    
    // 2.如果不带校验码则设置xorStr为空
    if (isXOR == NO){
        xorStr = @"";
    }
    
    // 3.带有校验码的命令
    NSString *commandStrXor = [NSString stringWithFormat:@"%@%@",commandStr,xorStr];
    if (commandStrXor.length <= 30){
        [self.bleManager sendDataToDevice1:commandStrXor device:device];
        
        return;
    }
    
    // 3.发送长度大于15字节的命令，留一定空间
    NSString *subLastCommandStr = commandStrXor;
    while (subLastCommandStr.length > 30) {
        NSString *subCommandStr = [subLastCommandStr substringToIndex:30];
        [self.bleManager sendDataToDevice1:subCommandStr device:device];
        
        subLastCommandStr = [subLastCommandStr substringFromIndex:30];
    }
    
    // 4.发送命令到设备
    [self.bleManager sendDataToDevice1:subLastCommandStr device:device];
}

#pragma mark --- 1.发送同步时间命令
- (void)sendTimeSynchronizationCommand:(CBPeripheral *)device{
    // 标记命令类型
    self.currentCommandType = TIMESYNCHRONIZATION_COMMAND;
    
    /* 向设备发送获取参数的指令 */
    NSDate *dateNow = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    NSDateComponents *comps = [calendar components:NSCalendarUnitWeekday fromDate:dateNow];;
    NSInteger weekDay = ([comps weekday] - 1);
    
    format.dateFormat = [NSString stringWithFormat:@"yyMMdd%02ldHHmmss",weekDay];
    NSString *timeStr = [format stringFromDate:dateNow];
    NSString *commandStr = @"680E";
    //把时间字符串转换为16进制字符串
    for (int i=0; i<timeStr.length / 2; i++) {
        NSString *timeSubStr = [timeStr substringWithRange:NSMakeRange(i * 2, 2)];
        commandStr = [NSString stringWithFormat:@"%@%@",commandStr,[StringRelatedManager convertToHexStringWithString:timeSubStr]];
    }
    
    NSString *xorStr = [StringRelatedManager calculateXORWithString:commandStr];
    
    [self.bleManager sendDataToDevice1:[NSString stringWithFormat:@"%@%@",commandStr,xorStr] device:device];
}

#pragma mark --- 2.发送打开灯光命令
- (void)sendPowerOnCommand:(NSString *)uuidString{
    [self sendCommandWithUUID:uuidString commandStr:@"680301" commandType:POWERON_COMMAND isXOR:YES];
}

#pragma mark --- 3.发送关闭灯光命令
- (void)sendPowerOffCommand:(NSString *)uuidString{
    [self sendCommandWithUUID:uuidString commandStr:@"680300" commandType:POWEROFF_COMMAND isXOR:YES];
}

#pragma mark --- 4.发送手动模式命令
- (void)sendManualModeCommand:(NSString *)uuidString{
    [self sendCommandWithUUID:uuidString commandStr:@"680200" commandType:MANUALMODE_COMMAND isXOR:YES];
}

#pragma mark --- 5.发送自动模式命令
- (void)sendAutoModeCommand:(NSString *)uuidString{
    [self sendCommandWithUUID:uuidString commandStr:@"680201" commandType:AUTOMODE_COMMAND isXOR:YES];
}

#pragma mark --- 6.发送读取时间命令
- (void)sendReadTimeCommand:(NSString *)uuidString{
    [self sendCommandWithUUID:uuidString commandStr:@"680D" commandType:READTIME_COMMAND isXOR:YES];
}

#pragma mark --- 7.发送查找设备命令
- (void)sendFindDeviceCommand:(NSString *)uuidString{
    [self sendCommandWithUUID:uuidString commandStr:@"680F" commandType:FINDDEVICE_COMMAND isXOR:YES];
}

#pragma mark --- 8.发送OTA升级命令
- (void)sendOTACommand:(NSString *)uuidString{
    [self sendCommandWithUUID:uuidString commandStr:@"68000000" commandType:OTA_COMMAND isXOR:YES];
}

/* Bootloader下命令发送
 * 1.发送获取蓝牙信息命令
 * 2.发送擦除内存块命令
 * 3.发送写入闪存命令
 * 4.发送重启命令
 */
#pragma mark --- 1.获取蓝牙版本等信息
- (void)sendReadBLInfoCommand:(NSString *)uuidString{
    self.OTADataLength = 0;
    [self sendCommandWithUUID:uuidString commandStr:@"00000000" commandType:READBLEINFOR_COMMAND isXOR:NO];
}

#pragma mark --- 2.发送擦除闪存命令
- (void)sendErasureDeviceCommand:(NSString *)uuidString commandStr:(NSString *)commandStr{
    self.OTADataLength = 0;
    [self sendCommandWithUUID:uuidString commandStr:commandStr commandType:ERASURE_COMMAND isXOR:NO];
}

#pragma mark --- 3.发送写入闪存命令
- (void)sendWriteDeviceCommand:(NSString *)uuidString commandStr:(NSString *)commandStr{
    self.OTADataLength = 0;
    [self sendCommandWithUUID:uuidString commandStr:commandStr commandType:WRITE_COMMAND isXOR:NO];
}

#pragma mark -- 4.重启命令
- (void)sendRestartDeviceCommand:(NSString *)uuidString{
    self.OTADataLength = 0;
    [self sendCommandWithUUID:uuidString commandStr:@"0A000000" commandType:RESTART_COMMAND isXOR:NO];
}

/*
 * 解析接收数据方法：对不同的灯具，由于协议的不同，所以解析方法也不相同
 * 1.Hagen App模型解析方法
 * 2.ECO Plant模型解析方法
 */

#pragma mark --- 1.Hagen App 使用的解析方法
- (void)parseDataFromReceiveData:(NSString *)receiveData deviceInfoModel:(DeviceParameterModel *)deviceInfoModel{
    // 定义游标
    NSInteger countIndex = 0;
    // 定义解析长度
    NSInteger count = 2;
    
    // 解析数据帧头
    deviceInfoModel.headerStr = [receiveData substringWithRange:NSMakeRange(countIndex, count)];
    
    // 解析命令码
    countIndex = countIndex + 2;
    deviceInfoModel.commandStr = [receiveData substringWithRange:NSMakeRange(countIndex, 2)];
    
    // 解析运行模式
    countIndex = countIndex + 2;
    deviceInfoModel.runMode = [receiveData substringWithRange:NSMakeRange(countIndex, 2)];
    
    // 根据工作模式解析数据:自动手动
    if (strtol([deviceInfoModel.runMode UTF8String], 0, 16) == MANUAL_MODE){
        // 解析手动模式数据
        // 解析开关状态
        countIndex = countIndex + 2;
        deviceInfoModel.powerState = [receiveData substringWithRange:NSMakeRange(countIndex, 2)];
        
        // 解析动态模式
        countIndex = countIndex + 2;
        deviceInfoModel.dynaMode = [receiveData substringWithRange:NSMakeRange(countIndex, 2)];
        
        // 解析手动模式值:解析所有通道的值，按照键值0 1 2 3 4 ....(colorIndex)存储到字典中
        NSString *colorValue = @"";
        NSInteger colorIndex = 0;
        countIndex = countIndex + 2;
        for (int i=0; i<deviceInfoModel.channelNum; i++) {
            // 解析出来的值保持高位在前，低位在后，并且保持16进制
            colorValue = @"";
            colorValue = [receiveData substringWithRange:NSMakeRange(countIndex, 4)];
            [deviceInfoModel.manualValueDic setObject:colorValue forKey:@(colorIndex)];
            colorIndex ++;
            countIndex = countIndex + 4;
        }
        
        // 解析用户自定义数值
        colorValue = @"";
        colorIndex = 0;
        // 这里的4是指P1 P2 P3 P4
        for (int i=0; i<4; i++) {
            colorValue = @"";
            colorValue = [receiveData substringWithRange:NSMakeRange(countIndex, deviceInfoModel.channelNum * 2)];
            [deviceInfoModel.userDefineValueDic setObject:colorValue forKey:@(colorIndex)];
            colorIndex ++;
            countIndex = countIndex + deviceInfoModel.channelNum * 2;
        }
    }else if (strtol([deviceInfoModel.runMode UTF8String], 0, 16) == AUTO_MODE){
        countIndex = countIndex + 2;
        NSString *timeStr = @"";
        NSString *colorStr = @"";
        for (int i=0; i<2; i++) {
            // 解析时间点
            timeStr = [receiveData substringWithRange:NSMakeRange(countIndex, 4)];
            [deviceInfoModel.timepointArray addObject:timeStr];
            //KMYLOG(@"timeStr=%@",timeStr);
            countIndex = countIndex + 4;
            timeStr = [receiveData substringWithRange:NSMakeRange(countIndex, 4)];
            [deviceInfoModel.timepointArray addObject:timeStr];
            //KMYLOG(@"timeStr=%@",timeStr);
            countIndex = countIndex + 4;
            // 根据通道数量解析颜色值
            colorStr = [receiveData substringWithRange:NSMakeRange(countIndex, deviceInfoModel.channelNum * 2)];
            countIndex = countIndex + deviceInfoModel.channelNum * 2;
            //KMYLOG(@"colorStr=%@",colorStr);
            // 添加到设备数据模型中
            [deviceInfoModel.timepointValueDic setObject:colorStr forKey:@(i)];
        }
    }
}

#pragma mark --- 2.ECO Plant解析数据方法
- (void)parseECOPlantDataFromReceiveData:(NSString *)receiveData deviceInfoModel:(ECOPlantParameterModel *)deviceInfoModel{
    // 定义游标
    NSInteger countIndex = 0;
    
    // 定义解析长度
    NSInteger count = 2;
    
    // 解析数据帧头
    deviceInfoModel.headerStr = [receiveData substringWithRange:NSMakeRange(countIndex, count)];
    
    // 解析命令码
    countIndex = countIndex + 2;
    deviceInfoModel.commandStr = [receiveData substringWithRange:NSMakeRange(countIndex, 2)];
    
    // 解析设备运行模式:这里没有运行模式，这里的标志的是是否已开启周期模式
    countIndex = countIndex + 2;
    deviceInfoModel.runMode = [receiveData substringWithRange:NSMakeRange(countIndex, 2)];
    if ([deviceInfoModel.runMode isEqualToString:@"00"]){
        deviceInfoModel.isOpenCycleMode = NO;
    }else{
        deviceInfoModel.isOpenCycleMode = YES;
    }
    
    // 生长周期个数
    countIndex = countIndex + 2;
    deviceInfoModel.cycleCount = [[receiveData substringWithRange:NSMakeRange(countIndex, 2)] integerValue];
    
    // 生长周期的起始日期
    countIndex = countIndex + 2;
    deviceInfoModel.cycleStartDate = [receiveData substringWithRange:NSMakeRange(countIndex, 6)];
    
    // 解析周期数据
    NSString *cycleValueStr = @"";
    countIndex = countIndex + 6;
    // 12 为本周期持续天数 打开关闭灯光时间 关闭灯光类型 后面为每路颜色值字符串长度
    NSInteger cycleValueLength = 12 + deviceInfoModel.channelNum * 2;
    for (int i=0; i<deviceInfoModel.cycleCount; i++) {
        cycleValueStr = [receiveData substringWithRange:NSMakeRange(countIndex, cycleValueLength)];
        
        [deviceInfoModel.cycleDataDic setObject:cycleValueStr forKey:@(i)];
        
        cycleValueStr = @"";
        countIndex = countIndex + cycleValueLength;
    }
}

@end
