//
//  GCSocket.m
//  GCSocketDemo
//
//  Created by 哈帝 on 16/12/9.
//  Copyright © 2016年 guan. All rights reserved.
//

#import "GCSocket.h"

#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>

@interface GCSocket ()

@property (nonatomic ,assign)int socketClient;

@end

@implementation GCSocket

- (id)init
{
    if (self = [super init]) {
        // 模拟runloop 实现接受数据（简单版本）具体查看GCDSocket
        [NSTimer scheduledTimerWithTimeInterval:3
                                         target:self selector:@selector(recvMessage) userInfo:nil repeats:YES];
        
         // socket也是固有的连接，不需要重新开启,具体时间可以自定义
        [NSTimer scheduledTimerWithTimeInterval:30
                                         target:self selector:@selector(longClienLink) userInfo:nil repeats:YES];
    }
    return self;
}

//! 建立socket并且连接
- (BOOL)connectionToHost:(NSString *)host onPort:(int)port
{
    // 建议放在其他线程
    
    // create socket
    self.socketClient = socket(AF_INET, SOCK_STREAM, 0);
    
    if (_socketClient > 0) {
        NSLog(@"Create socket link successfully");
    } else {
        NSLog(@"some error");
    }
    
    // Connect to host
    struct sockaddr_in hostServer;
    hostServer.sin_family = AF_INET;
    hostServer.sin_addr.s_addr = inet_addr(host.UTF8String);
    hostServer.sin_port = htons(port);
    
    int result = connect(self.socketClient, (const struct sockaddr *)&hostServer, sizeof(hostServer));
    
    return (result == 0);
}

//! 发送消息
- (void)sendMessage:(NSString *)message
{
    ssize_t sendLen = send(self.socketClient, message.UTF8String, strlen(message.UTF8String), 0);
   
    NSLog(@"senlen %ld",sendLen);
}

- (void)longClienLink
{
    [self sendMessage:@"0x11"];
}

//! 接收消息
- (void)recvMessage
{
    uint8_t buffer[1024];
    
    ssize_t recvLen = recv(self.socketClient, buffer, sizeof(buffer), 0);
    if (recvLen == 0) {
        return;
    }
    
    NSData *bufferData = [NSData dataWithBytes:buffer length:recvLen];
    NSString *str = [[NSString alloc] initWithData:bufferData encoding:NSUTF8StringEncoding];
    
    NSLog(@"recv:%@",str);
}

//! 断开socket连接
- (void)close
{
    close(_socketClient);
}

@end
