//
//  ViewController.m
//  MTabs
//
//  Created by ZartArn on 02.10.17.
//  Copyright © 2017 ZartArn. All rights reserved.
//

#import "ViewController.h"
#import "UIColor+tools.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (nonatomic) NSInteger itemsCount;

@end

@implementation ViewController

- (instancetype)initWithItemsCount:(NSInteger)itemsCount {
    if (self = [super init]) {
        _itemsCount = itemsCount;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor getRandomColor];
    
    [self configureViews];
    self.tableView.backgroundColor = [UIColor getRandomColor];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.itemsCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = [@(indexPath.row) stringValue];
    return cell;
}

#pragma mark -

- (void)configureViews {
    self.tableView  = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.autoresizingMask = 18.f;
    _tableView.tableFooterView = [UIView new];
    [self.view addSubview:_tableView];
}

@end
