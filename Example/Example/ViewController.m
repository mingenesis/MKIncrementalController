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

@property (nonatomic, strong) NSArray *data;
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
    
    NSMutableArray *data = [NSMutableArray array];
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    dateFormater.dateStyle = kCFDateFormatterFullStyle;
    dateFormater.timeStyle = kCFDateFormatterMediumStyle;
    
    for (NSInteger idx = 0; idx < 50; idx ++) {
        NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:idx * 9999999];
        [data addObject:[dateFormater stringFromDate:date]];
    }
    
    self.data = data;
    
    self.incrementalController = [[MKIncrementalController alloc] initWithTableView:self.tableView reloadView:nil];
    self.incrementalController.delegate = self;
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

- (void)incrementalController:(MKIncrementalController *)incrementalController fetchItemsWithCompletion:(void (^)(NSArray * _Nullable, NSError * _Nullable))completion {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        completion(nil, [NSError errorWithDomain:@"" code:0 userInfo:@{NSLocalizedDescriptionKey: @"error"}]);
        completion(@[@"a", @"b", @"c", @"d", @"e", @"f"], nil);
    });
}

@end
