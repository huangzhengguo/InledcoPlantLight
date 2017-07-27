//
//  TooltipManager.h
//  InledcoPlant
//
//  Created by huang zhengguo on 2017/2/6.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TooltipManager : UIView

+ (void)showRenameBoxWithTextFieldMessage:(NSString *)text title:(NSString *)title message:(NSString *)message controller:(UIViewController *)controller saveBlock:(void (^)(NSString *saveText))saveBlock;

@end
