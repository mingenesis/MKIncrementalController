//
//  MKIncrementalController.m
//  
//
//  Created by Mingenesis on 7/12/16.
//
//

#import "MKIncrementalController.h"
#import "MKIncrementalReloadView.h"
#import "MKIncrementalErrorView.h"
#import "MKIncrementalLoadmoreView.h"

static void * ScrollViewContext = &ScrollViewContext;

@interface MKIncrementalController ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView<MKIncrementalReloadView> *reloadView;
@property (nonatomic, strong) NSLayoutConstraint *reloadViewTopConstraint;
@property (nonatomic, strong) NSLayoutConstraint *reloadViewHeightConstraint;

@property (nonatomic) MKIncrementalControllerState prevState;
@property (nonatomic, strong) void (^completionBlock)(NSArray *items, NSError *error);

@end

@implementation MKIncrementalController

- (instancetype)init {
    return [self initWithTableView:[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain] reloadView:nil];
}

- (instancetype)initWithTableView:(UITableView *)tableView reloadView:(nullable __kindof UIView<MKIncrementalReloadView> *)reloadView {
    self = [super init];
    if (self) {
        _tableView = tableView;
        if (reloadView) {
            _reloadView = reloadView;
        }
        else {
            _reloadView = [[MKIncrementalReloadView alloc] initWithFrame:CGRectZero];
        }
        
        [self initialize];
    }
    return self;
}

- (void)initialize {
    UIView *bgView = self.tableView.backgroundView;
    
    if (!bgView) {
        bgView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    
    self.reloadView.clipsToBounds = YES;
    self.reloadView.translatesAutoresizingMaskIntoConstraints = NO;
    [bgView addSubview:self.reloadView];
    
    _reloadViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.reloadView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:bgView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    _reloadViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.reloadView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0];
    
    [self.reloadView addConstraint:self.reloadViewHeightConstraint];
    [bgView addConstraint:self.reloadViewTopConstraint];
    [bgView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[reloadView]|" options:0 metrics:nil views:@{@"reloadView": self.reloadView}]];
    
    self.tableView.backgroundView = bgView;
    [self updateTableFooterViewWithError:nil];
    
    [self.tableView addObserver:self forKeyPath:NSStringFromSelector(@selector(contentOffset)) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:ScrollViewContext];
    [self.tableView.panGestureRecognizer addTarget:self action:@selector(handlePanTableView:)];
}

- (void)dealloc {
    [self.tableView removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentOffset)) context:ScrollViewContext];
}

- (void)updateTableFooterViewWithError:(NSError *)error {
    UIView *footerView;
    
    if (self.items) {
        if (self.items.count == 0) {
            if (error) {
                if ([self.delegate respondsToSelector:@selector(incrementalController:errorViewForError:)]) {
                    footerView = [self.delegate incrementalController:self errorViewForError:error];
                }
                else {
                    footerView = [MKIncrementalErrorView errorViewWithError:error];
                }
            }
            else {
                if ([self.delegate respondsToSelector:@selector(emptyViewForIncrementalController:)]) {
                    footerView = [self.delegate emptyViewForIncrementalController:self];
                }
                else {
                    footerView = [MKIncrementalErrorView errorViewWithError:[NSError errorWithDomain:MKIncrementalErrorDomain code:MKIncrementalErrorEmpty userInfo:@{NSLocalizedDescriptionKey: (self.emptyMessage ?: @"No data")}]];
                }
            }
        }
        else {
            if ([self.delegate respondsToSelector:@selector(incrementalController:loadmoreViewForState:)]) {
                footerView = [self.delegate incrementalController:self loadmoreViewForState:self.state];
            }
            else {
                footerView = [MKIncrementalLoadmoreView loadmoreViewWithState:self.state];
            }
        }
    }
    
    self.tableView.tableFooterView = footerView;
}

- (void)cancelLoading {
    MKIncrementalControllerState state = self.state;
    
    if (state == MKIncrementalControllerStateLoadingMore || state == MKIncrementalControllerStateReloading) {
        _state = self.prevState;
        self.completionBlock = nil;
        
        [self updateTableFooterViewWithError:nil];
        if (state == MKIncrementalControllerStateReloading) {
            [self endReload];
        }
    }
}

#pragma mark - Reload

- (void)reload {
    if (self.state == MKIncrementalControllerStateLoadingMore || self.state == MKIncrementalControllerStateReloading) {
        return;
    }
    
    _prevState = self.state;
    _state = MKIncrementalControllerStateReloading;
    
    self.reloadView.loading = YES;
    [self updateTableFooterViewWithError:nil];
    
    if (!self.items) {
        _items = [NSMutableArray array];
    }
    
    CGPoint contentOffset = self.tableView.contentOffset;
    UIEdgeInsets insets = self.tableView.scrollIndicatorInsets;
    
    insets.top += [[self.reloadView class] heightForLoading];
    
    if (contentOffset.y > -insets.top) {
        contentOffset.y = - insets.top;
    }
    
    self.tableView.contentInset = insets;
    self.tableView.contentOffset = contentOffset;
    
    if ([self.delegate respondsToSelector:@selector(incrementalController:fetchItemsForState:completion:)]) {
        void(^completionBlock)(NSArray * _Nullable, NSError * _Nullable) = ^(NSArray * _Nullable items, NSError * _Nullable error) {
            self.completionBlock = nil;
            
            if (!self.tableView.dataSource) {
                return;
            }
            
            if (error) {
                _state = self.items.count == 0 ? MKIncrementalControllerStateNoMore : self.prevState;
                
                [self updateTableFooterViewWithError:error];
                [self endReload];
                
                return;
            }
            
            if (!items) {
                items = @[];
            }
            
            _state = items.count == 0 ? MKIncrementalControllerStateNoMore : MKIncrementalControllerStateNotLoading;
            
            [self.items setArray:items];
            
            [self.tableView reloadData];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateTableFooterViewWithError:nil];
                [self endReload];
                
                if ([self.delegate respondsToSelector:@selector(incrementalController:didSucceedFetchItems:)]) {
                    [self.delegate incrementalController:self didSucceedFetchItems:items];
                }
            });
        };
        
        self.completionBlock = completionBlock;
        
        [self.delegate incrementalController:self fetchItemsForState:self.state completion:^(NSArray * _Nullable items, NSError * _Nullable error) {
            if (completionBlock == self.completionBlock) {
                completionBlock(items, error);
            }
        }];
    }
}

- (void)endReload {
    self.reloadView.loading = NO;
    
    CGPoint contentOffset = self.tableView.contentOffset;
    UIEdgeInsets insets = self.tableView.scrollIndicatorInsets;
    
    self.tableView.contentInset = insets;
    self.tableView.contentOffset = contentOffset;
    
    contentOffset.y = -insets.top;
    [self.tableView setContentOffset:contentOffset animated:YES];
}

#pragma mark - Loadmore

- (void)loadmore {
    if (self.state == MKIncrementalControllerStateNoMore || self.state == MKIncrementalControllerStateReloading || self.state == MKIncrementalControllerStateLoadingMore) {
        return;
    }
    
    _prevState = self.state;
    _state = MKIncrementalControllerStateLoadingMore;
    
    [self updateTableFooterViewWithError:nil];
    
    if ([self.delegate respondsToSelector:@selector(incrementalController:fetchItemsForState:completion:)]) {
        void(^completionBlock)(NSArray * _Nullable, NSError * _Nullable) = ^(NSArray * _Nullable items, NSError * _Nullable error) {
            self.completionBlock = nil;
            
            if (!self.tableView.dataSource) {
                return;
            }
            
            if (error) {
                _state = self.prevState;
                
                [self updateTableFooterViewWithError:error];
                
                return;
            }
            
            if (!items) {
                items = @[];
            }
            
            _state = items.count == 0 ? MKIncrementalControllerStateNoMore : MKIncrementalControllerStateNotLoading;
            
            [self insertItems:items];
            [self updateTableFooterViewWithError:nil];
            
            if ([self.delegate respondsToSelector:@selector(incrementalController:didSucceedFetchItems:)]) {
                [self.delegate incrementalController:self didSucceedFetchItems:items];
            }
        };
        
        self.completionBlock = completionBlock;
        
        [self.delegate incrementalController:self fetchItemsForState:self.state completion:^(NSArray * _Nullable items, NSError * _Nullable error) {
            if (completionBlock == self.completionBlock) {
                completionBlock(items, error);
            }
        }];
    }
}

- (void)insertItems:(NSArray *)items {
    if (items.count == 0) {
        return;
    }
    
    NSUInteger index = self.items.count;
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:items.count];
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    
    for (id item in items) {
        NSIndexPath *indexPath = [self indexPathForItemAtIndex:index];
        
        [self.items addObject:item];
        [indexPaths addObject:indexPath];
        
        if (indexPath.section >= self.tableView.numberOfSections) {
            [indexSet addIndex:indexPath.section];
        }
        
        index ++;
    }
    
    [self.tableView beginUpdates];
    [self.tableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

- (NSIndexPath *)indexPathForItemAtIndex:(NSUInteger)index {
    if ([self.delegate respondsToSelector:@selector(incrementalController:indexPathForItemAtIndex:)]) {
        return [self.delegate incrementalController:self indexPathForItemAtIndex:index];
    }
    
    return [NSIndexPath indexPathForRow:index inSection:0];
}

#pragma mark - User Interaction

- (void)handlePanTableView:(UIPanGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if (self.reloadViewHeightConstraint.constant > [[self.reloadView class] minHeightForReload]) {
            [self reload];
        }
    }
}

- (void)scrollTableView:(CGFloat)offsetY direction:(BOOL)goDown {
    CGFloat top = self.tableView.scrollIndicatorInsets.top;
    CGFloat height = - offsetY - top;
    
    self.reloadViewTopConstraint.constant = top;
    self.reloadViewHeightConstraint.constant = MAX(0, height);
    
    if (self.tableView.dragging && goDown) {
        if (self.items.count > 0) {
            NSIndexPath *indexPath = [self indexPathForItemAtIndex:self.items.count - 1];
            
            if (CGRectIntersectsRect(self.tableView.bounds, [self.tableView rectForRowAtIndexPath:indexPath])) {
                [self loadmore];
            }
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (context == ScrollViewContext) {
        CGPoint prevOffset = [change[NSKeyValueChangeOldKey] CGPointValue];
        CGPoint newOffset = [change[NSKeyValueChangeNewKey] CGPointValue];
        
        if (prevOffset.y != newOffset.y) {
            [self scrollTableView:newOffset.y direction:newOffset.y > prevOffset.y];
        }
    }
}

@end
