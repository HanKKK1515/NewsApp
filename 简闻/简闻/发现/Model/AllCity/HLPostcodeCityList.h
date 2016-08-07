//
//  HLPostcodeCityList.h
//  简闻
//
//  Created by 韩露露 on 16/5/7.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HLPostcodeDistrict.h"

@interface HLPostcodeCityList : NSObject
@property (copy, nonatomic) NSString *id;
@property (copy, nonatomic) NSString *city;
@property (strong, nonatomic) NSArray *district;
@end
