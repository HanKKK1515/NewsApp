//
//  HLChengyuCell.m
//  简闻
//
//  Created by 韩露露 on 16/5/15.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import "HLChengyuCell.h"

@interface HLChengyuCell ()
@property (weak, nonatomic) IBOutlet UILabel *myTitle;
@end

@implementation HLChengyuCell

+ (instancetype)cellWithTableView:(UITableView *)tableView ForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"chengyuCell";
    return [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
}

- (void)setResult:(HLChengyuResult *)result {
    _result = result;
    self.myTitle.text = result.text.firstObject;
}

@end
