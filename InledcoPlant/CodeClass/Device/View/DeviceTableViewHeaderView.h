//
//  DeviceTableViewHeaderView.h
//  InledcoPlant
//
//  Created by huang zhengguo on 2017/2/3.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^buttonActionBlock) (NSInteger,BOOL,UIView *);
typedef void (^lockButtonBlock)(BOOL );
typedef void (^passButtonTagBlock) (NSInteger,BOOL,UIView *);

@interface DeviceTableViewHeaderView : UIView
@property (weak, nonatomic) IBOutlet UIView *backgroundView;

@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *lightNameLabel;

@property (weak, nonatomic) IBOutlet UIButton *lockButton;

@property (weak, nonatomic) IBOutlet UILabel *lockTitleLabel;

@property (weak, nonatomic) IBOutlet UIButton *renameButton;

@property (weak, nonatomic) IBOutlet UIButton *cycleSetButton;

@property (weak, nonatomic) IBOutlet UIButton *powerButton;

@property (weak, nonatomic) IBOutlet UIButton *manualButton;

@property (weak, nonatomic) IBOutlet UIButton *infoButton;

@property (copy, nonatomic) buttonActionBlock lockButtonAction;

@property (copy, nonatomic) passButtonTagBlock buttonPasstag;

@end
