//
//  TableViewController.m
//  SDLayoutDemo
//
//  Created by 薛林 on 2017/4/27.
//  Copyright © 2017年 YunTianXia. All rights reserved.
//

#import "TableViewController.h"
#import "BaiduTableViewController.h"

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

    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    cell.textLabel.text = @"花田小憩";
    cell.imageView.image = [UIImage imageNamed:@"qq"];
    cell.imageView.layer.cornerRadius = 76;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.navigationController pushViewController:[BaiduTableViewController new] animated:YES];
}


@end
