//
//  HLChengyuCell.h
//  简闻
//
//  Created by 韩露露 on 16/5/15.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HLChengyuResult.h"

@interface HLChengyuCell : UITableViewCell
@property (strong, nonatomic) HLChengyuResult *result;

+ (instancetype)cellWithTableView:(UITableView *)tableView ForRowAtIndexPath:(NSIndexPath *)indexPath;
@end
