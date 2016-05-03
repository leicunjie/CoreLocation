//
//  ViewController.m
//  SystemLocationDemo
//
//  Created by leicunjie on 16/5/3.
//  Copyright © 2016年 leicunjie. All rights reserved.
//

#import "ViewController.h"
#import "CCLocationManager.h"

@interface ViewController ()

@property(nonatomic,strong)CCLocationManager * manager;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.manager = [CCLocationManager new];
    [self.manager startUpdateLocationWithSuccessBlock:^(id data) {
        
    } addFailBlock:^(id data) {
        
    }];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
