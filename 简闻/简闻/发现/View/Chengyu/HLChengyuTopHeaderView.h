//
//  HLChengyuTopHeaderView.h
//  简闻
//
//  Created by 韩露露 on 16/5/17.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HLChengyuTopHeaderView : UITableViewHeaderFooterView

+ (instancetype)topHeaderView;
- (void)chengyu:(NSString *)chengyu pinyin:(NSString *)pinyin;

@end
