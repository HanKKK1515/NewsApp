//
//  HLPostcodeCityListResult.h
//  简闻
//
//  Created by 韩露露 on 16/5/7.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HLPostcodeCityList.h"

@interface HLPostcodeProvinceList : NSObject
@property (copy, nonatomic) NSString *id;
@property (copy, nonatomic) NSString *province;
@property (strong, nonatomic) NSArray *city;
@end
