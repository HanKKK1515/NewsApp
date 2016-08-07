//
//  HLNewsResult.h
//  简闻
//
//  Created by 韩露露 on 16/6/1.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HLNews : NSObject
@property (copy, nonatomic) NSString *title; // 新闻标题
@property (copy, nonatomic) NSString *src; // 新闻来源
@property (copy, nonatomic) NSString *url; // 新闻链接
@property (copy, nonatomic) NSString *img; // 图片链接
@property (copy, nonatomic) NSString *img_width; // 图片宽度
@property (copy, nonatomic) NSString *img_length; // 图片高度
@property (copy, nonatomic) NSString *content; // 新闻摘要内容
@property (copy, nonatomic) NSString *pdate_src; // 发布完整时间
@property (copy, nonatomic) NSDate *date;
@end
