//
//  HLView.h
//   涂鸦
//
//  Created by 韩露露 on 15/10/30.
//  Copyright © 2015年 韩露露. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface HLView : UIView

- (BOOL)haveDraw;
- (void)setLineThickness:(CGFloat)thickness;
- (void)setColor:(UIColor *)color;
- (void)clean;
- (void)back;

@end
