//
//  GlobalHeader.h
//  InledcoPlant
//
//  Created by huang zhengguo on 2017/2/6.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

#ifndef GlobalHeader_h
#define GlobalHeader_h

/* 设备屏幕宽高 */
#define KWIDTH [UIScreen mainScreen].bounds.size.width
#define KHEIGHT [UIScreen mainScreen].bounds.size.height

/* 打印宏 */
#define KMYLOG(...) NSLog(__VA_ARGS__)

// 默认分组名称
#define DEFAULT_GROUPNAME @"A1"

// 需要创建的数据库表
// 分组信息表
#define DEVICE_GROUP_TABLE @"DEVICE_GROUP_TABLE"
#define DEVICE_GROUP_NAME @"DEVICE_GROUP_NAME"
#define DEVICE_GROUP_FREE_ONE @"DEVICE_GROUP_FREE_ONE"
#define DEVICE_GROUP_FREE_TWO @"DEVICE_GROUP_FREE_TWO"
#define DEVICE_GROUP_FREE_THREE @"DEVICE_GROUP_FREE_THREE"

// 设备信息表
#define DEVICE_TABLE @"DEVICE_TABLE"
#define DEVICE_GROUPNAME @"DEVICE_GROUPNAME"
#define DEVICE_NAME @"DEVICE_NAME"
#define DEVICE_TYPECODE @"DEVICE_TYPECODE"
#define DEVICE_UUID @"DEVICE_UUID"

// 配置信息表
#define DEVICE_CONFIGURATION_TABLE @"DEVICE_CONFIGURATION_TABLE"
#define DEVICE_CONFIGURATION_DEVICENAME @"DEVICE_CONFIGURATION_DEVICENAME"

// 定义设备编码

// 定义四路五路标题数组和颜色数组
// 四路
#define FOURCHANNEL_TITLE_ARRAY (@[FGGetStringWithKey(@"Red"),FGGetStringWithKey(@"Green"),FGGetStringWithKey(@"Blue"),FGGetStringWithKey(@"White")])
#define FOURCHANNEL_COLOR_ARRAY (@[[UIColor redColor],[UIColor greenColor],[UIColor blueColor],[UIColor whiteColor]])

// 五路
#define FIVECHANNEL_TITLE_ARRAY (@[FGGetStringWithKey(@"Pink"),FGGetStringWithKey(@"Blue"),FGGetStringWithKey(@"ColdWhite"),FGGetStringWithKey(@"PureWhite"),FGGetStringWithKey(@"WarmWhite")])
#define FIVECHANNEL_COLOR_ARRAY (@[[UIColor redColor],[UIColor blueColor],[UIColor colorWithRed:195.0f / 255.0f green:201.0f / 255.0f blue:255.0f / 255.0f alpha:1.0],[UIColor colorWithRed:255.0f / 255.0f green:223.0f / 255.0f blue:184.0f / 255.0f alpha:1.0],[UIColor colorWithRed:255.0f / 255.0f green:185.0f / 255.0f blue:105.0f / 255.0f alpha:1.0]])

#endif /* GlobalHeader_h */
