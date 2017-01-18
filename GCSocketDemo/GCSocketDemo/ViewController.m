//
//  ViewController.m
//  GCSocketDemo
//
//  Created by 哈帝 on 16/12/9.
//  Copyright © 2016年 guan. All rights reserved.
//

#import "ViewController.h"

#import "GCSocket.h"
#import "GCAsyncSocket.h"

@interface ViewController ()<GCAsynSocketDelegate>

@property (nonatomic ,strong)GCAsyncSocket *asyncSocket;

@property (nonatomic ,strong)GCSocket *socket;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // You can user 'nc -lk 8888' to test
    
    // 'sudo tcpdump -i any -n -X port 8888' to test
    
    // use Socket C API
    /** */
     
    _socket = [[GCSocket alloc] init];
    [_socket connectionToHost:@"127.0.0.1" onPort:8888];
    [_socket sendMessage:@"hello"];
    [_socket readMessage];
     
    
    // use GCDAsyncSocket API
    
    /**
    
    _asyncSocket = [[GCAsyncSocket alloc] init];
    _asyncSocket.delegate = self;
    [_asyncSocket connectWithHost:@"127.0.0.1" port:8888];
    [_asyncSocket writeData:[@"hello" dataUsingEncoding:NSUTF8StringEncoding] timeout:1 tag:1];
     
     */
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
