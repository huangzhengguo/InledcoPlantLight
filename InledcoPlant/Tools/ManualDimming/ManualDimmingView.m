//
//  ManualDimmingView.m
//  InledcoPlant
//
//  Created by huang zhengguo on 2017/5/22.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

#import "ManualDimmingView.h"
#import "FGLanguageTool.h"

// 两个颜色滑动条之间的间隙
#define SPACEBETWEENCOLOR 0

// 滑动条最大值和最小值
#define SLIDERMAXVALUE 1000
#define SLIDERMINVALUE 1

// 发送命令的最小时间间隔
#define SENDCOMMANDINTERVAL 50

// 色块 颜色标题 滑动条 百分比占用宽度百分比
#define COLOR_LABEL_PERCENT 0.1f
#define COLORNAME_LABEL_PERCENT 0.2f
#define COLORSLIDER_LABEL_PERCENT 0.55f
#define COLORPERCENT_LABEL_PERCENT 0.15f

@interface ManualDimmingView()

// 颜色名称数组
@property(nonatomic, strong) NSArray *colorTitleArray;

// 颜色数组
@property(nonatomic, strong) NSArray *colorArray;

// 计时器
@property(nonatomic, assign) UInt64 lastDimmSendTime;

@end

@implementation ManualDimmingView

- (NSMutableArray *)colorSliderArray{
    if (_colorSliderArray == nil){
        self.colorSliderArray = [NSMutableArray array];
    }
    return _colorSliderArray;
}

- (NSMutableArray *)colorPercentLabelArray{
    if (_colorPercentLabelArray == nil){
        self.colorPercentLabelArray = [NSMutableArray array];
    }
    return _colorPercentLabelArray;
}

- (instancetype)initWithFrame:(CGRect)frame colorPercentArray:(NSArray *)colorPercentArray textColor:(UIColor *)textColor{
    if (self = [super initWithFrame:frame]){
        self.frame = frame;
        // 获取颜色通道数量
        NSInteger channelNum = colorPercentArray.count;
        
        // 根据颜色通道数量获取颜色标题及颜色值
        if (colorPercentArray.count == 3){
            self.colorTitleArray = @[FGGetStringWithKey(@"red"),FGGetStringWithKey(@"green"),FGGetStringWithKey(@"blue")];
            self.colorArray = @[[UIColor redColor],[UIColor greenColor],[UIColor blueColor]];
        }else if (colorPercentArray.count == 4){
            self.colorTitleArray = FOURCHANNEL_TITLE_ARRAY;
            self.colorArray = FOURCHANNEL_COLOR_ARRAY;
        }else if (colorPercentArray.count == 5){
            self.colorTitleArray = FIVECHANNEL_TITLE_ARRAY;
            self.colorArray = FIVECHANNEL_COLOR_ARRAY;
        }else {
            self.colorTitleArray = FOURCHANNEL_TITLE_ARRAY;
            self.colorArray = FOURCHANNEL_COLOR_ARRAY;
        }
        
        // 色条 颜色名称label 百分比label高度相同
        float colorHeight = self.frame.size.height / (float)channelNum;
        
        // 根据通道数量创建控件
        float yHeight = 0.0f;
        for (int i=0; i<channelNum; i++) {
            // 滑动条 颜色名称 百分比的Y的值
            yHeight = self.frame.size.height / (float)channelNum * (float)i;
            
            // 颜色值
            UIColor *currentColor = [self.colorArray objectAtIndex:i];
            
            // 创建色块
            UILabel *colorLabel = [[UILabel alloc] init];
            
            colorLabel.frame = CGRectMake(10.0f, ((float)(3 * i+1)) * 20.0f, 20.0f, 20.0f);
            colorLabel.backgroundColor = currentColor;
            
            [self addSubview:colorLabel];
            
            // 创建颜色标题
            UILabel *colorTitleLabel = [[UILabel alloc] init];
            
            colorTitleLabel.frame = CGRectMake(colorLabel.frame.origin.x + colorLabel.frame.size.width + 10.0f, yHeight, COLORNAME_LABEL_PERCENT * self.frame.size.width, colorHeight);
            colorTitleLabel.textColor = textColor;
            colorTitleLabel.adjustsFontSizeToFitWidth = YES;
            colorTitleLabel.text = [self.colorTitleArray objectAtIndex:i];
            
            [self addSubview:colorTitleLabel];
            
            // 创建百分比
            UILabel *colorPercentLabel = [[UILabel alloc] init];
            
            colorTitleLabel.adjustsFontSizeToFitWidth = YES;
            colorPercentLabel.textColor = textColor;
            colorPercentLabel.frame = CGRectMake((1.0 - COLORPERCENT_LABEL_PERCENT) * self.frame.size.width, yHeight, COLORPERCENT_LABEL_PERCENT * self.frame.size.width, colorHeight);
            colorPercentLabel.text = [NSString stringWithFormat:@"%@%%",@([[colorPercentArray objectAtIndex:i] integerValue] / 10)];
            
            [self.colorPercentLabelArray addObject:colorPercentLabel];
            [self addSubview:colorPercentLabel];
            
            // 创建滑动条
            UISlider *colorSlider = [[UISlider alloc] init];
            
            // 滑动条颜色
            colorSlider.tintColor = currentColor;
            
            // 滑动条tag值，依次对应每种颜色:从0开始计数
            colorSlider.tag = 1000 + i;
            
            // 添加滑动事件
            [colorSlider addTarget:self action:@selector(colorSliderChange:) forControlEvents:UIControlEventValueChanged];
            [colorSlider addTarget:self action:@selector(colorSliderChangeEnd:) forControlEvents:UIControlEventTouchUpOutside];
            
            // 最大值 最小值
            colorSlider.minimumValue = 0.0f;
            colorSlider.maximumValue = 1000.0f;
            
            colorSlider.value = (float)[[colorPercentArray objectAtIndex:i] floatValue];
            colorSlider.frame = CGRectMake(colorTitleLabel.frame.origin.x + colorTitleLabel.frame.size.width + 5, yHeight, self.frame.size.width - colorTitleLabel.frame.origin.x - colorTitleLabel.frame.size.width - 5 - colorPercentLabel.frame.size.width, colorHeight);
            
            [self.colorSliderArray addObject:colorSlider];
            [self addSubview:colorSlider];
            
            // 使色块和 颜色标题 滑动条 百分比label保持在相同位置
            colorLabel.center = CGPointMake(colorLabel.center.x, colorSlider.center.y);
        }
    }
    
    return self;
}

#pragma mark --- 滑动条滑动事件
- (void)colorSliderChange:(UISlider *)sender{
    // 设置对应百分比的值
    UILabel *colorPercentLabel = [self.colorPercentLabelArray objectAtIndex:(sender.tag - 1000)];
    
    colorPercentLabel.text = [NSString stringWithFormat:@"%.0f%%",sender.value / 10];
    
    // 需要调用block
    if (self.colorDimmingBlock){
        // 这里需要间隔一定的时间再次调用，不能连续发送命令
        self.colorDimmingBlock(sender.tag, sender.value);
    }
}

#pragma mark --- 自动模式设置
- (void)colorSliderChangeEnd:(UISlider *)sender{
    // 需要调用block
    if (self.colorDimmingEndBlock){
        // 这里需要间隔一定的时间再次调用，不能连续发送命令
        self.colorDimmingEndBlock(sender.tag, sender.value);
    }
}

#pragma mark --- 根据数据更新视图
- (void)updateManualDimmingViewWith:(NSArray *)colorPercentArray{
    // 更新控件的显示
    for (int i=0; i<colorPercentArray.count; i++) {
        UISlider *colorSlider = [self.colorSliderArray objectAtIndex:i];
        UILabel *percentLabel = [self.colorPercentLabelArray objectAtIndex:i];
        
        colorSlider.value = (float)[[colorPercentArray objectAtIndex:i] floatValue];
        percentLabel.text = [NSString stringWithFormat:@"%@%%",@([[colorPercentArray objectAtIndex:i] integerValue] / 10)];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
