//
//  DeviceScanCell.h
//  InledcoPlant
//
//  Created by huang zhengguo on 2017/5/15.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^selectButtonBlock) (BOOL);

@interface DeviceScanCell : UITableViewCell

- (void)SetCellModelWithIcon:(NSString *)icon mainTitle:(NSString *)mainTitle subTitle:(NSString *)subTitle selectedFlag:(BOOL)selectedFlag;

// 点击选择按钮回调
@property(nonatomic, copy) selectButtonBlock buttonClickBlock;

@end
