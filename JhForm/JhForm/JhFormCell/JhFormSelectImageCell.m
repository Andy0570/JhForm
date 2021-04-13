//
//  JhFormSelectImageCell.m
//  JhForm
//
//  Created by Jh on 2019/1/8.
//  Copyright © 2019 Jh. All rights reserved.
//

#import "JhFormSelectImageCell.h"
#import "JhFormCellModel.h"
#import "JhFormConst.h"
#import "JhTextView.h"

@interface JhFormSelectImageCell()

#if kHasHXPhotoPicker
<HXPhotoViewDelegate>

@property (strong, nonatomic) HXPhotoView *photoView;
@property (strong, nonatomic) HXPhotoManager *photoManager;

#endif

@property (nonatomic, strong) NSArray *selectImgArr; // 选中的图片数组
@property (nonatomic, strong) UIView *bottomImageBgView; // 图片背景View
@property (nonatomic, assign) BOOL  isInit;

@end

@implementation JhFormSelectImageCell

- (void)Jh_initUI {
    self.isInit = YES;
}

- (UIView *)bottomImageBgView {
    if (!_bottomImageBgView) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:view];
        _bottomImageBgView = view;
#if kHasHXPhotoPicker
        [_bottomImageBgView addSubview:self.photoView];
#endif
    }
    return _bottomImageBgView;
}

#if kHasHXPhotoPicker
- (HXPhotoManager *)photoManager {
    if (!_photoManager) {
        NSInteger maxNum = Jh_GlobalMaxImages;
        _photoManager = [[HXPhotoManager alloc] initWithType:HXPhotoManagerSelectedTypePhoto];
        _photoManager.configuration.type = HXConfigurationTypeWXMoment;
        _photoManager.configuration.openCamera = NO; // 是否打开相机功能
        _photoManager.configuration.photoMaxNum = maxNum; // 照片最大选择数，默认 8
        _photoManager.configuration.videoMaxNum = 0; // 视频最大选择数，默认 1
        _photoManager.configuration.maxNum = maxNum; // 最大选择数
        _photoManager.configuration.selectTogether = NO; // 图片和视频是否能够同时选择 默认 NO
        _photoManager.configuration.cameraCellShowPreview = NO; // 相机cell是否显示预览
        _photoManager.configuration.photoCanEdit = YES; // 照片是否可以编辑
        _photoManager.configuration.showBottomPhotoDetail = NO; // 显示底部照片数量信息 default YES
        _photoManager.configuration.saveSystemAblum = YES; // 拍摄的 照片/视频 是否保存到系统相册，默认 NO
        _photoManager.configuration.photoStyle = Jh_ThemeType == JhThemeTypeAuto ? HXPhotoStyleDefault :(Jh_ThemeType == JhThemeTypeLight? HXPhotoStyleInvariant : HXPhotoStyleDark); // 相册风格
        [HXPhotoCommon photoCommon].requestNetworkAfter = YES;
    }
    return _photoManager;
}

- (HXPhotoView *)photoView {
    if (!_photoView) {
        _photoView = [[HXPhotoView alloc] initWithFrame:CGRectMake(Jh_ImageLeftMargin, Jh_OnePhotoViewTopMargin, Jh_OnePhotoViewWidth, Jh_ImageHeight) manager:self.photoManager];
        _photoView.outerCamera = YES; /// 是否把相机功能放在外面 默认NO
        _photoView.lineCount = Jh_ImageOneLineCount;
        _photoView.spacing = Jh_ImageMargin;
        _photoView.delegate = self;
        _photoView.addImageName = Jh_AddIcon; /// 添加按钮的图片
    }
    return _photoView;
}

#pragma mark - <HXPhotoViewDelegate>

// 当view高度改变时调用
- (void)photoView:(HXPhotoView *)photoView updateFrame:(CGRect)frame {
    self.photoView.frame = frame;
    [self layoutSubviews];
}

//  根据 photoView 来判断是哪一个选择器
- (void)photoView:(HXPhotoView *)photoView changeComplete:(NSArray<HXPhotoModel *> *)allList photos:(NSArray<HXPhotoModel *> *)photos videos:(NSArray<HXPhotoModel *> *)videos original:(BOOL)isOriginal {
    self.cellModel.Jh_imageAllList = allList;
    if (self.cellModel.Jh_selectImageType == JhSelectImageTypeImage) {
        [self getOriginalImage:photos original:isOriginal];
    } else if (self.cellModel.Jh_selectImageType == JhSelectImageTypeVideo) {
        [self getVideo:videos];
    } else {
        [self getOriginalImage:photos original:isOriginal];
        [self getVideo:videos];
    }
    [self Jh_reloadData];
}

// 获取原图
-(void)getOriginalImage:(NSArray<HXPhotoModel *> *)photos original:(BOOL)isOriginal {
    // 获取原图
    JhWeakSelf
    [photos hx_requestImageWithOriginal:isOriginal completion:^(NSArray<UIImage *> * _Nullable imageArray, NSArray<HXPhotoModel *> * _Nullable errorArray) {
        weakSelf.selectImgArr = imageArray;
        weakSelf.cellModel.Jh_imageArr = self.selectImgArr;
        [weakSelf Jh_reloadData];
    }];
}

// 获取视频
-(void)getVideo:(NSArray<HXPhotoModel *> *)videos {
    JhWeakSelf
    NSMutableArray *mArr = [NSMutableArray array];
    //导出视频地址
    for (int i=0; i< videos.count; i++) {
        HXPhotoModel *model = videos[i];
        // presetName 导出视频的质量，自己根据需求设置
        [model exportVideoWithPresetName:AVAssetExportPresetMediumQuality startRequestICloud:nil iCloudProgressHandler:nil exportProgressHandler:^(float progress, HXPhotoModel * _Nullable model) {
        } success:^(NSURL * _Nullable videoURL, HXPhotoModel * _Nullable model) {
            // 导出完成, videoURL
            //NSLog(@" videoURL %@ ",videoURL);
            [mArr addObject:videoURL];
            weakSelf.cellModel.Jh_selectVideoArr = [mArr copy];
            [weakSelf Jh_reloadData];
        } failed:nil];
    }
}

#endif

#pragma mark -- 刷新当前图片数据

- (void)Jh_reloadData {
    if (self.cellModel.Jh_imageSelectBlock) {
        self.cellModel.Jh_imageSelectBlock(self.selectImgArr);
    }
    JhWeakSelf
    [UIView performWithoutAnimation:^{
        [weakSelf.baseTableView beginUpdates];
        [weakSelf.baseTableView endUpdates];
    }];
}

#pragma mark - JhFormProtocol

- (void)Jh_configCellModel:(JhFormCellModel *)cellModel {
    [super Jh_configCellModel:cellModel];
    
#if kHasHXPhotoPicker
    self.photoManager.configuration.photoStyle = cellModel.Jh_cellThemeType == JhThemeTypeAuto ? HXPhotoStyleDefault :(cellModel.Jh_cellThemeType == JhThemeTypeLight? HXPhotoStyleInvariant : HXPhotoStyleDark);
    if (cellModel.Jh_maxImageCount) {
        self.photoManager.configuration.maxNum = cellModel.Jh_maxImageCount;
        self.photoManager.configuration.photoMaxNum = cellModel.Jh_maxImageCount;
    }
    self.photoManager.configuration.selectTogether = (cellModel.Jh_selectImageType == JhSelectImageTypeAll);
    if (cellModel.Jh_selectImageType) {
        self.photoManager.type = cellModel.Jh_selectImageType;
    }
    if (cellModel.Jh_imageNoSaveAblum){
        self.photoManager.configuration.saveSystemAblum = !cellModel.Jh_imageNoSaveAblum;
    }
    if (cellModel.Jh_videoMinimumDuration) {
        self.photoManager.configuration.videoMinimumDuration = cellModel.Jh_videoMinimumDuration;
    }
    if (cellModel.Jh_noShowAddImgBtn) {
        self.photoView.showAddCell = NO;
        self.photoView.editEnabled = NO;
    }
    if (cellModel.Jh_selectImageType == JhSelectImageTypeImage && self.isInit) {
        if (cellModel.Jh_imageArr.count) {
            [self.photoManager clearSelectedList];
            NSMutableArray *mUrlArr = @[].mutableCopy;
            for (id img in cellModel.Jh_imageArr) {
                HXPhotoModel *model ;
                if([img isKindOfClass:[UIImage class]]){
                    model = [HXPhotoModel photoModelWithImage:img];
                }
                if([img isKindOfClass:[NSString class]]){
                    model = [HXPhotoModel photoModelWithImageURL:[NSURL URLWithString:img]];
                }
                if([img isKindOfClass:[NSURL class]]){
                    model = [HXPhotoModel photoModelWithImageURL:img];
                }
                if ([img isKindOfClass:[HXPhotoModel class]]) {
                    model =img;
                }
                if(model){
                    [mUrlArr addObject:model];
                }
            }
            [self.photoManager addLocalModels:mUrlArr];
            [self.photoView refreshView];
            self.isInit = NO;
        }
    }
    if (cellModel.Jh_selectImageType != JhSelectImageTypeImage && self.isInit) {
        if(cellModel.Jh_mixImageArr.count){
            [self.photoManager clearSelectedList];
            [self.photoManager addCustomAssetModel:cellModel.Jh_mixImageArr];
            [self.photoView refreshView];
            self.isInit = NO;
        }
    }
    self.photoView.hideDeleteButton = cellModel.Jh_hideDeleteButton;
    //弹出的相册界面的设置
    UIColor *themeColor = JhBaseThemeColor;
    UIColor *navColor = [UIColor whiteColor];
    UIColor *navTitleColor = [UIColor blackColor];
    self.photoManager.configuration.navBarBackgroudColor = navColor;
    self.photoManager.configuration.navigationTitleColor= navTitleColor;
    self.photoManager.configuration.bottomViewBgColor = navColor;
    self.photoManager.configuration.themeColor = themeColor;
    self.photoManager.configuration.previewSelectedBtnBgColor = themeColor;
    self.photoManager.configuration.cameraFocusBoxColor = themeColor;
    self.photoManager.configuration.albumListViewCellSelectBgColor = JhBaseCellBgColor;
    //    self.photoManager.configuration.bottomDoneBtnTitleColor = [UIColor purpleColor];
    //    self.photoManager.configuration.cellSelectedBgColor = [UIColor redColor];
    JhWeakSelf
    self.photoManager.viewWillAppear = ^(UIViewController *viewController) {
        [weakSelf updateStatusBar:cellModel];
    };
    self.photoManager.viewWillDisappear = ^(UIViewController *viewController) {
        [weakSelf updateStatusBar:cellModel];
    };
    //    self.photoView.didCancelBlock = ^{
    //    };
    //    self.photoView.didAddCellBlock = ^(HXPhotoView * _Nonnull myPhotoView) {
    //    };
    
#endif
    
}

#if kHasHXPhotoPicker
- (void)updateStatusBar:(JhFormCellModel *)cellModel {
    if (Jh_IOS13_Later) {
        if (cellModel.Jh_cellThemeType == JhThemeTypeAuto) {
            self.photoManager.configuration.statusBarStyle = UIStatusBarStyleDefault;
        }
        if (cellModel.Jh_cellThemeType == JhThemeTypeLight) {
            self.photoManager.configuration.statusBarStyle = UIStatusBarStyleDarkContent;
        }
        if (cellModel.Jh_cellThemeType == JhThemeTypeDark) {
            self.photoManager.configuration.statusBarStyle = UIStatusBarStyleLightContent;
        }
    }
}
#endif

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.rightTextView.hidden = YES;
    if (!self.cellModel.Jh_title.length) {
        self.line.hidden = YES;
#if kHasHXPhotoPicker
        self.bottomImageBgView.frame = CGRectMake(0, 0, Jh_ScreenWidth, CGRectGetHeight(self.photoView.frame)+Jh_OnePhotoViewTopMargin*2);
#endif
    } else {
#if kHasHXPhotoPicker
        self.line.hidden = NO;
        self.line.frame = CGRectMake(Jh_LineLeftMargin, CGRectGetMaxY(self.titleLabel.frame)+Jh_Margin+Jh_LineHeight, Jh_ScreenWidth - Jh_LineLeftMargin, Jh_LineHeight);
        self.bottomImageBgView.frame = CGRectMake(0, CGRectGetMaxY(self.line.frame), Jh_ScreenWidth, CGRectGetHeight(self.photoView.frame)+Jh_OnePhotoViewTopMargin*2);
#endif
    }
    //右侧按钮
    if (self.cellModel.Jh_rightBtnWidth>0) {
        CGFloat topHeight = self.cellModel.Jh_titleHeight + Jh_Margin*2;
        CGFloat rightBtnWidth = Jh_SetValueAndDefault(self.cellModel.Jh_rightBtnWidth, 0);
        CGFloat rightBtnHeight = Jh_SetValueAndDefault(self.cellModel.Jh_rightBtnHeight, topHeight);
        CGFloat rightBtnX = Jh_ScreenWidth-Jh_RightViewLeftMargin-rightBtnWidth-Jh_RightMargin;
        CGFloat rightBtnY = self.cellModel.Jh_rightBtnHeight ? (topHeight - self.cellModel.Jh_rightBtnHeight)/2 : 0;
        self.rightBtn.Jh_x = rightBtnX;
        self.rightBtn.Jh_y = rightBtnY;
        self.rightBtn.Jh_height = rightBtnHeight;
    }
    //提示文字
    if (self.cellModel.Jh_tipInfo.length) {
        self.tipLabel.frame = CGRectMake(Jh_LeftMargin, self.cellModel.Jh_cellHeight - Jh_TipInfoTopMargin*2 - Jh_TipInfoHeight, Jh_ScreenWidth-Jh_LeftMargin*2, Jh_TipInfoHeight);
    }
    if (self.cellModel.Jh_hiddenCustomLine == YES) {
        self.line.hidden = YES;
    }
}

@end
