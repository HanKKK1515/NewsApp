//
//  HLPhoneResult.h
//  简闻
//
//  Created by 韩露露 on 16/5/2.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HLPhoneResult : NSObject
@property (copy, nonatomic) NSString *province; // 省份
@property (copy, nonatomic) NSString *city; // 城市
@property (copy, nonatomic) NSString *sp; // 运营商
@property (copy, nonatomic) NSString *rpt_type; // 号码性质
@property (copy, nonatomic) NSString *hyname; // 号码性质描述
@property (copy, nonatomic) NSString *countDesc;
@end
