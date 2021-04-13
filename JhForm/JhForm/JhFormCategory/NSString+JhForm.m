//
//  NSString+JhForm.m
//  JhForm
//
//  Created by Jh on 2019/1/10.
//  Copyright © 2019 Jh. All rights reserved.
//

#import "NSString+JhForm.h"

@implementation NSString (JhForm)

- (NSString *)Jh_addUnit:(NSString *)unit {
    if ([self isEqualToString:@""] || [unit isEqualToString:@""]) {
        return self;
    }
    return [NSString stringWithFormat:@"%@ %@", self, unit];
}

- (CGSize)Jh_sizeWithFontSize:(CGFloat)fontSize maxSize:(CGSize)maxSize {
    CGSize textSize = [self boundingRectWithSize:maxSize
                                         options:(NSStringDrawingUsesLineFragmentOrigin |
                                                  NSStringDrawingUsesFontLeading)
                                      attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]}
                                         context:nil].size;
    return CGSizeMake(ceil(textSize.width), ceil(textSize.height));
}

// 一串字符在固定宽度下，正常显示所需要的高度 method
+ (CGFloat)Jh_autoHeightWithString:(NSString *)string
                             width:(CGFloat)width
                              font:(NSInteger)font
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{
        NSFontAttributeName: [UIFont systemFontOfSize:font],
        NSParagraphStyleAttributeName: paragraphStyle
    };
    
    CGSize textSize = [string boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                           options:(NSStringDrawingUsesLineFragmentOrigin |
                                                    NSStringDrawingUsesFontLeading)
                                        attributes:attributes
                                           context:nil].size;
    return ceil(textSize.height);
}

// 一串字符在一行中正常显示所需要的宽度 method
+ (CGFloat)Jh_autoWidthWithString:(NSString *)string font:(NSInteger)font {
    CGSize textSize = [string boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
                                           options:(NSStringDrawingUsesLineFragmentOrigin |
                                                    NSStringDrawingUsesFontLeading)
                                        attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:font]}
                                           context:nil].size;
    return ceil(textSize.width);
}

@end
