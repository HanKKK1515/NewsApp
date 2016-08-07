//
//  HLPostcodeAddressResultList.h
//  简闻
//
//  Created by 韩露露 on 16/5/6.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HLPostcodeAddressResultCity : NSObject
@property (copy, nonatomic) NSString *PostNumber;
@property (copy, nonatomic) NSString *Province;
@property (copy, nonatomic) NSString *City;
@property (copy, nonatomic) NSString *District; // 行政区
@property (copy, nonatomic) NSString *Address;

@end
