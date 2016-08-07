//
//  HLChengyuResult.h
//  简闻
//
//  Created by 韩露露 on 16/5/20.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HLChengyuResponse.h"

@interface HLChengyuResult : NSObject
@property (copy, nonatomic) NSString *key;
@property (strong, nonatomic) NSArray *text;
@property (assign, nonatomic, getter = isClose) BOOL close;
@end
