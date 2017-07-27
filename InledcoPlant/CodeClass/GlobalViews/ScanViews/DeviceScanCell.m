//
//  DeviceScanCell.m
//  InledcoPlant
//
//  Created by huang zhengguo on 2017/5/15.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

#import "DeviceScanCell.h"

@interface DeviceScanCell()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *mainTitleLabel;
@property (nonatomic, strong) UILabel *subTitleLabel;
@property (nonatomic, strong) UIButton *selectButton;

@end

@implementation DeviceScanCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)init{
    if (self = [super init]){
        [self SetViews];
    }
    return self;
}

- (void)SetViews{
    self.iconImageView = [[UIImageView alloc] init];
    self.mainTitleLabel = [[UILabel alloc] init];
    self.subTitleLabel = [[UILabel alloc] init];
    self.selectButton = [[UIButton alloc] init];
    
    self.iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.mainTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.subTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.selectButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.selectButton setImage:[UIImage imageNamed:@"check.png"] forState:UIControlStateSelected];
    [self.selectButton setImage:[UIImage imageNamed:@"uncheck.png"] forState:UIControlStateNormal];
    [self.selectButton addTarget:self action:@selector(selectButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.mainTitleLabel];
    [self.contentView addSubview:self.subTitleLabel];
    [self.contentView addSubview:self.selectButton];
    
    // 手动代码约束
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.iconImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0f constant:5]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.iconImageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0f constant:5]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.iconImageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0f constant:-5]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.iconImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.iconImageView attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.mainTitleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0f constant:5]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.mainTitleLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.iconImageView attribute:NSLayoutAttributeRight multiplier:1.0f constant:5]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.mainTitleLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.selectButton attribute:NSLayoutAttributeLeft multiplier:1.0f constant:-5]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.mainTitleLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.subTitleLabel  attribute:NSLayoutAttributeTop multiplier:1.0f constant:-5.0f]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.subTitleLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0f constant:-5]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.subTitleLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.iconImageView attribute:NSLayoutAttributeRight multiplier:1.0f constant:5]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.subTitleLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.selectButton attribute:NSLayoutAttributeLeft multiplier:1.0f constant:-5]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.subTitleLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.mainTitleLabel attribute:NSLayoutAttributeHeight multiplier:0.6f constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.selectButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0f constant:5]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.selectButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0f constant:-5]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.selectButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0f constant:-5]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.selectButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.selectButton attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0]];
}

- (void)SetCellModelWithIcon:(NSString *)icon mainTitle:(NSString *)mainTitle subTitle:(NSString *)subTitle selectedFlag:(BOOL)selectedFlag{
    if (icon != nil){
        _iconImageView.image = [UIImage imageNamed:icon];
    }
    
    if (mainTitle != nil){
        _mainTitleLabel.text = mainTitle;
    }
    
    if (subTitle != nil){
        _subTitleLabel.text = subTitle;
    }
    
    _selectButton.selected = selectedFlag;
}

- (void)selectButtonAction:(UIButton *)sender{
    [sender setSelected:!sender.selected];
    if (self.buttonClickBlock){
        self.buttonClickBlock(sender.selected);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
