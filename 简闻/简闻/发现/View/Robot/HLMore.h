//
//  HLMore.h
//  简闻
//
//  Created by 韩露露 on 16/5/28.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, HLMoreType) {
    kHLMoreTypeHome = 1,
    kHLMoreTypeTop,
    kHLMoreTypeBottom,
    kHLMoreTypeClearContent,
};

@class HLMore;
@protocol HLMoreDelegate <NSObject>

@optional
- (void)more:(HLMore *)more didSelectedType:(HLMoreType)type;

@end

@interface HLMore : UIView

@property (weak, nonatomic) id<HLMoreDelegate> delegate;

+ (instancetype)more;
@end
