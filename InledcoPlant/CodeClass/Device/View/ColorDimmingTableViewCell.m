//
//  ColorDimmingTableViewCell.m
//  InledcoPlant
//
//  Created by huang zhengguo on 2017/5/22.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

#import "ColorDimmingTableViewCell.h"
#import "ManualDimmingView.h"

@implementation ColorDimmingTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
}

- (instancetype)initWithChannelNum:(NSInteger)channelNum{
    if (self = [super init]){
        // 根据路数创建调光界面
        NSMutableArray *colorPercentArray = [NSMutableArray arrayWithCapacity:channelNum];
        for (int i=0; i<channelNum; i++) {
            [colorPercentArray addObject:@(100)];
        }
        ManualDimmingView *manualDimmingView = [[ManualDimmingView alloc] initWithFrame:CGRectMake(8, 0, KWIDTH - 16, 500.0f) colorPercentArray:colorPercentArray textColor:[UIColor blackColor]];
        
        manualDimmingView.backgroundColor = [UIColor lightGrayColor];
        // 手动调光
        manualDimmingView.colorDimmingBlock = ^(NSInteger tag, float colorValue) {
            if (self.passColorValueBlock){
                self.passColorValueBlock(tag, colorValue);
            }
        };
        
        [self.contentView addSubview:manualDimmingView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
