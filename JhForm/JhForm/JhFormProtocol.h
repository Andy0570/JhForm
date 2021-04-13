//
//  JhFormProtocol.h
//  JhForm
//
//  Created by Jh on 2020/11/24.
//  Copyright © 2020 Jh. All rights reserved.
//

#import <Foundation/Foundation.h>
@class JhFormCellModel;

NS_ASSUME_NONNULL_BEGIN

@protocol JhFormProtocol <NSObject>

@required
/// 根据 Model 配置对应的 cell
- (void)Jh_configCellModel:(JhFormCellModel *)cellModel;

@optional
/// 配置cell高度，暂时没用到，使用的cellModel的Jh_cellHeight 计算高度
+ (CGFloat)Jh_configCellHeight:(JhFormCellModel *)cellModel;

@end

NS_ASSUME_NONNULL_END
