//
//  BarragePostViewController.m
//  MotionTracker
//
//  Created by mesird on 08/10/2016.
//  Copyright © 2016 mesird. All rights reserved.
//

#import "BarragePostViewController.h"

#import <BarrageRenderer/BarrageRenderer.h>
#import <BarrageRenderer/BarrageDescriptor.h>
#import <BarrageRenderer/BarrageWalkTextSprite.h>

@interface BarragePostViewController ()


@property (nonatomic, strong) BarrageRenderer    *barrageRenderer;

@property (weak, nonatomic) IBOutlet UITextField *inputField;

@property (nonatomic, strong) NSArray *messages;

@end

@implementation BarragePostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view layoutIfNeeded];
    
    // Create some message
    [self _initMessage];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = NO;
}

- (void)_initMessage {
    
    _messages = @[@"哈利路亚", @"666666", @"我要禁言了！！", @"23333333333333333", @"GTMD懒剑", @"大声告诉我我是天下第几帅？？？", @"第一", @"I love programming!!!"];
    
    _barrageRenderer = [[BarrageRenderer alloc] init];
    [self.view addSubview:_barrageRenderer.view];
    [_barrageRenderer start];
    
    for (NSString *message in _messages) {
        BarrageDescriptor * descriptor = [[BarrageDescriptor alloc] init];
        descriptor.spriteName = NSStringFromClass([BarrageWalkTextSprite class]);
        descriptor.params[@"text"] = message;
        descriptor.params[@"textColor"] = [UIColor blackColor];
        descriptor.params[@"speed"] = @(100 * (double)random() / RAND_MAX + 50);
        descriptor.params[@"direction"] = @(BarrageWalkDirectionR2L);
        [_barrageRenderer receive:descriptor];
    }
}

- (IBAction)postButtonPressed:(id)sender {
    
    NSString *text = _inputField.text;
    if (text.length == 0) {
        return;
    }
    
    BarrageDescriptor * descriptor = [[BarrageDescriptor alloc] init];
    descriptor.spriteName = NSStringFromClass([BarrageWalkTextSprite class]);
    descriptor.params[@"text"] = text;
    descriptor.params[@"textColor"] = [UIColor blackColor];
    descriptor.params[@"speed"] = @(100 * (double)random() / RAND_MAX + 50);
    descriptor.params[@"direction"] = @(BarrageWalkDirectionR2L);
    [_barrageRenderer receive:descriptor];
    
    _inputField.text = @"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
    [_barrageRenderer stop];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
