//
//  HLPostcodeAllCityList.m
//  简闻
//
//  Created by 韩露露 on 16/5/7.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import "HLPostcodeCityListResponse.h"
#import "MJExtension.h"

@implementation HLPostcodeCityListResponse

+ (NSDictionary *)mj_objectClassInArray {
    return @{@"result" : [HLPostcodeProvinceList class]};
}

@end
