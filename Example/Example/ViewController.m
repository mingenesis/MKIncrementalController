//
//  ViewController.m
//  Example
//
//  Created by Mingenesis on 7/12/16.
//  Copyright © 2016 Mingenesis. All rights reserved.
//

#import "ViewController.h"
#import "MKIncrementalController.h"

@interface ViewController ()<UITableViewDataSource, MKIncrementalControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) MKIncrementalController *incrementalController;

@end

@implementation ViewController

- (void)loadView {
    [super loadView];
    
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 50;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.incrementalController = [[MKIncrementalController alloc] initWithTableView:self.tableView reloadView:nil];
    self.incrementalController.delegate = self;
    
    [self.incrementalController reload];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.incrementalController.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.textLabel.text = self.incrementalController.items[indexPath.row];
    
    return cell;
}

#pragma mark - MKIncrementalControllerDelegate

- (void)incrementalController:(MKIncrementalController *)incrementalController fetchItemsForState:(MKIncrementalControllerState)state completion:(nonnull void (^)(NSArray * _Nullable, NSError * _Nullable))completion {
    NSUInteger offset = state == MKIncrementalControllerStateReloading ? 0 : incrementalController.items.count;
    NSMutableArray *data = [NSMutableArray array];
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    dateFormater.dateStyle = kCFDateFormatterFullStyle;
    dateFormater.timeStyle = kCFDateFormatterMediumStyle;
    
    for (NSInteger idx = 0; idx < 20; idx ++) {
        if (offset < 90) {
            NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:(offset + idx) * 9999999];
            [data addObject:[dateFormater stringFromDate:date]];
        }
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        completion(data, nil);
    });
}

@end
