//
//  TSCustomButton.m
//  Sell product
//
//  Created by Mac on 06.06.16.
//  Copyright © 2016 Tsvigun Alexandr. All rights reserved.
//

#import "TSCustomButton.h"

@implementation TSCustomButton

+ (TSCustomButton *)customButton:(CGRect)frame parentView:(UIView *)view color:(UIColor *)color image:(UIImage *)image
                           title:(NSString *)title correctValue:(NSInteger)value titleColor:(UIColor *)titleColor;
{
    TSCustomButton *button = [[TSCustomButton alloc] initWithFrame:frame];
    button.backgroundColor = color;
    [button setTitleColor:titleColor forState:UIControlStateNormal];
    [button setImage:image forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:9];
    [button setImageEdgeInsets:UIEdgeInsetsMake(- 10, 20 + value, 0, - button.titleLabel.bounds.size.width)];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(75, - 30, 50, 0)];
    [view addSubview:button];
    
    return button;
}

@end
