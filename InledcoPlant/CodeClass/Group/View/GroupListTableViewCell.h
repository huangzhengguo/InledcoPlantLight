//
//  GroupListTableViewCell.h
//  InledcoPlant
//
//  Created by huang zhengguo on 2017/2/6.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceGroupModel.h"

typedef void (^editGroupBlock) (BOOL);

@interface GroupListTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;

@property (weak, nonatomic) IBOutlet UIButton *editGroupButton;

@property (copy, nonatomic) editGroupBlock editGroup;

@property (nonatomic, strong) DeviceGroupModel *groupModel;

@end
