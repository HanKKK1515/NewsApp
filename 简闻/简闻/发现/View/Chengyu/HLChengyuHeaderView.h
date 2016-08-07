//
//  HLChengyuHeaderView.h
//  简闻
//
//  Created by 韩露露 on 16/5/16.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HLChengyuResult.h"

@class HLChengyuHeaderView;
@protocol HLChengyuHeaderViewDelegate <NSObject>

@optional
- (void)chengyuHeaderViewDidClickBtn:(HLChengyuHeaderView *)headerView;

@end

@interface HLChengyuHeaderView : UITableViewHeaderFooterView

@property (strong, nonatomic) HLChengyuResult *result;
@property (weak, nonatomic) id<HLChengyuHeaderViewDelegate> delegate;

+ (instancetype)headerViewWithTableView:(UITableView *)tableView;
- (void)ChangeArrow:(BOOL)close;
@end
