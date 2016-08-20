//
//  HLNewsHeaderFlowLayout.m
//  简闻
//
//  Created by 韩露露 on 16/8/6.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import "HLNewsHeaderFlowLayout.h"


@implementation HLNewsHeaderFlowLayout

- (void)prepareLayout {
    [super prepareLayout];
    self.itemSize = self.collectionView.frame.size;
    self.minimumInteritemSpacing = 0;
    self.minimumLineSpacing = 0;
    self.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity{
    CGRect currentRect;
    currentRect.size = self.collectionView.frame.size;
    currentRect.origin = proposedContentOffset;
    NSArray *itemsAttrib = [self layoutAttributesForElementsInRect:currentRect];
    
    CGFloat itemCX = proposedContentOffset.x + self.collectionView.frame.size.width * 0.5;
    CGFloat minDistance = MAXFLOAT;
    for (UICollectionViewLayoutAttributes *attris in itemsAttrib) {
        if (ABS(attris.center.x - itemCX) < ABS(minDistance)) {
            minDistance = attris.center.x - itemCX;
        }
    }
    NSUInteger item = ((proposedContentOffset.x + minDistance - self.collectionView.frame.size.width * 0.5) / self.collectionView.frame.size.width) + 1;
    if ([self.delegate respondsToSelector:@selector(headerFlowLayout:currentItem:)]) {
        [self.delegate headerFlowLayout:self currentItem:item];
    }
    return CGPointMake(proposedContentOffset.x + minDistance, proposedContentOffset.y);
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    CGFloat changeSizeRect = self.collectionView.frame.size.width * 0.5; // 图片开始放大时的center距离collectionView中心x的距离
    
    CGRect currentFrame; // 可视区域的frame
    currentFrame.size = self.collectionView.frame.size;
    currentFrame.origin = self.collectionView.contentOffset;
    
    CGFloat centerX = self.collectionView.contentOffset.x + self.collectionView.frame.size.width * 0.5; // 可视区域的center.x
    
    // 获取可视区域内item属性的拷贝
    NSArray *currentItemAttrb = [[NSArray alloc] initWithArray:[super layoutAttributesForElementsInRect:currentFrame] copyItems:YES];
    for (UICollectionViewLayoutAttributes *itemAttris in currentItemAttrb) {
        CGFloat distance = ABS(centerX - itemAttris.center.x); // 每个item中心到可视区域的center.x的距离
        CGFloat scale;
        if (distance <= changeSizeRect) {
            scale = 1 - distance * 0.3 / changeSizeRect;
        } else {
            scale = 0.7;
        }
        itemAttris.transform3D = CATransform3DMakeScale(scale, scale, scale);
    }
    return currentItemAttrb;
}

@end
