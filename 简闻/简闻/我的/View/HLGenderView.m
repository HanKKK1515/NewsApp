//
//  HLGenderView.m
//  简闻
//
//  Created by 韩露露 on 16/6/20.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import "HLGenderView.h"

@interface HLGenderView () <UIPickerViewDelegate, UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UIPickerView *gender;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolBarHeight;

- (IBAction)cancel:(UIBarButtonItem *)sender;
- (IBAction)done:(UIBarButtonItem *)sender;
@end

@implementation HLGenderView

+ (instancetype)genderView {
    HLGenderView *genderView = [[NSBundle mainBundle] loadNibNamed:@"HLGenderView" owner:self options:nil].lastObject;
    genderView.gender.delegate = genderView;
    genderView.gender.dataSource = genderView;
    [genderView pickerView:genderView.gender didSelectRow:0 inComponent:0];
    return genderView;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 2;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (row == 0) {
        return @"男";
    } else if (row == 1) {
        return @"女";
    }
    return nil;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSString *gender = row > 0 ? @"女" : @"男";
    [[NSNotificationCenter defaultCenter] postNotificationName:@"genderDidChoice" object:nil userInfo:@{@"userInfo" : gender}];
}

- (IBAction)cancel:(UIBarButtonItem *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"genderDidCancel" object:nil];
}

- (IBAction)done:(UIBarButtonItem *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"genderDidDone" object:nil];
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
