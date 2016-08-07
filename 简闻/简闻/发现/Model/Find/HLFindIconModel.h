//
//  HLFindIconModel.h
//  简闻
//
//  Created by 韩露露 on 16/8/5.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HLFindIconModel : NSObject

@property (copy, nonatomic) NSString *icon;
@property (copy, nonatomic) NSString *text;

+ (instancetype)iconWithDict:(NSDictionary *)dict;

@end
