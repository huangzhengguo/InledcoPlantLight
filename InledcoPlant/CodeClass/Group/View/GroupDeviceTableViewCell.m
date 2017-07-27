//
//  GroupDeviceTableViewCell.m
//  InledcoPlant
//
//  Created by huang zhengguo on 2017/2/4.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

#import "GroupDeviceTableViewCell.h"

@implementation GroupDeviceTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.rightBackgroundBiew.backgroundColor = [UIColor colorWithRed:(151.0 / 255.0) green:(174.0 / 255.0) blue:(124.0 / 255.0) alpha:1];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.rightBackgroundBiew.layer.cornerRadius = 5;
    
    // 设置按钮布局等
    self.findDeviceButton.layer.cornerRadius = self.findDeviceButton.frame.size.height / 2;
    self.deviceInfoButton.layer.cornerRadius = self.deviceInfoButton.frame.size.height / 2;
    
    // 设置check框图片
    self.checkButton.hidden = YES;
    [self.checkButton setImage:[UIImage imageNamed:@"check_empty 32pt"] forState:UIControlStateNormal];
    [self.checkButton setImage:[UIImage imageNamed:@"check32pt"] forState:UIControlStateSelected];
}

// 选择设备
- (IBAction)checkClickAction:(UIButton *)sender {
    if (self.checkButton.selected == YES){
        [self.checkButton setSelected:NO];
    }else{
        [self.checkButton setSelected:YES];
    }
    
    // 把选择框的状态传递出去
}

// 查找设备
- (IBAction)findDeviceAction:(UIButton *)sender {
}

// 查看设备信息
- (IBAction)deviceInfoAction:(UIButton *)sender {
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
