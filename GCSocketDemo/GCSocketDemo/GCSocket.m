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

+ (instancetype)shareInstance
{
    static GCSocket *socket = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        socket = [[self alloc] init];
    });
    
    return socket;
}

- (id)init
{
    if (self = [super init]) {
        /* [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(recvMessage) userInfo:nil repeats:YES]; */
        
         // socket也是固有的连接，不需要重新开启,具体时间可以自定义 (模拟心跳)
        [NSTimer scheduledTimerWithTimeInterval:30
                                         target:self selector:@selector(longClienLink) userInfo:nil repeats:YES];
    }
    return self;
}

//! 建立连接
- (BOOL)createSocket
{
    // 当连接时 判断上次是否已经断开
    if (_socketClient != 0) {
        [self close];
        _socketClient = 0;
    }
    
    //创建一个socket,返回值为Int。（注scoket其实就是Int类型）
    //第一个参数addressFamily IPv4(AF_INET) 或 IPv6(AF_INET6)。
    //第二个参数 type 表示 socket 的类型，通常是流stream(SOCK_STREAM) 或数据报文datagram(SOCK_DGRAM)
    //第三个参数 protocol 参数通常设置为0，以便让系统自动为选择我们合适的协议，对于 stream socket 来说会是 TCP 协议(IPPROTO_TCP)，而对于 datagram来说会是 UDP 协议(IPPROTO_UDP)
    // create socket
    self.socketClient = socket(AF_INET, SOCK_STREAM, 0);
    
    if (_socketClient > 0) {
        NSLog(@"Create socket link successfully");
    } else {
        NSLog(@"Create socket failed with some error");
    }
    
    return _socketClient > 0;
}

//! 建立socket并且连接
- (BOOL)connectionToHost:(NSString *)host onPort:(int)port
{
    [self createSocket];
    // Connect to host
    // 创建一个sockaddr_in类型结构体
    struct sockaddr_in hostServer;
    // 设置IPv4
    hostServer.sin_family = AF_INET;
    // inet_aton是一个改进的方法来将一个字符串IP地址转换为一个32位的网络序列IP地址
    // 如果这个函数成功，函数的返回值非零，如果输入地址不正确则会返回零。
    hostServer.sin_addr.s_addr = inet_addr(host.UTF8String);
    // htons是将整型变量从主机字节顺序转变成网络字节顺序，赋值端口号
    hostServer.sin_port = htons(port);
    // 用scoket和服务端地址，发起连接。
    // 客户端向特定网络地址的服务器发送连接请求，连接成功返回0，失败返回 -1。
    // 该接口调用会阻塞当前线程，直到服务器返回。（可以用hub提示用户）
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

//！接收消息
- (void)readMessage
{
    // 新启动一个线程 接受消息
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self recvMessage];
    });
}

//! 接收消息
- (void)recvMessage
{
    // 模拟runloop
    do {
        uint8_t buffer[1024];
        ssize_t recvLen = recv(self.socketClient, buffer, sizeof(buffer), 0);
        if (recvLen == 0) {
            return;
        }
        NSData *bufferData = [NSData dataWithBytes:buffer length:recvLen];
        NSString *str = [[NSString alloc] initWithData:bufferData encoding:NSUTF8StringEncoding];
        // test
        NSLog(@"recv:%@",str);
    } while (1);

}

//! 断开socket连接
- (void)close
{
    close(_socketClient);
}

@end
