//
//  StringRelatedManager.m
//  FluvalSmartApp
//
//  Created by huang zhengguo on 16/10/20.
//  Copyright © 2016年 huang zhengguo. All rights reserved.
//

#import "StringRelatedManager.h"

@implementation StringRelatedManager

+ (NSString *)hexToStringWithData:(NSData *)data{
    // 把data数据转换为字节数组
    Byte *bytes = (Byte *)[data bytes];

    NSString *hexStr = @"";
    for (int i=0; i<[data length]; i++) {
        
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i] & 0xff];
        if ([newHexStr length] == 1){
            
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        }else{
            
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
        }
    }
    
    return hexStr;
}

+ (NSString *)calculateXORWithString:(NSString *)str{
    if (str.length % 2 != 0){
        return nil;
    }
    
    NSInteger hexInt = 0;
    NSInteger xorInt = 0;
    for (int i=0; i<str.length / 2; i++) {
        
        NSString *subStr = [str substringWithRange:NSMakeRange(i * 2, 2)];
        
        hexInt = strtol([subStr UTF8String], 0, 16);
        
        xorInt = (xorInt ^ hexInt);
    }
    
    NSString *xor = [NSString stringWithFormat:@"%0lx",(long)xorInt];
    if (xor.length < 2){
        
        xor = [NSString stringWithFormat:@"0%@",xor];
    }
    
    return xor;
}

+ (NSString *)convertToHexStringWithString:(NSString *)str{
    NSInteger value = [str integerValue];
    NSString *hexStr = [NSString stringWithFormat:@"%0lx",(long)value];
    if (hexStr.length > 2){
        
        return nil;
    }
    
    if (hexStr.length == 1){
        
        return [NSString stringWithFormat:@"0%@",hexStr];
    }
    
    return hexStr;
}

+ (NSString *)convertHexDateToString:(NSString *)dateStr{
    NSString *yearStr = [dateStr substringWithRange:NSMakeRange(0, 2)];
    NSString *monthStr = [dateStr substringWithRange:NSMakeRange(2, 2)];
    NSString *dayStr = [dateStr substringWithRange:NSMakeRange(4, 2)];
    
    // 年份加上2000基准值
    NSInteger yearInt = strtol([yearStr UTF8String], 0, 16) + 2000;
    NSInteger monthInt = strtol([monthStr UTF8String], 0, 16) + 1;
    NSInteger dayInt = strtol([dayStr UTF8String], 0, 16);
    
    return [NSString stringWithFormat:@"%ld-%ld-%ld",yearInt,monthInt,dayInt];
}

+ (NSString *)convertDateToHexString:(NSDate *)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    dateFormatter.dateFormat = @"yyyymmdd";
    
    NSString *dateStr = [dateFormatter stringFromDate:date];
    int8_t yearInt = (int8_t)([[dateStr substringWithRange:NSMakeRange(0, 4)] intValue] - 2000);
    int8_t monthInt = (int8_t)[[dateStr substringWithRange:NSMakeRange(4, 2)] intValue];
    int8_t dayInt = (int8_t)[[dateStr substringWithRange:NSMakeRange(6, 2)] intValue];
    
    return [NSString stringWithFormat:@"%02x%02x%02x",yearInt,monthInt,dayInt];
}

+ (NSString *)convertHexTimeToString:(NSString *)timeStr{
    NSInteger hourInt = strtol([[timeStr substringToIndex:2] UTF8String], 0, 16);
    NSInteger minuteInt = strtol([[timeStr substringFromIndex:3] UTF8String], 0, 16);
    
    return [NSString stringWithFormat:@"%02ld:%02ld",hourInt,minuteInt];
}

+ (NSString *)convertDateStrToHexStr:(NSString *)timeStr{
    int8_t hourInt = [[timeStr substringWithRange:NSMakeRange(0, 2)] intValue];
    int8_t minuteInt = [[timeStr substringWithRange:NSMakeRange(3, 2)] intValue];
    
    return [NSString stringWithFormat:@"%02x%02x",hourInt,minuteInt];
}

@end


























