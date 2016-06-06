//
//  TSCustomButton.h
//  Sell product
//
//  Created by Mac on 06.06.16.
//  Copyright © 2016 Tsvigun Alexandr. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TSCustomButton : UIButton

+ (TSCustomButton *)customButton:(CGRect)frame color:(UIColor *)color image:(UIImage *)image
                           title:(NSString *)title correctOffset:(NSInteger)offset titleColor:(UIColor *)titleColor;

@end
