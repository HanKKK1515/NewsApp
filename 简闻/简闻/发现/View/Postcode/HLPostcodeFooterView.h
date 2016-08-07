//
//  HLPostcodeFooterView.h
//  简闻
//
//  Created by 韩露露 on 16/5/6.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HLPostcodeFooterView : UITableViewCell
@property (assign, nonatomic, readonly, getter = isActive) BOOL active;

- (void)startActive;
- (void)stopActive;
- (void)setFooterViewWithString:(NSString *)string;
+ (instancetype)postcodeFooterView;
@end
