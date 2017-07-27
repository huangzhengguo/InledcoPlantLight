//
//  DatabaseManager.m
//  InledcoPlant
//
//  Created by huang zhengguo on 2017/2/9.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

#import "DatabaseManager.h"

/* 数据库路径 */
#define DATABASEPATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"bleDatabase.sqlite"]

@interface DatabaseManager()

// 数据库锁
@property(nonatomic, strong) NSLock *lock;

// 数据库指针
@property(nonatomic, strong) FMDatabase *fmDatabase;

@end

@implementation DatabaseManager

-(instancetype)init{
    if(self = [super init]){
        // 初始化数据库指针：指定数据库的位置
        _fmDatabase = [[FMDatabase alloc] initWithPath:DATABASEPATH];
        BOOL ret = [_fmDatabase open];
        if (!ret){
            KMYLOG(@"打开数据库失败！");
        }
        // 初始化锁
        _lock = [[NSLock alloc] init];
        
        // 初始化表
        // 创建分组表
        [self createTableWithTableName:DEVICE_GROUP_TABLE ColumnArray:@[DEVICE_GROUP_TABLE,DEVICE_GROUP_NAME,DEVICE_GROUP_FREE_ONE,DEVICE_GROUP_FREE_TWO,DEVICE_GROUP_FREE_THREE]];
        
        // 创建设备表
        [self createTableWithTableName:DEVICE_TABLE ColumnArray:@[DEVICE_TABLE,DEVICE_GROUPNAME,DEVICE_NAME,DEVICE_TYPECODE,DEVICE_UUID]];
    }
    return self;
}

+(instancetype)defaultDatabaseManager{
    static DatabaseManager *databaseManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        databaseManager = [[DatabaseManager alloc] init];
    });
    
    return databaseManager;
}

#pragma mark --- 通用创建表方法
- (void)createTableWithTableName:(NSString *)tableName ColumnArray:(NSArray *)columnArray{
    [_lock lock];
    // 定义sql语句
    NSString *sqlStr = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(ID INTEGER PRIMARY KEY AUTOINCREMENT",tableName];
    for (NSString *columnName in columnArray) {
        
        sqlStr = [sqlStr stringByAppendingFormat:@",%@",columnName];
    }
    
    sqlStr = [sqlStr stringByAppendingString:@");"];
    BOOL ret=[_fmDatabase executeUpdate:sqlStr];
    if (ret == NO){
        KMYLOG(@"创建%@失败!",tableName);
    }
    [_lock unlock];
}

#pragma mark --- 插入数据
- (void)insertIntoTableWithTableName:(NSString *)tableName columnDic:(NSDictionary *)columnDic{
    [_lock lock];
    // 构造列字符串
    NSString *columnName = [[columnDic allKeys] componentsJoinedByString:@","];
    NSMutableArray *tmpArray = [NSMutableArray array];
    for (int i=0;i<columnDic.allKeys.count;i++){
        [tmpArray addObject:@"?"];
    }
    
    NSString *valueString = [tmpArray componentsJoinedByString:@","];
    NSString *sqlStr = [NSString stringWithFormat:@"INSERT INTO %@(%@) VALUES(%@);",tableName,columnName,valueString];
    BOOL ret = [_fmDatabase executeUpdate:sqlStr withArgumentsInArray:columnDic.allValues];
    if (ret == NO){
        KMYLOG(@"插入%@表失败!",tableName);
    }
    [_lock unlock];
}

#pragma mark --- 删除方法
- (void)deleteFromTableWithTableName:(NSString *)tableName identify:(NSInteger)identify{
    [_lock lock];
    NSString *sqlStr = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@=",tableName,@(identify)];
    BOOL ret = [_fmDatabase executeUpdate:sqlStr];
    if (ret == NO){
        KMYLOG(@"从%@删除失败",tableName);
    }
    [_lock unlock];
}

#pragma mark --- 更新一个表的某一列
- (void)updateDataWithTableName:(NSString *)tableName colName:(NSString *)colName conditionColName:(NSString *)conditionColName conditionCol:(NSString *)conditionCol data:(NSString *)data{
    [_lock lock];
    NSString *sqlStr = [NSString stringWithFormat:@"UPDATE %@ SET %@ = '%@' WHERE %@='%@'",tableName,colName,data,conditionColName,conditionCol];
    BOOL ret = [_fmDatabase executeUpdate:sqlStr];
    if (ret == NO){
        KMYLOG(@"更新%@表失败",tableName);
    }
    [_lock unlock];
}

#pragma mark --- 根据列名查询
-(NSMutableArray *)findDataFromTableWithTableName:(NSString *)tableName colName:(NSString *)colName colValue:(NSString *)colValue{
    [_lock lock];
    NSMutableArray *array = [NSMutableArray array];
    FMResultSet *set;
    NSString *sqlStr = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = '%@'",tableName,colName,colValue];
    set = [_fmDatabase executeQuery:sqlStr];
    while ([set next]) {
        DeviceModel *deviceModel = [[DeviceModel alloc] init];
        
        deviceModel.deviceGroupName = [set stringForColumn:DEVICE_GROUPNAME];
        deviceModel.deviceName = [set stringForColumn:DEVICE_NAME];
        deviceModel.deviceTypeCode = [set stringForColumn:DEVICE_TYPECODE];
        deviceModel.UUIDString = [set stringForColumn:DEVICE_UUID];
        
        [array addObject:deviceModel];
        deviceModel = nil;
    }
    [_lock unlock];
    
    return array;
}

#pragma mark --- 查询
-(NSMutableArray *)findDataFromTableWithTableName:(NSString *)tableName groupName:(NSString *)groupName{
    [_lock lock];
    FMResultSet *set;
    NSString *sqlStr;
    NSMutableArray *array = [NSMutableArray array];
    if ([tableName isEqualToString:DEVICE_GROUP_TABLE]){
        // 获取分组信息
        if (groupName == nil){
            sqlStr = [NSString stringWithFormat:@"SELECT * FROM %@",tableName];
        }else{
            sqlStr = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = '%@'",tableName,DEVICE_GROUP_NAME,groupName];
        }
        
        set = [_fmDatabase executeQuery:sqlStr];
        while ([set next]) {
            DeviceGroupModel *deviceGroupModel = [[DeviceGroupModel alloc] init];
            
            deviceGroupModel.groupName = [set stringForColumn:DEVICE_GROUP_NAME];
            
            [array addObject:deviceGroupModel];
            
            deviceGroupModel = nil;
        }
        [_lock unlock];
        
        return array;
    }else if ([tableName isEqualToString:DEVICE_TABLE]){
        // 解析设备数据
        if (groupName == nil){
            sqlStr = [NSString stringWithFormat:@"SELECT * FROM %@",tableName];
        }else{
            sqlStr = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = '%@'",tableName,DEVICE_GROUPNAME,groupName];
        }
        set = [_fmDatabase executeQuery:sqlStr];
        while ([set next]) {
            DeviceModel *deviceModel = [[DeviceModel alloc] init];
            
            deviceModel.UUIDString = [set stringForColumn:DEVICE_UUID];
            deviceModel.deviceTypeCode = [set stringForColumn:DEVICE_TYPECODE];
            deviceModel.deviceGroupName = [set stringForColumn:DEVICE_GROUPNAME];
            deviceModel.deviceName = [set stringForColumn:DEVICE_NAME];
            
            [array addObject:deviceModel];
            
            deviceModel = nil;
        }
        [_lock unlock];
        return array;
    }else{
        [_lock unlock];
        return array;
    }
}

@end



































