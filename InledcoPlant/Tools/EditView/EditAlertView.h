//
//  EditNameView.h
//  InledcoPlant
//
//  Created by huang zhengguo on 2017/2/7.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditAlertView : UIView

- (instancetype)initWithTitle:(NSString *)title;

@property (nonatomic, copy) NSString * (^confirmBlock)(NSString *);

@end
