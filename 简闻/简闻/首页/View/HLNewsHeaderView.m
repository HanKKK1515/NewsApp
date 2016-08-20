//
//  HLNewsHeaderView.m
//  简闻
//
//  Created by 韩露露 on 16/8/6.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import "HLNewsHeaderView.h"
#import "HLNewsHeaderFlowLayout.h"
#import "HLNewsHeaderCell.h"

@interface HLNewsHeaderView () <UICollectionViewDelegate, UICollectionViewDataSource, HLNewsHeaderFlowLayoutDelegate>
@property (weak, nonatomic) IBOutlet UIPageControl *page;
@property (strong, nonatomic) UICollectionView *collectionView;
@end

static const CGFloat height = 230;
@implementation HLNewsHeaderView

+ (instancetype)headerView {
    return [[NSBundle mainBundle] loadNibNamed:@"HLNewsHeaderView" owner:self options:nil].lastObject;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        HLNewsHeaderFlowLayout *flowLayout = [[HLNewsHeaderFlowLayout alloc] init];
        flowLayout.delegate = self;
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.frame collectionViewLayout:flowLayout];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.showsVerticalScrollIndicator = NO;
        self.collectionView = collectionView;
        [self insertSubview:collectionView atIndex:0];
        
        [self.collectionView registerNib:[UINib nibWithNibName:@"HLNewsHeaderCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"headerCell"];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect collFrame = self.frame;
    collFrame.size.width = [UIScreen mainScreen].bounds.size.width;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        collFrame.size.height = height;
    } else {
        collFrame.size.height = height - 80;
    }
    self.frame = collFrame;
    
    collFrame.origin = CGPointMake(self.frame.origin.x, self.frame.origin.y + 7);
    collFrame.size = CGSizeMake(self.frame.size.width, self.frame.size.height - 7);
    self.collectionView.frame = collFrame;
}

- (void)headerFlowLayout:(HLNewsHeaderFlowLayout *)headerFowLayout currentItem:(NSUInteger)item {
    self.page.currentPage = item;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.icons.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HLNewsHeaderCell *cell = [HLNewsHeaderCell headerCellWithCollectionView:collectionView indexPath:indexPath];
    cell.iconURL = self.icons[indexPath.item];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(headerView:didSelectItem:)]) {
        [self.delegate headerView:self didSelectItem:indexPath.item];
    }
}

- (void)setIcons:(NSArray *)icons {
    _icons = icons;
    [self.collectionView reloadData];
}

@end
