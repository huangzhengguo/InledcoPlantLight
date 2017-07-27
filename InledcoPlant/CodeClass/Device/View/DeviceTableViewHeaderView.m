//
//  DeviceTableViewHeaderView.m
//  InledcoPlant
//
//  Created by huang zhengguo on 2017/2/3.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

#import "DeviceTableViewHeaderView.h"

#define EDGEINSERT 10.0f

@implementation DeviceTableViewHeaderView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)init{
    if (self=[super init]){
        self = [[[NSBundle mainBundle] loadNibNamed:@"DeviceTableViewHeaderView" owner:self options:nil] lastObject];
        
        // 初始化界面
        self.backgroundView.layer.cornerRadius = 5;
        self.backgroundView.backgroundColor = [UIColor colorWithRed:(151.0f/255.0f) green:(174.0f/255.0f) blue:(124.0f/255.0f) alpha:1];
        
        // 初始化按钮不可用
        self.renameButton.enabled = false;
        self.cycleSetButton.enabled = false;
        self.powerButton.enabled = false;
        self.manualButton.enabled = false;
        
        // 设置解锁按钮图片
        [self.lockButton setSelected:YES];
        [self.lockButton setImage:[UIImage imageNamed:@"lock.png"] forState:UIControlStateSelected];
        [self.lockButton setImage:[UIImage imageNamed:@"unlock.png"] forState:UIControlStateNormal];
        self.lockButton.imageEdgeInsets = UIEdgeInsetsMake(EDGEINSERT / 2, EDGEINSERT / 2, EDGEINSERT / 2, EDGEINSERT / 2);
        
        // 设置按钮图片
        [self.renameButton setImage:[UIImage imageNamed:@"edit.png"] forState:UIControlStateNormal];
        [self.renameButton setImage:[UIImage imageNamed:@"editdisable.png"] forState:UIControlStateDisabled];
        self.renameButton.imageEdgeInsets = UIEdgeInsetsMake(EDGEINSERT, EDGEINSERT, EDGEINSERT, EDGEINSERT);
        [self.cycleSetButton setImage:[UIImage imageNamed:@"timer.png"] forState:UIControlStateNormal];
        [self.cycleSetButton setImage:[UIImage imageNamed:@"timerdisable.png"] forState:UIControlStateDisabled];
        self.cycleSetButton.imageEdgeInsets = UIEdgeInsetsMake(EDGEINSERT, EDGEINSERT, EDGEINSERT, EDGEINSERT);
        
        // 开关按钮还要设置打开和关闭状态对应的图片
        // 关闭状态
        [self.powerButton setImage:[UIImage imageNamed:@"poweroff.png"] forState:UIControlStateNormal];
        [self.powerButton setImage:[UIImage imageNamed:@"powerdisable.png"] forState:UIControlStateDisabled];
        // 打开状态
        [self.powerButton setImage:[UIImage imageNamed:@"poweron.png"] forState:UIControlStateSelected];
        self.powerButton.imageEdgeInsets = UIEdgeInsetsMake(EDGEINSERT, EDGEINSERT, EDGEINSERT, EDGEINSERT);
        
        [self.manualButton setImage:[UIImage imageNamed:@"manual.png"] forState:UIControlStateNormal];
        [self.manualButton setImage:[UIImage imageNamed:@"manualdisable.png"] forState:UIControlStateDisabled];
        self.manualButton.imageEdgeInsets = UIEdgeInsetsMake(EDGEINSERT, EDGEINSERT, EDGEINSERT, EDGEINSERT);
        
        // 初始化按钮形状
        self.renameButton.layer.cornerRadius = self.renameButton.frame.size.height / 2;
        self.cycleSetButton.layer.cornerRadius = self.cycleSetButton.frame.size.height / 2;
        self.powerButton.layer.cornerRadius = self.powerButton.frame.size.height / 2;
        self.manualButton.layer.cornerRadius = self.manualButton.frame.size.height / 2;
        self.lockButton.layer.cornerRadius = self.lockButton.frame.size.height / 2;
        self.infoButton.layer.cornerRadius = self.infoButton.frame.size.height / 2;
    }
    
    return self;
}

#pragma mark --- 各个按钮事件
- (IBAction)lockClickAction:(id)sender {
    // 这里实现重命名 自动设置 开关 手动设置的切换
    if (_buttonPasstag){
        if (self.lockButtonAction){
            UIButton *lockDeviceButton = (UIButton *)sender;
            self.lockButtonAction(lockDeviceButton.tag,lockDeviceButton.selected,self);
            self.buttonPasstag(lockDeviceButton.tag,lockDeviceButton.selected,self);
        }
    }
}

- (IBAction)renameClickAction:(id)sender {
    if (self.buttonPasstag){
        UIButton *button = (UIButton *)sender;
        self.buttonPasstag(button.tag,button.selected,self);
    }
}

- (IBAction)cyclesetClickAction:(id)sender {
    if (self.buttonPasstag){
        UIButton *button = (UIButton *)sender;
        self.buttonPasstag(button.tag,button.selected,self);
    }
}

- (IBAction)powerClickAction:(id)sender {
    if (self.buttonPasstag){
        UIButton *button = (UIButton *)sender;
        self.buttonPasstag(button.tag,button.selected,self);
    }
}

- (IBAction)manualClickAction:(id)sender {
    if (self.buttonPasstag){
        UIButton *button = (UIButton *)sender;
        self.buttonPasstag(button.tag,button.selected,self);
    }
}

- (IBAction)infoClickAction:(id)sender {
    NSLog(@"infoClick");
}
@end
