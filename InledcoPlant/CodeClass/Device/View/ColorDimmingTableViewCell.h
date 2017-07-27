//
//  ColorDimmingTableViewCell.h
//  InledcoPlant
//
//  Created by huang zhengguo on 2017/5/22.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^passColorValue) (NSInteger,float);

@interface ColorDimmingTableViewCell : UITableViewCell

- (instancetype)initWithChannelNum:(NSInteger)channelNum;

// 传递颜色信息block
@property(nonatomic, copy) passColorValue passColorValueBlock;

@end
