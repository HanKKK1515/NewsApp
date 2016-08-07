//
//  HLChengyuHeaderView.m
//  简闻
//
//  Created by 韩露露 on 16/5/16.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import "HLChengyuHeaderView.h"

@interface HLChengyuHeaderView ()
@property (weak, nonatomic) IBOutlet UIImageView *arrowView;
@property (weak, nonatomic) IBOutlet UILabel *titleView;

- (IBAction)headerViewClick;
@end

@implementation HLChengyuHeaderView

+ (instancetype)headerViewWithTableView:(UITableView *)tableView {
    static NSString *ID = @"headerView";
    return [tableView dequeueReusableHeaderFooterViewWithIdentifier:ID];
}

- (void)setResult:(HLChengyuResult *)result {
    _result = result;
    self.titleView.text = [result.key substringFromIndex:1];
}

- (IBAction)headerViewClick {
    self.result.close = !self.result.isClose;
    if ([self.delegate respondsToSelector:@selector(chengyuHeaderViewDidClickBtn:)]) {
        [self.delegate chengyuHeaderViewDidClickBtn:self];
    }
}

- (void)ChangeArrow:(BOOL)close {
    if (close) {
        self.arrowView.image = [UIImage imageNamed:@"navigationbar_arrow_up"];
    } else {
        self.arrowView.image = [UIImage imageNamed:@"navigationbar_arrow_down"];
    }
}
//- (void)didMoveToSuperview {
//    if (self.isClose) {
//        self.arrowView.image = [UIImage imageNamed:@"navigationbar_arrow_up"];
//    } else {
//        self.arrowView.image = [UIImage imageNamed:@"navigationbar_arrow_down"];
//    }
//    [self layoutSubviews];
//}

//- (void)willRemoveSubview:(UIView *)subview {
//    if ([subview isKindOfClass:[UIImageView class]]) {
//        UIImageView *arrow = (UIImageView *)subview;
//        if (self.isClose) {
//            arrow.image = [UIImage imageNamed:@"navigationbar_arrow_up"];
//        } else {
//            arrow.image = [UIImage imageNamed:@"navigationbar_arrow_down"];
//        }
//        [self layoutSubviews];
//    }
//}

//- (void)willMoveToSuperview:(UIView *)newSuperview {
//    if (self.isClose) {
//        self.arrowView.image = [UIImage imageNamed:@"navigationbar_arrow_up"];
//    } else {
//        self.arrowView.image = [UIImage imageNamed:@"navigationbar_arrow_down"];
//    }
//    [self layoutSubviews];
//}

@end
