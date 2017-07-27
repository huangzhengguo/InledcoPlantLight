//
//  EditNameView.m
//  InledcoPlant
//
//  Created by huang zhengguo on 2017/2/7.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

#import "EditAlertView.h"

#define EDITVIEW_WIDTH 300
#define EDITVIEW_HEIGHT 160
#define CORNERRADIUS 15
#define BUTTON_HEIGHT 40

@implementation EditAlertView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithTitle:(NSString *)title{
    if (self = [super init]){
        // 背景
        self.frame = CGRectMake(0, 0, KWIDTH, KHEIGHT);
        self.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.3];
        
        // 弹出框添加到背景上面
        UIView *editView = [[UIView alloc] init];
        
        // 设置背景颜色
        editView.backgroundColor = [UIColor whiteColor];
        
        // 设置大小
        editView.frame = CGRectMake(0, 0, EDITVIEW_WIDTH, EDITVIEW_HEIGHT);
        
        // 透明度
        editView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
        
        // 设定弹出框的中心位置，和背景相同,设置屏幕中间
        [editView setCenter:self.center];

        // 设置圆角
        editView.layer.cornerRadius = CORNERRADIUS;
        
        // 添加标题label
        UILabel *titleLabel = [[UILabel alloc] init];
        
        titleLabel.text = title;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.layer.cornerRadius = CORNERRADIUS;
        titleLabel.clipsToBounds = YES;
        titleLabel.frame = CGRectMake(0, 0, EDITVIEW_WIDTH, EDITVIEW_HEIGHT / 4);
        
        // 添加标题
        [editView addSubview:titleLabel];
        
        UILabel *messageLabel = [[UILabel alloc] init];
        
        messageLabel.tag = 1001;
        messageLabel.text = @"";
        messageLabel.font = [UIFont systemFontOfSize:15];
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.textColor = [UIColor redColor];
        messageLabel.backgroundColor = [UIColor clearColor];
        messageLabel.frame = CGRectMake(0, EDITVIEW_HEIGHT / 4, EDITVIEW_WIDTH, EDITVIEW_HEIGHT / 5);

        [editView addSubview:messageLabel];
        
        // 添加编辑框
        UITextField *textField = [[UITextField alloc] init];
        
        textField.tag = 1000;
        textField.frame = CGRectMake(0, EDITVIEW_HEIGHT / 2 , EDITVIEW_WIDTH * 5 / 6, EDITVIEW_HEIGHT / 5);
        textField.textAlignment = NSTextAlignmentCenter;
        textField.center = CGPointMake(editView.frame.size.width / 2, textField.center.y);
        textField.backgroundColor = [UIColor whiteColor];
        //textField.layer.borderWidth = 1;
        textField.borderStyle = UITextBorderStyleBezel;
        //textField.layer.borderColor = [UIColor blackColor].CGColor;
        
        [editView addSubview:textField];
        
        UIButton *cancelButton = [[UIButton alloc] init];
        
        [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        cancelButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        cancelButton.frame = CGRectMake(0, editView.frame.size.height - BUTTON_HEIGHT, EDITVIEW_WIDTH / 2, BUTTON_HEIGHT);
        [cancelButton addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
        [editView addSubview:cancelButton];
        
        UIButton *confirmButton = [[UIButton alloc] init];
        
        [confirmButton setTitle:@"Confirm" forState:UIControlStateNormal];
        confirmButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [confirmButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        confirmButton.frame = CGRectMake(EDITVIEW_WIDTH / 2, editView.frame.size.height - BUTTON_HEIGHT, EDITVIEW_WIDTH / 2, BUTTON_HEIGHT);
        
        [confirmButton addTarget:self action:@selector(confirmAction:) forControlEvents:UIControlEventTouchUpInside];
        [editView addSubview:confirmButton];
        // 添加到背景视图上
        [self addSubview:editView];
    }
    
    return self;
}

#pragma mark --- 取消方法
- (void)cancelAction:(UIButton *)sender{
    if (self){
        [self removeFromSuperview];
    }
}

#pragma mark --- 确认方法
- (void)confirmAction:(UIButton *)sender{
    if (self.confirmBlock){
        NSString *result = nil;
        UITextField *textField = [self viewWithTag:1000];
        result = self.confirmBlock(textField.text);
        if (result == nil){
            [self removeFromSuperview];
        }else{
            // 显示错误提示信息
            UILabel *messageLabel = [self viewWithTag:1001];
            messageLabel.text = result;
        }
    }
}

@end
