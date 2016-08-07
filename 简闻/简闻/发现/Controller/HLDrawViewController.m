//
//  ViewController.m
//  涂鸦HD
//
//  Created by 韩露露 on 15/10/31.
//  Copyright © 2015年 韩露露. All rights reserved.
//

#import "HLDrawViewController.h"
#import "HLView.h"
#import "MBProgressHUD+MJ.h"

@interface HLDrawViewController ()

@property (weak, nonatomic) IBOutlet HLView *currentView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelBtn;
- (IBAction)clean;
- (IBAction)back;
- (IBAction)cancel:(UIBarButtonItem *)sender; // 销毁控制器
- (IBAction)save;
- (IBAction)thickness:(UISlider *)sender;

- (IBAction)setColor:(UIButton *)sender;

@end

@implementation HLDrawViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.cancelBtn.imageInsets = UIEdgeInsetsMake(10, -5, 7, 10);
}

- (IBAction)clean {
    [self.currentView clean];
}

- (IBAction)back {
    [self.currentView back];
}

- (IBAction)cancel:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)save {
    if (self.currentView.haveDraw) {
        UIGraphicsBeginImageContextWithOptions(self.currentView.frame.size, NO, 0.0);
        [self.currentView.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        [self.currentView clean];
    } else {
        __weak typeof(self) drawVc = self;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"还没开始画哦(^o^)" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionY = [UIAlertAction actionWithTitle:@"继续画" style:UIAlertActionStyleDefault handler:nil];
        UIAlertAction *actionN = [UIAlertAction actionWithTitle:@"不画了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [drawVc.navigationController popViewControllerAnimated:YES];
        }];
        [alert addAction:actionN];
        [alert addAction:actionY];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
}

- (IBAction)thickness:(UISlider *)sender {
    [self.currentView setLineThickness:sender.value];
}

- (IBAction)setColor:(UIButton *)sender {
    NSInteger numb = sender.tag;
    UIColor *color = nil;
    switch(numb) {
        case 1:
            color = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0];
            break;
        case 2:
            color = [UIColor colorWithRed:76/255.0 green:76/255.0 blue:76/255.0 alpha:1.0];
            break;
        case 3:
            color = [UIColor colorWithRed:127/255.0 green:127/255.0 blue:127/255.0 alpha:1.0];
            break;
        case 4:
            color = [UIColor colorWithRed:179/255.0 green:127/255.0 blue:127/255.0 alpha:1.0];
            break;
        case 5:
            color = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0];
            break;
        case 6:
            color = [UIColor colorWithRed:250/255.0 green:204/255.0 blue:102/255.0 alpha:1.0];
            break;
        case 7:
            color = [UIColor colorWithRed:245/255.0 green:128/255.0 blue:2/255.0 alpha:1.0];
            break;
        case 8:
            color = [UIColor colorWithRed:244/255.0 green:102/255.0 blue:103/255.0 alpha:1.0];
            break;
        case 9:
            color = [UIColor colorWithRed:243/255.0 green:2/255.0 blue:4/255.0 alpha:1.0];
            break;
        case 10:
            color = [UIColor colorWithRed:128/255.0 green:0/255.0 blue:64/255.0 alpha:1.0];
            break;
        case 11:
            color = [UIColor colorWithRed:39/255.0 green:128/255.0 blue:64/255.0 alpha:1.0];
            break;
        case 12:
            color = [UIColor colorWithRed:128/255.0 green:128/255.0 blue:0/255.0 alpha:1.0];
            break;
        case 13:
            color = [UIColor colorWithRed:128/255.0 green:255/255.0 blue:0/255.0 alpha:1.0];
            break;
        case 14:
            color = [UIColor colorWithRed:254/255.0 green:255/255.0 blue:102/255.0 alpha:1.0];
            break;
        case 15:
            color = [UIColor colorWithRed:102/255.0 green:255/255.0 blue:204/255.0 alpha:1.0];
            break;
        case 16:
            color = [UIColor colorWithRed:102/255.0 green:204/255.0 blue:255/255.0 alpha:1.0];
            break;
        case 17:
            color = [UIColor colorWithRed:204/255.0 green:102/255.0 blue:255/255.0 alpha:1.0];
            break;
        case 18:
            color = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:255/255.0 alpha:1.0];
            break;
        case 19:
            color = [UIColor colorWithRed:128/255.0 green:0/255.0 blue:255/255.0 alpha:1.0];
            break;
        case 20:
            color = [UIColor colorWithRed:21/255.0 green:64/255.0 blue:128/255.0 alpha:1.0];
    }
    [self.currentView setColor:color];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if(error) {
        [MBProgressHUD showError:@"保存失败" toView:self.view];
    } else {
        [MBProgressHUD showSuccess:@"已保存到相册" toView:self.view];
    }
}
@end
