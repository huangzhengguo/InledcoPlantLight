//
//  FGLanguageTool.m
//  MultiplyLanguageSetting
//
//  Created by huang zhengguo on 2016/11/22.
//  Copyright © 2016年 huang zhengguo. All rights reserved.
//

#import "AppDelegate.h"
#import "FGLanguageTool.h"

//用来在用户配置中保存语言的标记
#define LANGUAGE_SET_FLAG @"language_set_flag"

//支持的语言宏
//英文
#define LANGUAGE_ENGLISH @"en"

//法文
#define LANGUAGE_FRENCH @"fr"

//法文
#define LANGUAGE_GERMAN @"de"

@interface FGLanguageTool()

@property (nonatomic, strong) NSBundle *bundle;

@property (nonatomic, copy) NSString *language;

@end

@implementation FGLanguageTool

+ (id)shareInstance{
    
    static FGLanguageTool *shareModel;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        shareModel = [[FGLanguageTool alloc] init];
    });
    
    return shareModel;
}

- (instancetype)init{
    
    self = [super init];
    if (self){
        
        [self initLanguage];
    }
    
    return self;
}

- (void)initLanguage{
    
    //获取用户设置
    NSString *tmp = [[NSUserDefaults standardUserDefaults] objectForKey:LANGUAGE_SET_FLAG];
    NSString *path;
    
    if (!tmp){
        
        tmp = [self getCurrentLanguage];
    }
    
    self.language = tmp;
    //获取资源文件的路径
    path = [[NSBundle mainBundle] pathForResource:self.language ofType:@"lproj"];
    self.bundle = [NSBundle bundleWithPath:path];
}

- (NSString *)getCurrentLanguage{
    
    NSString *tmp = [[NSUserDefaults standardUserDefaults] objectForKey:LANGUAGE_SET_FLAG];
    
    if (!tmp){
        
        NSArray *languageArray = [NSLocale preferredLanguages];
        /* if ([languageArray[0] isEqualToString:@"en-CN"]){
            
            tmp = LANGUAGE_ENGLISH;
        }else */
        
        //获取系统偏好设置的语言，
        if ([languageArray[0] isEqualToString:@"fr-CN"] || [languageArray[0] isEqualToString:@"fr-FR"] || [languageArray[0] isEqualToString:@"fr-BE"] || [languageArray[0] isEqualToString:@"fr-CA"] || [languageArray[0] isEqualToString:@"fr-CH"]){
            
            tmp = LANGUAGE_FRENCH;
        }else if ([languageArray[0] isEqualToString:@"de-CN"] || [languageArray[0] isEqualToString:@"de-AT"] || [languageArray[0] isEqualToString:@"de-DE"] || [languageArray[0] isEqualToString:@"de-CH"]){
            
            tmp = LANGUAGE_GERMAN;
        }else{
            
            //其它不支持的语言设置统一使用英文
            tmp = LANGUAGE_ENGLISH;
        }
    }
    
    return tmp;
}

- (NSString *)getStringForKeyWithKey:(NSString *)key{
    
    return [self getStringForKey:key withTable:nil];
}

- (NSString *)getStringForKey:(NSString *)key withTable:(NSString *)table{
    
    if (self.bundle){
        
        return NSLocalizedStringFromTableInBundle(key, table, self.bundle, @"");
    }
    
    return NSLocalizedStringFromTable(key, table, @"");
}

- (void)setNewLanguage:(NSString *)language{
    
    //判断语言设置和当前的用户设置是否相同，如果相同的话，直接返回
    if ([language isEqualToString:self.language]){
        
        return;
    }
    
    //判断设置的语言是否支持，如果支持，则设置；否则直接返回
    if ([language isEqualToString:LANGUAGE_ENGLISH] || [language isEqualToString:LANGUAGE_FRENCH] || [language isEqualToString:LANGUAGE_GERMAN]){
        
        NSString *path = [[NSBundle mainBundle] pathForResource:language ofType:@"lproj"];
        self.bundle = [NSBundle bundleWithPath:path];
    }else{
        //如果出现不支持的语言设置，直接返回
        return;
    }
    
    self.language = language;
    [[NSUserDefaults standardUserDefaults] setObject:language forKey:LANGUAGE_SET_FLAG];
    [[NSUserDefaults standardUserDefaults] synchronize];
    //重置根视图控制器
    [self resetRootViewController];
}

/*
 * 该方法根据不同的App架构实现
 */
- (void)resetRootViewController{
    
    //获取应用程序代理
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //获取分镜
    UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    //获取导航控制器
    UINavigationController *rootNav = [stroyBoard instantiateViewControllerWithIdentifier:@"deviceNav"];
    UINavigationController *settingNav = [stroyBoard instantiateViewControllerWithIdentifier:@"settingNav"];
    UITabBarController *tabVC = (UITabBarController *)appDelegate.window.rootViewController;
    //重置导航控制器
    tabVC.viewControllers = @[rootNav,settingNav];
}

@end
