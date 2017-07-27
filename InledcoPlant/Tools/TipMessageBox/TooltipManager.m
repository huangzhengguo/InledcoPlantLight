//
//  TooltipManager.m
//  InledcoPlant
//
//  Created by huang zhengguo on 2017/2/6.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

#import "TooltipManager.h"

@implementation TooltipManager

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (void)showRenameBoxWithTextFieldMessage:(NSString *)text title:(NSString *)title message:(NSString *)message controller:(UIViewController *)controller saveBlock:(void (^)(NSString *saveText))saveBlock{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    // 添加输入文本框
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
        textField.text = text;
        textField.textAlignment = NSTextAlignmentCenter;
    }];
    
    // 添加取消按钮
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    // 添加确认按钮
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        //when you click the confirm button,do the saveBlock action
        if (saveBlock){
            
            NSArray *textFieldArray = [alertController textFields];
            UITextField *textField = [textFieldArray objectAtIndex:0];
            saveBlock(textField.text);
        }
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:confirmAction];
    
    // 弹出提示框
    [controller presentViewController:alertController animated:YES completion:nil];
}


@end
