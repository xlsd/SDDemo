//
//  xuelinTableViewController.m
//  SDDemo
//
//  Created by 薛林 on 2017/4/27.
//  Copyright © 2017年 xuelin. All rights reserved.

#import "BaiduTableViewController.h"
#import "FDFeedEntity.h"
#import "FDFeedCell.h"
#import "UITableView+SDTemplateLayoutCell.h"

@interface SDTableViewController ()<UIActionSheetDelegate>
@property (nonatomic, copy) NSArray *prototypeEntitiesFromJSON;
@property (nonatomic, strong) NSMutableArray *feedEntitySections; // 2d array

@end

@implementation SDTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"小憩";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Actions" style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonAction)];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"FDFeedCell" bundle:nil] forCellReuseIdentifier:@"FDFeedCell"];
    
    //  加载数据
    [self buildTestDataThen:^{
        self.feedEntitySections = @[].mutableCopy;
        [self.feedEntitySections addObject:self.prototypeEntitiesFromJSON.mutableCopy];
        
        [self.tableView reloadData];
    }];
    
    //  刷新控件
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    self.tableView.refreshControl = refreshControl;
    [refreshControl addTarget:self action:@selector(refreshControlAction:) forControlEvents:UIControlEventValueChanged];
    refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"下拉刷新"];
    
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.feedEntitySections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.feedEntitySections[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FDFeedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FDFeedCell"];
    [self configerCell:cell atIndexPath:indexPath];
    return cell;
}


- (void)configerCell:(FDFeedCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.sd_enforceFrameLayout = NO;
    cell.entity = self.feedEntitySections[indexPath.section][indexPath.row];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView sd_heightForCellWithIdentifier:@"FDFeedCell" cacheByIndexPath:indexPath configuration:^(id cell) {
        [self configerCell:cell atIndexPath:indexPath];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//  左划动作
- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *actionOne = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"delete" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [self deleteRowWithIndexPath:indexPath];
        
    }];
    UITableViewRowAction *actionTwo = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"🌹top" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [self moveWithIndexPath:indexPath];
    }];
    UITableViewRowAction *actionThree = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"👍" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        FDFeedCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.backgroundColor = [UIColor colorWithRed:((float)arc4random_uniform(256) / 255.0) green:((float)arc4random_uniform(256) / 255.0) blue:((float)arc4random_uniform(256) / 255.0) alpha:1.0];
    }];
    
    actionTwo.backgroundColor = [UIColor colorWithRed:((float)arc4random_uniform(256) / 255.0) green:((float)arc4random_uniform(256) / 255.0) blue:((float)arc4random_uniform(256) / 255.0) alpha:1.0];
    actionThree.backgroundColor = [UIColor colorWithRed:((float)arc4random_uniform(256) / 255.0) green:((float)arc4random_uniform(256) / 255.0) blue:((float)arc4random_uniform(256) / 255.0) alpha:1.0];
    
    return @[actionOne,actionTwo,actionThree];
}


#pragma mark - loadData
- (void)buildTestDataThen:(void (^)(void))then {
    // Simulate an async request
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // Data from `data.json`
        NSString *dataFilePath = [[NSBundle mainBundle] pathForResource:@"baidu" ofType:@"json"];
        NSData *data = [NSData dataWithContentsOfFile:dataFilePath];
        NSDictionary *rootDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSArray *feedDicts = rootDict[@"feed"];
        
        // Convert to `FDFeedEntity`
        NSMutableArray *entities = @[].mutableCopy;
        [feedDicts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [entities addObject:[[FDFeedEntity alloc] initWithDictionary:obj]];
        }];
        self.prototypeEntitiesFromJSON = entities;
        
        // Callback
        dispatch_async(dispatch_get_main_queue(), ^{
            !then ?: then();
        });
    });
}
//  下拉加载数据
- (void)refreshControlAction:(UIRefreshControl *)sender {
    [sender beginRefreshing];
    if (sender.refreshing) 
        sender.attributedTitle = [[NSAttributedString alloc]initWithString:@"努力加载中..."];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.feedEntitySections removeAllObjects];
        [self.feedEntitySections addObject:self.prototypeEntitiesFromJSON.mutableCopy];
        [self.tableView reloadData];
        [sender endRefreshing];
    });
}

#pragma mark - rightButtonAction
- (void)rightButtonAction {
    [[[UIActionSheet alloc] initWithTitle:@"Actions"
                                 delegate:self
                        cancelButtonTitle:@"Cancel"
                   destructiveButtonTitle:nil
                        otherButtonTitles:@"Insert a row",@"Insert a section",@"Delete a section", nil] showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    SEL selectors[] = {
        @selector(InsertRow),
        @selector(InsertSection),
        @selector(deleteSection),
    };
    NSLog(@"%ld----%ld-------%ld",buttonIndex,sizeof(selectors),sizeof(SEL));
    if (buttonIndex < sizeof(selectors) / sizeof(SEL)) {
        //  方法名 -> 方法id -> 方法内存地址 -> 根据方法地址调用方法
        void(*imp)(id, SEL) = (typeof(imp))[self methodForSelector:selectors[buttonIndex]];
        imp(self, selectors[buttonIndex]);
    }
    
}

//  随机插入数据
- (FDFeedEntity *)randomEntity {
    NSUInteger randomNumber = arc4random_uniform((int32_t)self.prototypeEntitiesFromJSON.count);
    FDFeedEntity *randomEntity = self.prototypeEntitiesFromJSON[randomNumber];
    return randomEntity;
}

//  插入一行
- (void)InsertRow {
    if (self.feedEntitySections.count == 0) {
        [self InsertSection];
    } else {
        [self.feedEntitySections[0] insertObject:self.randomEntity atIndex:0];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}
//  插入一组
- (void)InsertSection {
    [self.feedEntitySections insertObject:@[self.randomEntity].mutableCopy atIndex:0];
    [self.tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}
//  删除一组
- (void)deleteSection {
    if (self.feedEntitySections.count>0) {
        [self.feedEntitySections removeObjectAtIndex:0];
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}
//  删除指定行
- (void)deleteRowWithIndexPath:(NSIndexPath *)indexPath {
    if (!indexPath) return;
    NSArray *feeds = self.feedEntitySections[indexPath.section];
    if (feeds.count > 1) {
        [self.feedEntitySections[indexPath.section] removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        [self.feedEntitySections removeObject:self.feedEntitySections[indexPath.section]];
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
}

//  置顶
- (void)moveWithIndexPath:(NSIndexPath *)indexPath {
    if (!indexPath) return;
    NSArray *sections = self.feedEntitySections[indexPath.section];
    if (sections.count > 1) {
        [self.feedEntitySections[0] insertObject:sections[indexPath.row] atIndex:0];
        [self.feedEntitySections[indexPath.section] removeObjectAtIndex:indexPath.row + 1];
        [self.tableView reloadData];
    } else {
        [self.feedEntitySections[0] insertObject:sections[indexPath.row] atIndex:0];
        [self.feedEntitySections removeObjectAtIndex:indexPath.section + 1];
        [self.tableView reloadData];
    }
}

@end
