//
//  SDAnimationControllerViewController.m
//  SDDemo
//
//  Created by xuelin on 2018/12/2.
//  Copyright © 2018 xuelin. All rights reserved.
//

#import "SDAnimationControllerViewController.h"
#define kScreenWidth     [UIScreen mainScreen].bounds.size.width
#define kScreenHeight    [UIScreen mainScreen].bounds.size.height

static NSInteger const AnimationCount = 4;

@interface SDAnimationControllerViewController ()
// 从右向左动画相关
@property (nonatomic, strong) NSMutableArray<UIButton *> *rightBtns;
@property (nonatomic, strong) NSMutableArray<NSValue *> *rightFrames;
@property (nonatomic, strong) UIView *rightBackView;

// 从底部想上动画相关
@property (nonatomic, strong) NSMutableArray<UIButton *> *bottomBtns;
@property (nonatomic, strong) NSMutableArray<NSValue *> *bottomFrames;
@property (nonatomic, strong) UIView *bottomBackView;
@end

@implementation SDAnimationControllerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _rightBtns = @[].mutableCopy;
    _rightFrames = @[].mutableCopy;
    _bottomBtns = @[].mutableCopy;
    _bottomFrames = @[].mutableCopy;
    
    // 从右侧开始向左进行动画
    [self setAnimationViewFromRight];
    
    // 从底部向上进行动画
    [self setAnimationViewFromBottom];
}

// 从底部向上进行动画
- (void)setAnimationViewFromBottom {
    UIView *backview = [[UIView alloc] initWithFrame:CGRectMake(0, 80, kScreenWidth, 210)];
    [self.view addSubview:backview];
    self.bottomBackView = backview;
    backview.backgroundColor = [UIColor orangeColor];
    
    CGFloat buttonHeight = 210 / 3;
    for (int i = 0; i < AnimationCount; i++) {
        CGFloat y = buttonHeight * i;
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, y, kScreenWidth, buttonHeight)];
        [self.bottomBtns addObject:button];
        [backview addSubview:button];
        [button addTarget:self action:@selector(bottomAction:) forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor = [UIColor colorWithRed:((float)arc4random_uniform(256) / 255.0) green:((float)arc4random_uniform(256) / 255.0) blue:((float)arc4random_uniform(256) / 255.0) alpha:1.0];
        [backview addSubview:button];
        button.tag = i;
        [self.bottomFrames addObject:[NSValue valueWithCGRect:button.frame]];
        [button setTitle:[NSString stringWithFormat:@"%d", i] forState:UIControlStateNormal];
    }
    backview.clipsToBounds = YES;
}

- (void)bottomAction:(UIButton *)button {
    button.hidden = YES;
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [self bottonChangeFrame:button];
        button.alpha = 0;
    } completion:^(BOOL finished) {
        button.frame = self.bottomFrames.lastObject.CGRectValue;
        button.hidden = NO;
        [self bottomReloadTagAndFrame:button];
        [UIView animateWithDuration:0.5 animations:^{
            button.alpha = 1;
        }];
    }];
}

- (void)bottonChangeFrame:(UIButton *)button {
    [self bottomFrameChange:button tag:button.tag];
}

- (void)bottomFrameChange:(UIButton *)button tag:(NSInteger)tag {
    if (tag == 0) {
        tag++;
    }
    self.bottomBtns[tag].frame = self.bottomFrames[tag - 1].CGRectValue;
    if (tag < 3 && tag >= 1) {
        tag++;
        [self bottomFrameChange:self.bottomBtns[tag] tag:tag];
    }
}

- (void)bottomReloadTagAndFrame:(UIButton *)button {
    UIButton *tempButton = button;
    [self.bottomBtns removeObject:button];
    [self.bottomBtns addObject:tempButton];
    [self.bottomBtns enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.tag = idx;
    }];
}



// 从右侧开始向左进行动画
- (void)setAnimationViewFromRight {
    UIView *backview = [[UIView alloc] initWithFrame:CGRectMake(0, 360, kScreenWidth, 120)];
    [self.view addSubview:backview];
    self.rightBackView = backview;
    backview.backgroundColor = [UIColor orangeColor];
    
    CGFloat itemSpace = 15;
    CGFloat buttonWidth = (kScreenWidth - itemSpace * 4) / 3;
    
    for (int i = 0; i < AnimationCount; i++) {
        CGFloat x = itemSpace + (buttonWidth + itemSpace) * i;
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(x, 20, buttonWidth, 80)];
        [self.rightBtns addObject:button];
        [backview addSubview:button];
        [button addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor = [UIColor colorWithRed:((float)arc4random_uniform(256) / 255.0) green:((float)arc4random_uniform(256) / 255.0) blue:((float)arc4random_uniform(256) / 255.0) alpha:1.0];
        [backview addSubview:button];
        button.tag = i;
        [self.rightFrames addObject:[NSValue valueWithCGRect:button.frame]];
        [button setTitle:[NSString stringWithFormat:@"%d", i] forState:UIControlStateNormal];
    }
}

- (void)action:(UIButton *)button {
    button.hidden = YES;
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [self changeFrame:button];
        button.alpha = 0;
    } completion:^(BOOL finished) {
        button.frame = self.rightFrames.lastObject.CGRectValue;
        button.hidden = NO;
        [self reloadTagAndFrame:button];
        [UIView animateWithDuration:0.5 animations:^{
            button.alpha = 1;
        }];
    }];
}

- (void)changeFrame:(UIButton *)button {
    [self frameChange:button tag:button.tag];
}

- (void)frameChange:(UIButton *)button tag:(NSInteger)tag {
    if (tag == 0) {
        tag++;
    }
    self.rightBtns[tag].frame = self.rightFrames[tag - 1].CGRectValue;
    if (tag < 3 && tag >= 1) {
        tag++;
        [self frameChange:self.rightBtns[tag] tag:tag];
    }
}

- (void)reloadTagAndFrame:(UIButton *)button {
    UIButton *tempButton = button;
    [self.rightBtns removeObject:button];
    [self.rightBtns addObject:tempButton];
    [self.rightBtns enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.tag = idx;
    }];
}

- (BOOL)shouldAutorotate {
    return NO;
}

@end
