//
//  HLView.m
//   涂鸦
//
//  Created by 韩露露 on 15/10/30.
//  Copyright © 2015年 韩露露. All rights reserved.
//

#import "HLView.h"

@interface HLView ()

@property (strong, nonatomic) NSMutableArray *paths;
@property (assign, nonatomic) CGFloat thickness;
@property (strong, nonatomic) UIColor *currentColor;

@end

@implementation HLView

- (NSMutableArray *)paths {
    if(_paths == nil) {
        _paths = [NSMutableArray array];
    }
    return _paths;
}

- (CGFloat)thickness {
    if(!_thickness) {
        _thickness = 10;
    }
    return _thickness;
}

- (UIColor *)currentColor {
    if(!_currentColor) {
        self.currentColor = [UIColor blueColor];
    }
    return _currentColor;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:touch.view];
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineWidth = self.thickness;
    [path moveToPoint:currentPoint];
    [self.paths addObject:path];
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:touch.view];
    UIBezierPath *path = [self.paths lastObject];
    [path addLineToPoint:currentPoint];
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self touchesMoved:touches withEvent:event];
}

- (void)drawRect:(CGRect)rect {
    for(UIBezierPath *path in self.paths) {
        path.lineJoinStyle = kCGLineJoinRound;
        path.lineCapStyle = kCGLineCapRound;
        [self.currentColor set];
        [path stroke];
    }
}

- (void)setLineThickness:(CGFloat)thickness {
    _thickness = thickness;
    for(UIBezierPath *path in self.paths) {
        path.lineWidth = thickness;
    }
    [self setNeedsDisplay];
}

- (void)setColor:(UIColor *)color {
    self.currentColor = color;
    [self setNeedsDisplay];
}

- (void)clean {
    [self.paths removeAllObjects];
    [self setNeedsDisplay];
}
- (void)back {
    [self.paths removeLastObject];
    [self setNeedsDisplay];
}

- (BOOL)haveDraw {
    return self.paths.count > 0;
}

@end
