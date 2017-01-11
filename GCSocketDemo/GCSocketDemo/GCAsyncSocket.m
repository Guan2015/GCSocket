//
//  GCAsyncSocket.m
//  GCSocketDemo
//
//  Created by 哈帝 on 16/12/12.
//  Copyright © 2016年 guan. All rights reserved.
//

#import "GCAsyncSocket.h"
#import <GCDAsyncSocket.h>

@interface GCAsyncSocket ()<GCDAsyncSocketDelegate>
{
    GCDAsyncSocket *asyncSocket;
}

@end

@implementation GCAsyncSocket

+ (instancetype)shareSocketInstance
{
    static GCAsyncSocket *socket = nil;
    @synchronized (socket) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            socket = [[GCAsyncSocket alloc] init];
        });
    }
    
    return socket;
}

- (instancetype)init
{
    if (self = [super init]) {
        asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    
    return self;
}

#pragma mark - Public method

- (void)connectWithHost:(NSString *)host port:(UInt16)port
{
    NSError *error = nil;
    BOOL isconnect = [asyncSocket connectToHost:host onPort:port error:&error];
    GCSocketLog(@"connect  :%d",isconnect);
    if (error) {
        GCSocketLog(@"connect error :%@",error.description);
        if (_delegate && [_delegate respondsToSelector:@selector(didConnectFailedWithError:)]) {
            [_delegate didConnectFailedWithError:error];
        }
    }
}

- (void)close
{
    [asyncSocket disconnect];
}

- (BOOL)isClose
{
    return [asyncSocket isConnected];
}

- (void)readDataWithTimeout:(NSTimeInterval)timeout tag:(long)tag
{
    [asyncSocket readDataWithTimeout:timeout tag:tag];
}

- (void)writeData:(NSData *)data timeout:(NSTimeInterval)timeout tag:(long)tag
{
    [asyncSocket writeData:data withTimeout:timeout tag:tag];
}

#pragma mark - GCDSocketDelegate

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    GCSocketLog(@"didDisconnect...%@", err.description);
    if (_delegate && [_delegate respondsToSelector:@selector(didConnectFailedWithError:)]) {
        [_delegate didConnectFailedWithError:err];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    GCSocketLog(@"socket didConnectToHost: %@, port: %d", host, port);
    [sock readDataWithTimeout:-1 tag:0];
    if (_delegate && [_delegate respondsToSelector:@selector(gc_socket:didConnectTohost:port:)]) {
        [_delegate gc_socket:sock didConnectTohost:host port:port];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    GCSocketLog(@"socket didReadData length: %lu, tag: %ld", (unsigned long)data.length, tag);
    if (_delegate && [_delegate respondsToSelector:@selector(gc_socket:didReceiveData:tag:)]) {
        [_delegate gc_socket:sock didReceiveData:data tag:tag];
    }
    [sock readDataWithTimeout:-1 tag:0];
}


- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    GCSocketLog(@"[RHSocketConnection] didWriteDataWithTag: %ld", tag);
    [sock readDataWithTimeout:-1 tag:tag];
}

@end
