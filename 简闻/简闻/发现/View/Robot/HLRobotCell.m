//
//  HLRobotCell.m
//  简闻
//
//  Created by 韩露露 on 16/5/22.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import "HLRobotCell.h"
#import "UIImage+Extension.h"
#import "NSDate+HL.h"

@interface HLRobotCell ()
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *timeView;
@property (weak, nonatomic) IBOutlet UILabel *textView;
@end

@implementation HLRobotCell

+ (instancetype)cellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"robotCell";
    HLRobotCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    cell.iconView.layer.cornerRadius = 20;
    cell.iconView.clipsToBounds = YES;

    return cell;
}

- (void)setCellData:(HLRobotCellData *)cellData {
    _cellData = cellData;
    
    if (self.cellData.isHiddenTime) {
        self.timeView.text = nil;
        self.timeView.hidden = YES;
    } else {
        self.timeView.hidden = NO;
        self.timeView.text = [NSDate timeIntervarWithDate:cellData.date];
    }
    
    self.textView.text = cellData.text;
}

@end
