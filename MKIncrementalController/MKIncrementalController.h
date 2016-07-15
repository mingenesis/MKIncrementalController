//
//  MKIncrementalController.h
//  
//
//  Created by Mingenesis on 7/12/16.
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, MKIncrementalControllerState) {
    MKIncrementalControllerStateNotLoading = 0,
    MKIncrementalControllerStateLoadingMore,
    MKIncrementalControllerStateReloading,
    MKIncrementalControllerStateNoMore,
};

@protocol MKIncrementalControllerDelegate, MKIncrementalReloadView;

@interface MKIncrementalController : NSObject

- (instancetype)initWithTableView:(UITableView *)tableView reloadView:(nullable __kindof UIView<MKIncrementalReloadView> *)reloadView NS_DESIGNATED_INITIALIZER;

@property (nonatomic, readonly) MKIncrementalControllerState state;
@property (nullable, nonatomic, strong, readonly) NSMutableArray *items;

@property (nullable, nonatomic, weak) id <MKIncrementalControllerDelegate> delegate;

- (void)loadmore;
- (void)reload;
- (void)cancelLoading;

@end

@protocol MKIncrementalReloadView <NSObject>

+ (CGFloat)minHeightForReload;
- (void)startLoading;
- (void)stopLoading;

@end

@protocol MKIncrementalControllerDelegate <NSObject>

@optional
- (void)incrementalController:(MKIncrementalController *)incrementalController fetchItemsForState:(MKIncrementalControllerState)state completion:(void (^)( NSArray * _Nullable items,  NSError * _Nullable error))completion;
- (NSIndexPath *)incrementalController:(MKIncrementalController *)incrementalController indexPathForItemAtIndex:(NSUInteger)index;

- (nullable __kindof UIView *)incrementalController:(MKIncrementalController *)incrementalController loadmoreViewForState:(MKIncrementalControllerState)state;
- (nullable __kindof UIView *)incrementalController:(MKIncrementalController *)incrementalController errorViewForError:(NSError *)error;
- (nullable __kindof UIView *)emptyViewForIncrementalController:(MKIncrementalController *)incrementalController;

@end

NS_ASSUME_NONNULL_END