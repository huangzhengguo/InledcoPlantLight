//
//  FGLanguageTool.h
//  MultiplyLanguageSetting
//
//  Created by huang zhengguo on 2016/11/22.
//  Copyright © 2016年 huang zhengguo. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 * 为了方便使用定义宏，参数为key和table
 */
#define FGGetStringWithKeyFromTable(key,tbl) [[FGLanguageTool shareInstance] getStringForKey:key withTable:tbl]

/*
 * table使用默认值nil的宏，更方便获取对应语言字符串
 */
#define FGGetStringWithKey(key) [[FGLanguageTool shareInstance] getStringForKeyWithKey:key]

@interface FGLanguageTool : NSObject

/**
 *  单例类
 */
+ (id)shareInstance;

/**
 *  get the current system current language
 *  Default: English Language.
 *  @return return the system current language
 */
- (NSString *)getCurrentLanguage;

/**
 *  使用默认的table参数获取当前用户的语言设置
 *  @param key 资源文件中定义的键
 *  @return 返回指定key对应的值
 */
- (NSString *)getStringForKeyWithKey:(NSString *)key;

/**
 * 返回table中指定的key的值
 * @return 返回table中指定的key的值
 */
- (NSString *)getStringForKey:(NSString *)key withTable:(NSString *)table;

/**
 * 返回table中指定的key的值
 * @param language The language will be to set to the APP.
 */
- (void)setNewLanguage:(NSString *)language;

@end
