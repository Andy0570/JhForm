//
//  JhTextView.h
//  JhForm
//
//  Created by Jh on 2020/11/23.
//  Copyright © 2020 Jh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JhTextView : UITextView

/// 限制最大录入长度，0为不限制
@property (nonatomic, assign) NSInteger Jh_maxLength;

/// 是否显示右下角的计数文字
/// 若无最大字数限制，则只显示字数； 若有字数限制，则显示 "当前字数/最大字数"
@property (nonatomic, assign) BOOL Jh_showLengthNumber;

/// 占位符文字
@property (nonatomic, strong) NSString *Jh_placeholder;
/// 占位符文字颜色
@property (nonatomic, strong) UIColor  *Jh_placeholderColor;
/// 占位符文字字体
@property (nonatomic, assign) CGFloat Jh_placeholderFont;

/// 内边距
@property (nonatomic, assign) UIEdgeInsets Jh_textContainerInset;
/// 文本对齐方式
@property (nonatomic, assign) NSTextAlignment Jh_textAlignment;

/// 获取当前输入文字、输入状态 （ 0、开始输入；1、发生改变；2、输入完成）
@property (nonatomic,   copy) void(^Jh_cellInputBlock)(NSString *inputText, NSInteger inputState);

@end

NS_ASSUME_NONNULL_END
