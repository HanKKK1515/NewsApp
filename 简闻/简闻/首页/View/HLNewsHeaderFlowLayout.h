//
//  HLNewsHeaderFlowLayout.h
//  简闻
//
//  Created by 韩露露 on 16/8/6.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HLNewsHeaderFlowLayout;
@protocol HLNewsHeaderFlowLayoutDelegate <NSObject>

@optional
- (void)headerFlowLayout:(HLNewsHeaderFlowLayout *)headerFowLayout currentItem:(NSUInteger)item;

@end

@interface HLNewsHeaderFlowLayout : UICollectionViewFlowLayout

@property (weak, nonatomic) id<HLNewsHeaderFlowLayoutDelegate> delegate;

@end
