//
//  DatabaseManager.h
//  InledcoPlant
//
//  Created by huang zhengguo on 2017/2/9.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FMDB.h"
#import "DeviceGroupModel.h"

@interface DatabaseManager : NSObject

// 单例类
+(instancetype)defaultDatabaseManager;

- (void)insertIntoTableWithTableName:(NSString *)tableName columnDic:(NSDictionary *)columnDic;

-(NSMutableArray *)findDataFromTableWithTableName:(NSString *)tableName colName:(NSString *)colName colValue:(NSString *)colValue;

-(NSMutableArray *)findDataFromTableWithTableName:(NSString *)tableName groupName:(NSString *)groupName;

- (void)updateDataWithTableName:(NSString *)tableName colName:(NSString *)colName conditionColName:(NSString *)conditionColName conditionCol:(NSString *)conditionCol data:(NSString *)data;

@end
