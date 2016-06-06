//
//  NSString+TSFormattedStingPrice.m
//  Sell product
//
//  Created by Mac on 05.06.16.
//  Copyright © 2016 Tsvigun Alexandr. All rights reserved.
//

#import "NSString+TSFormattedStingPrice.h"

@implementation NSString (TSFormattedStingPrice)

+ (NSString *)formattedStringPrice:(NSString *)currentPrice
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    NSString *tempPrice = nil;
    
    if ([currentPrice hasPrefix:@"$"]) {
        tempPrice = [currentPrice substringFromIndex:1];
    } else {
        tempPrice = currentPrice;
    }
    
    NSNumber *myNumber = [formatter numberFromString:tempPrice];
    NSString *intermediateString = [formatter stringFromNumber:myNumber];
    NSString *formattedString = nil;
    
    if ([intermediateString rangeOfString:@"$"].location != NSNotFound) {
        formattedString = [NSString stringWithFormat:@"%@", intermediateString];
    } else {
        formattedString = [NSString stringWithFormat:@"$%@", intermediateString];
    }
    
    return formattedString;
}

@end
