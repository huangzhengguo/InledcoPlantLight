//
//  GroupListTableViewCell.m
//  InledcoPlant
//
//  Created by huang zhengguo on 2017/2/6.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

#import "GroupListTableViewCell.h"

@implementation GroupListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    // 设置编辑按钮不同状态的图标
    [self.editGroupButton setBackgroundImage:[UIImage imageNamed:@"equal32pt"] forState:UIControlStateNormal];
    [self.editGroupButton setBackgroundImage:[UIImage imageNamed:@"tick32pt"] forState:UIControlStateSelected];
}

- (IBAction)editGroupAction:(UIButton *)sender {
    
    // 调用Block，根据model的状态进行对应的操作
    if (self.editGroup){
        if (self.editGroupButton.isSelected == YES){
            self.editGroupButton.selected = NO;
        }else{
            self.editGroupButton.selected = YES;
        }
        self.editGroup(self.editGroupButton.selected);
    }
}

- (void)setGroupModel:(DeviceGroupModel *)groupModel{
    self.groupNameLabel.text = groupModel.groupName;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
