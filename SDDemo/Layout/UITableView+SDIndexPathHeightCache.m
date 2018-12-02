//
//  UITableView+SDIndexPathHeightCache.m
//  SDDemo
//
//  Created by 薛林 on 2017/4/27.
//  Copyright © 2017年 xuelin. All rights reserved.
//

#import "UITableView+SDIndexPathHeightCache.h"
#import <objc/runtime.h>

typedef NSMutableArray<NSMutableArray<NSNumber *> *> SDIndexPathHeightsBySection;

@interface SDIndexPathHeightCache ()
@property (nonatomic, strong) SDIndexPathHeightsBySection *heightsBySectionForPortrait;
@property (nonatomic, strong) SDIndexPathHeightsBySection *heightsBySectionForLandscape;
@end

@implementation SDIndexPathHeightCache

- (instancetype)init {
    self = [super init];
    if (self) {
        _heightsBySectionForPortrait = [NSMutableArray array];
        _heightsBySectionForLandscape = [NSMutableArray array];
    }
    return self;
}

- (SDIndexPathHeightsBySection *)heightsBySectionForCurrentOrientation {
    return UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation) ? self.heightsBySectionForPortrait: self.heightsBySectionForLandscape;
}

- (void)enumerateAllOrientationsUsingBlock:(void (^)(SDIndexPathHeightsBySection *heightsBySection))block {
    block(self.heightsBySectionForPortrait);
    block(self.heightsBySectionForLandscape);
}

- (BOOL)existsHeightAtIndexPath:(NSIndexPath *)indexPath {
    [self buildCachesAtIndexPathsIfNeeded:@[indexPath]];
    NSNumber *number = self.heightsBySectionForCurrentOrientation[indexPath.section][indexPath.row];
    return ![number isEqualToNumber:@-1];
}

- (void)cacheHeight:(CGFloat)height byIndexPath:(NSIndexPath *)indexPath {
    self.automaticallyInvalidateEnabled = YES;
    [self buildCachesAtIndexPathsIfNeeded:@[indexPath]];
    self.heightsBySectionForCurrentOrientation[indexPath.section][indexPath.row] = @(height);
}

- (CGFloat)heightForIndexPath:(NSIndexPath *)indexPath {
    [self buildCachesAtIndexPathsIfNeeded:@[indexPath]];
    NSNumber *number = self.heightsBySectionForCurrentOrientation[indexPath.section][indexPath.row];
#if CGFLOAT_IS_DOUBLE
    return number.doubleValue;
#else
    return number.floatValue;
#endif
}

- (void)invalidateHeightAtIndexPath:(NSIndexPath *)indexPath {
    [self buildCachesAtIndexPathsIfNeeded:@[indexPath]];
    [self enumerateAllOrientationsUsingBlock:^(SDIndexPathHeightsBySection *heightsBySection) {
        heightsBySection[indexPath.section][indexPath.row] = @-1;
    }];
}

- (void)invalidateAllHeightCache {
    [self enumerateAllOrientationsUsingBlock:^(SDIndexPathHeightsBySection *heightsBySection) {
        [heightsBySection removeAllObjects];
    }];
}

- (void)buildCachesAtIndexPathsIfNeeded:(NSArray *)indexPaths {
    // Build every section array or row array which is smaller than given index path.
    [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
        [self buildSectionsIfNeeded:indexPath.section];
        [self buildRowsIfNeeded:indexPath.row inExistSection:indexPath.section];
    }];
}

- (void)buildSectionsIfNeeded:(NSInteger)targetSection {
    [self enumerateAllOrientationsUsingBlock:^(SDIndexPathHeightsBySection *heightsBySection) {
        for (NSInteger section = 0; section <= targetSection; ++section) {
            if (section >= heightsBySection.count) {
                heightsBySection[section] = [NSMutableArray array];
            }
        }
    }];
}

- (void)buildRowsIfNeeded:(NSInteger)targetRow inExistSection:(NSInteger)section {
    [self enumerateAllOrientationsUsingBlock:^(SDIndexPathHeightsBySection *heightsBySection) {
        NSMutableArray<NSNumber *> *heightsByRow = heightsBySection[section];
        for (NSInteger row = 0; row <= targetRow; ++row) {
            if (row >= heightsByRow.count) {
                heightsByRow[row] = @-1;
            }
        }
    }];
}

@end

@implementation UITableView (SDIndexPathHeightCache)

- (SDIndexPathHeightCache *)sd_indexPathHeightCache {
    SDIndexPathHeightCache *cache = objc_getAssociatedObject(self, _cmd);
    if (!cache) {
        cache = [SDIndexPathHeightCache new];
        objc_setAssociatedObject(self, _cmd, cache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return cache;
}

@end

// We just forward primary call, in crash report, top most method in stack maybe sd's,
// but it's really not our bug, you should check whether your table view's data source and
// displaying cells are not matched when reloading.
static void __SD_TEMPLATE_LAYOUT_CELL_PRIMARY_CALL_IF_CRASH_NOT_OUR_BUG__(void (^callout)(void)) {
    callout();
}
#define SDPrimaryCall(...) do {__SD_TEMPLATE_LAYOUT_CELL_PRIMARY_CALL_IF_CRASH_NOT_OUR_BUG__(^{__VA_ARGS__});} while(0)

@implementation UITableView (sdIndexPathHeightCacheInvalidation)

- (void)sd_reloadDataWithoutInvalidateIndexPathHeightCache {
    SDPrimaryCall([self sd_reloadData];);
}

+ (void)load {
    // All methods that trigger height cache's invalidation
    SEL selectors[] = {
        @selector(reloadData),
        @selector(insertSections:withRowAnimation:),
        @selector(deleteSections:withRowAnimation:),
        @selector(reloadSections:withRowAnimation:),
        @selector(moveSection:toSection:),
        @selector(insertRowsAtIndexPaths:withRowAnimation:),
        @selector(deleteRowsAtIndexPaths:withRowAnimation:),
        @selector(reloadRowsAtIndexPaths:withRowAnimation:),
        @selector(moveRowAtIndexPath:toIndexPath:)
    };
    
    for (NSUInteger index = 0; index < sizeof(selectors) / sizeof(SEL); ++index) {
        SEL originalSelector = selectors[index];
        SEL swizzledSelector = NSSelectorFromString([@"sd_" stringByAppendingString:NSStringFromSelector(originalSelector)]);
        Method originalMethod = class_getInstanceMethod(self, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(self, swizzledSelector);
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

- (void)sd_reloadData {
    if (self.sd_indexPathHeightCache.automaticallyInvalidateEnabled) {
        [self.sd_indexPathHeightCache enumerateAllOrientationsUsingBlock:^(SDIndexPathHeightsBySection *heightsBySection) {
            [heightsBySection removeAllObjects];
        }];
    }
    SDPrimaryCall([self sd_reloadData];);
}

- (void)sd_insertSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    if (self.sd_indexPathHeightCache.automaticallyInvalidateEnabled) {
        [sections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL *stop) {
            [self.sd_indexPathHeightCache buildSectionsIfNeeded:section];
            [self.sd_indexPathHeightCache enumerateAllOrientationsUsingBlock:^(SDIndexPathHeightsBySection *heightsBySection) {
                [heightsBySection insertObject:[NSMutableArray array] atIndex:section];
            }];
        }];
    }
    SDPrimaryCall([self sd_insertSections:sections withRowAnimation:animation];);
}

- (void)sd_deleteSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    if (self.sd_indexPathHeightCache.automaticallyInvalidateEnabled) {
        [sections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL *stop) {
            [self.sd_indexPathHeightCache buildSectionsIfNeeded:section];
            [self.sd_indexPathHeightCache enumerateAllOrientationsUsingBlock:^(SDIndexPathHeightsBySection *heightsBySection) {
                [heightsBySection removeObjectAtIndex:section];
            }];
        }];
    }
    SDPrimaryCall([self sd_deleteSections:sections withRowAnimation:animation];);
}

- (void)sd_reloadSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    if (self.sd_indexPathHeightCache.automaticallyInvalidateEnabled) {
        [sections enumerateIndexesUsingBlock: ^(NSUInteger section, BOOL *stop) {
            [self.sd_indexPathHeightCache buildSectionsIfNeeded:section];
            [self.sd_indexPathHeightCache enumerateAllOrientationsUsingBlock:^(SDIndexPathHeightsBySection *heightsBySection) {
                [heightsBySection[section] removeAllObjects];
            }];
            
        }];
    }
    SDPrimaryCall([self sd_reloadSections:sections withRowAnimation:animation];);
}

- (void)sd_moveSection:(NSInteger)section toSection:(NSInteger)newSection {
    if (self.sd_indexPathHeightCache.automaticallyInvalidateEnabled) {
        [self.sd_indexPathHeightCache buildSectionsIfNeeded:section];
        [self.sd_indexPathHeightCache buildSectionsIfNeeded:newSection];
        [self.sd_indexPathHeightCache enumerateAllOrientationsUsingBlock:^(SDIndexPathHeightsBySection *heightsBySection) {
            [heightsBySection exchangeObjectAtIndex:section withObjectAtIndex:newSection];
        }];
    }
    SDPrimaryCall([self sd_moveSection:section toSection:newSection];);
}

- (void)sd_insertRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    if (self.sd_indexPathHeightCache.automaticallyInvalidateEnabled) {
        [self.sd_indexPathHeightCache buildCachesAtIndexPathsIfNeeded:indexPaths];
        [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
            [self.sd_indexPathHeightCache enumerateAllOrientationsUsingBlock:^(SDIndexPathHeightsBySection *heightsBySection) {
                [heightsBySection[indexPath.section] insertObject:@-1 atIndex:indexPath.row];
            }];
        }];
    }
    SDPrimaryCall([self sd_insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];);
}

- (void)sd_deleteRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    if (self.sd_indexPathHeightCache.automaticallyInvalidateEnabled) {
        [self.sd_indexPathHeightCache buildCachesAtIndexPathsIfNeeded:indexPaths];
        
        NSMutableDictionary<NSNumber *, NSMutableIndexSet *> *mutableIndexSetsToRemove = [NSMutableDictionary dictionary];
        [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
            NSMutableIndexSet *mutableIndexSet = mutableIndexSetsToRemove[@(indexPath.section)];
            if (!mutableIndexSet) {
                mutableIndexSet = [NSMutableIndexSet indexSet];
                mutableIndexSetsToRemove[@(indexPath.section)] = mutableIndexSet;
            }
            [mutableIndexSet addIndex:indexPath.row];
        }];
        
        [mutableIndexSetsToRemove enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, NSIndexSet *indexSet, BOOL *stop) {
            [self.sd_indexPathHeightCache enumerateAllOrientationsUsingBlock:^(SDIndexPathHeightsBySection *heightsBySection) {
                [heightsBySection[key.integerValue] removeObjectsAtIndexes:indexSet];
            }];
        }];
    }
    SDPrimaryCall([self sd_deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];);
}

- (void)sd_reloadRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    if (self.sd_indexPathHeightCache.automaticallyInvalidateEnabled) {
        [self.sd_indexPathHeightCache buildCachesAtIndexPathsIfNeeded:indexPaths];
        [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
            [self.sd_indexPathHeightCache enumerateAllOrientationsUsingBlock:^(SDIndexPathHeightsBySection *heightsBySection) {
                heightsBySection[indexPath.section][indexPath.row] = @-1;
            }];
        }];
    }
    SDPrimaryCall([self sd_reloadRowsAtIndexPaths:indexPaths withRowAnimation:animation];);
}

- (void)sd_moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if (self.sd_indexPathHeightCache.automaticallyInvalidateEnabled) {
        [self.sd_indexPathHeightCache buildCachesAtIndexPathsIfNeeded:@[sourceIndexPath, destinationIndexPath]];
        [self.sd_indexPathHeightCache enumerateAllOrientationsUsingBlock:^(SDIndexPathHeightsBySection *heightsBySection) {
            NSMutableArray<NSNumber *> *sourceRows = heightsBySection[sourceIndexPath.section];
            NSMutableArray<NSNumber *> *destinationRows = heightsBySection[destinationIndexPath.section];
            NSNumber *sourceValue = sourceRows[sourceIndexPath.row];
            NSNumber *destinationValue = destinationRows[destinationIndexPath.row];
            sourceRows[sourceIndexPath.row] = destinationValue;
            destinationRows[destinationIndexPath.row] = sourceValue;
        }];
    }
    SDPrimaryCall([self sd_moveRowAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];);
}

@end
