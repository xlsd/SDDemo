//
//  TableViewController.m
//  SDDemo
//
//  Created by 薛林 on 2017/4/27.
//  Copyright © 2017年 xuelin. All rights reserved.
//

#import "TableViewController.h"
#import "BaiduTableViewController.h"
#import "SDAnimationControllerViewController.h"

@interface TableViewController ()

@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"花田";
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    if (indexPath.row == 0) {
        cell.textLabel.text = @"花田小憩";
    } else {
        cell.textLabel.text = @"递归算法的补位动画";
    }
    cell.imageView.image = [UIImage imageNamed:@"qq"];
    cell.imageView.layer.cornerRadius = 76;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        [self.navigationController pushViewController:[SDTableViewController new] animated:YES];
    } else {
        [self.navigationController pushViewController:[SDAnimationControllerViewController new] animated:YES];
    }
    
}


@end
