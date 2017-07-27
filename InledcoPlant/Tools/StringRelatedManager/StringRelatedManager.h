//
//  StringRelatedManager.h
//  FluvalSmartApp
//
//  Created by huang zhengguo on 16/10/20.
//  Copyright © 2016年 huang zhengguo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StringRelatedManager : NSObject

/*
 * 转换NSData类型数据为16进制表示的字符串
 * @param data 要转换的数据
 */
+ (NSString *)hexToStringWithData:(NSData *)data;

/*
 * 计算命令字符串的校验码
 * @param str 要转换的数据
 */
+ (NSString *)calculateXORWithString:(NSString *)str;

/*
 * 转换内容为10进制的数据字符串为长度为2的16进制的字符串，其它长度字符串返回nil
 * @param str 要转换的字符串
 */
+ (NSString *)convertToHexStringWithString:(NSString *)str;

/*
 * 转换十六进制日期字符串为yyyyMMdd日期格式
 * @param dateStr日期字符串格式：年月日都是一个自己，其中年份基准值为2000
 */
+ (NSString *)convertHexDateToString:(NSString *)dateStr;

/*
 * 转换日期为yymmdd十六进制格式
 * @param date 要转换的日期
 * @return 转换后的十六进制字符串
 */
+ (NSString *)convertDateToHexString:(NSDate *)date;

/*
 * 转换十六进制的小时分钟为HH:mm格式，如1200->18:00
 * @param timeStr 要转换的时间字符串
 */
+ (NSString *)convertHexTimeToString:(NSString *)timeStr;

/*
 * 转换HH:mm格式的字符串时间为十六进制字符串
 * @param timeStr 要转换的时间字符串
 * @return 返回16进制的字符串
 */
+ (NSString *)convertDateStrToHexStr:(NSString *)timeStr;

@end
