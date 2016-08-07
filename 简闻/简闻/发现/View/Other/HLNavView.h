//
//  HLNavView.h
//  简闻
//
//  Created by 韩露露 on 16/5/3.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HLNavTextField.h"

@interface HLNavView : UIView
@property (weak, nonatomic) IBOutlet HLNavTextField *titleSearch;
+ (instancetype)titleView;
@end
