## 一.SDDemo包含

####二.更新动态

> 新增一个使用递归算法写的iOS补位动画效果，以后新写的好玩的都会慢慢添加到这个Demo中来。

> 新增一个View中自排Item的算法，效果如下。

 * 流畅的图文混排
 <img width="187.5" height="333.5" src="https://github.com/xlsd/SDDemo/blob/master/SDDemo/listView.gif"/>
 
 * 递归算法实现iOS补位动画
  <img width="187.5" height="333.5" src="https://github.com/xlsd/SDDemo/blob/master/SDDemo/Resource/demo.gif"/>
  
  * 一个UIView中Item的自排算法
   <img width="187.5" height="333.5" src="https://github.com/xlsd/SDDemo/blob/master/SDDemo/Resource/item.png"/>
   
> 流畅的图文混排说明

    流畅的图文混排说明：一个简单的图文混排，图片大小自适应，限制最大宽度，使用indexPath缓存行高。支持cell编辑插入、收藏、点赞、置顶、删除功能。
缓存行高功能，能够支持90%以上的需求，如果数据计算较为复杂，可以对数据预处理+缓存行高，就相对较好了。
如果有什么问题，可以建issue，我会及时回复。

```
Containts the following function:
1. How to whrit a fluent listView;
2. How to edit the tableViewCell;
3. How to make the imageView size fit imageSize;
4. How to use the xib;
5. How to use the constain;
```


```
//  以下是部分图文混排的代码

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


```


