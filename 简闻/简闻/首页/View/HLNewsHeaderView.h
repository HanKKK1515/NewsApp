//
//  HLNewsHeaderView.h
//  简闻
//
//  Created by 韩露露 on 16/8/6.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HLNewsHeaderView;
@protocol HLNewsHeaderViewDelegate <NSObject>

@optional
- (void)headerView:(HLNewsHeaderView *)headerView didSelectItem:(NSUInteger)item;

@end

@interface HLNewsHeaderView : UITableViewHeaderFooterView

@property (weak, nonatomic) id<HLNewsHeaderViewDelegate> delegate;
@property (strong, nonatomic) NSArray *icons;

+ (instancetype)headerView;

@end
