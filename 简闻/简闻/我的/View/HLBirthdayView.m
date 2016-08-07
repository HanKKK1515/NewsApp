//
//  HLBirthdayView.m
//  简闻
//
//  Created by 韩露露 on 16/6/21.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import "HLBirthdayView.h"

@interface HLBirthdayView ()
@property (weak, nonatomic) IBOutlet UIDatePicker *date;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolBarHeight;

- (IBAction)cancel:(UIBarButtonItem *)sender;
- (IBAction)done:(UIBarButtonItem *)sender;
@end

@implementation HLBirthdayView

+ (instancetype)birthdayView {
    HLBirthdayView *birthday = [[NSBundle mainBundle] loadNibNamed:@"HLBirthdayView" owner:self options:nil].lastObject;
    [birthday.date addTarget:birthday action:@selector(didSelectedBirthday) forControlEvents:UIControlEventValueChanged];
    [birthday didSelectedBirthday];
    return birthday;
}

- (void)didSelectedBirthday {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didSelectedDateNotification" object:nil userInfo:@{@"userInfo" : self.date.date}];
}

- (IBAction)cancel:(UIBarButtonItem *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didCancelDateNotification" object:nil];
}

- (IBAction)done:(UIBarButtonItem *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didDoneDateNotification" object:nil];
}

- (void)hiddenToolBar:(BOOL)hidden {
    if (hidden) {
        self.toolBar.hidden = YES;
        self.toolBarHeight.constant = 0;
    } else {
        self.toolBar.hidden = NO;
        self.toolBarHeight.constant = 44;
    }
}

@end
