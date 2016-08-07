//
//  HLNewsHotResponse.h
//  简闻
//
//  Created by 韩露露 on 16/6/1.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HLNewsHotResponse : NSObject
@property (copy, nonatomic) NSString *reason;
@property (assign, nonatomic) int error_code;
@property (strong, nonatomic) NSArray *result;
@end
