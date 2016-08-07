//
//  HLRobotToolBars.h
//  简闻
//
//  Created by 韩露露 on 16/5/26.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HLRobotToolBar;
@protocol HLRobotToolBarDelegate <NSObject>

@optional
- (void)robotToolBar:(HLRobotToolBar *)bar text:(NSString *)text;

@end

@interface HLRobotToolBar : UIView
@property (weak, nonatomic) id<HLRobotToolBarDelegate> delegate;
@property (copy, readonly, nonatomic) NSString *text;

- (void)toolBarBecomeFirstResponder;
- (void)toolBarResignFirstResponder;
- (void)clearText;
@end
