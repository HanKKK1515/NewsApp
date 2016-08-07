//
//  HLToolBar.h
//  简闻
//
//  Created by 韩露露 on 16/6/4.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    kHLToolBarTypeBack = 1,
    kHLToolBarTypeGo,
    kHLToolBarTypeRefresh,
} HLToolBarType;

@class HLToolBar;
@protocol HLToolBarDelegate <NSObject>

@optional
- (void)toolBar:(HLToolBar *)toolBar didClickBtn:(HLToolBarType)type;

@end

@interface HLToolBar : UIView
@property (weak, nonatomic) id<HLToolBarDelegate> delegate;
@property (assign, nonatomic, getter = isEnableBack) BOOL enableBack;
@property (assign, nonatomic, getter = isEnableGo) BOOL enableGo;
@property (assign, nonatomic, getter = isRefreshing) BOOL refreshing;

+ (instancetype)toolBar;
@end
