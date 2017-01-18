//
//  GCSocket.h
//  GCSocketDemo
//
//  Created by 哈帝 on 16/12/9.
//  Copyright © 2016年 guan. All rights reserved.
//  Socket C API DEMO

#import <Foundation/Foundation.h>

@class GCSocket;

@protocol GCSocketDelegate <NSObject>

@optional


@end

@interface GCSocket : NSObject

@property (nonatomic ,weak)id <GCSocketDelegate> delegate;

- (BOOL)connectionToHost:(NSString *)host onPort:(int)port;

- (void)sendMessage:(NSString *)message;

- (void)readMessage;

/* - (void)recvMessage; */

- (id)init;

+ (instancetype)shareInstance;

@end
