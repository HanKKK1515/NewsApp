//
//  HLPostcodeAllCityList.h
//  简闻
//
//  Created by 韩露露 on 16/5/7.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HLPostcodeProvinceList.h"

@interface HLPostcodeCityListResponse : NSObject
@property (copy, nonatomic) NSString *reason;
@property (strong, nonatomic) NSArray *result;
@end
