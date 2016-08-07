//
//  HLNewsResponse.m
//  简闻
//
//  Created by 韩露露 on 16/6/1.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import "HLNewsResponse.h"
#import "MJExtension.h"

@implementation HLNewsResponse

+ (NSDictionary *)mj_objectClassInArray {
    return @{@"result" : HLNews.class};
}

@end
