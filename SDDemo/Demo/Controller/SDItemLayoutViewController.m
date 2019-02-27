//
//  SDItemLayoutViewController.m
//  SDDemo
//
//  Created by xuelin on 2019/2/27.
//  Copyright © 2019 xuelin. All rights reserved.
//

#import "SDItemLayoutViewController.h"


static const NSInteger SortTitleItemColumn = 5;
static const NSInteger SortTitleRowHeight = 48.0;

@interface SDItemLayoutViewController ()
@property (nonatomic, strong) UIView *sortView;
@property (nonatomic, strong) NSArray *sortTitleArray;
@property (nonatomic, strong) NSArray *typeButtonArray;
@end

@implementation SDItemLayoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.sortView];
    [self.sortView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.center.equalTo(self.view);
        make.height.equalTo(@([self sortViewHeight]));
    }];
    
}

- (void)typeButtonAction:(UIButton *)button {
    
}

- (UIView *)sortView {
    if (!_sortView) {
        UIView *sortView = [[UIView alloc] init];
        sortView.backgroundColor = [UIColor lightGrayColor];
        _sortView = sortView;
        
        CGFloat itemSpace = 11.4;
        CGFloat leftMargin = 15;
        CGFloat itemWidth = (kScreenWidth - leftMargin * 2 - itemSpace * 4) / SortTitleItemColumn;
        NSMutableArray *buttonArray = [NSMutableArray arrayWithCapacity:3];
        for (int i = 0; i < self.sortTitleArray.count; i ++) {
            UIButton *button = [[UIButton alloc] init];
            button.backgroundColor = [UIColor colorWithRed:((float)arc4random_uniform(256) / 255.0) green:((float)arc4random_uniform(256) / 255.0) blue:((float)arc4random_uniform(256) / 255.0) alpha:1.0];
            
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor orangeColor] forState:UIControlStateHighlighted];
            button.titleLabel.font = [UIFont systemFontOfSize:13];
            button.layer.cornerRadius = 12.5;
            button.layer.masksToBounds = YES;
            button.tag = i;
            [button setTitle:self.sortTitleArray[i] forState:UIControlStateNormal];
            if (i == 0) {
                button.selected = YES;
            }
            [button addTarget:self action:@selector(typeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [sortView addSubview:button];
            
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.equalTo(@25);
                make.width.equalTo(@(itemWidth));
                make.top.equalTo(sortView).offset((int)(button.tag / 5.0) * (25 + 15) + 15);
                make.left.equalTo(sortView).offset(button.tag % 5 * (itemWidth + itemSpace) + leftMargin);
            }];
            
            [buttonArray addObject:button];
        }
        _typeButtonArray = [buttonArray copy];
    }
    return _sortView;
}

- (CGFloat)sortViewHeight {
    CGFloat itemSpace = 11.4;
    CGFloat leftMargin = 15;
    CGFloat itemWidth = (kScreenWidth - leftMargin * 2 - itemSpace * 4) / SortTitleItemColumn;
    CGFloat oneRowH = SortTitleRowHeight;
    CGFloat itemsW = itemWidth * self.sortTitleArray.count + itemSpace * (self.sortTitleArray.count - 1) + leftMargin * 2;
    NSInteger row = (NSInteger)ceilf(itemsW / kScreenWidth);
    CGFloat sumH = oneRowH * row;
    return sumH;
}

- (NSArray *)sortTitleArray {
    if (!_sortTitleArray) {
        _sortTitleArray = @[@"全部", @"买入", @"增持", @"减持", @"卖出", @"预警", @"A股", @"H股", @"美股", @"币种", @"添加", @"其他"];
    }
    return _sortTitleArray;
}

@end
