//
//  GCAsyncSocket.h
//  GCSocketDemo
//
//  Created by 哈帝 on 16/12/12.
//  Copyright © 2016年 guan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GCDAsyncSocket;

@protocol GCAsynSocketDelegate <NSObject>

@optional

- (void)didConnectFailedWithError:(NSError *)error;

- (void)gc_socket:(GCDAsyncSocket *)socket didConnectTohost:(NSString *)host port:(UInt16)port;

- (void)gc_socket:(GCDAsyncSocket *)socket didReceiveData:(NSData *)data tag:(long)tag;

@end

@interface GCAsyncSocket : NSObject

@property (nonatomic ,weak)id <GCAsynSocketDelegate> delegate;

/*! 单例 */
+ (instancetype)shareSocketInstance;

/*!
 * @brief  建立socket连接
 * @discussion 建立成功会回调GCDAsyncSocket  didConnectToHost:(NSString *)host port:(uint16_t)port 代理方法，失败会在控制台打印错误log
   @param  host连接地址
   @param  port端口号
 * @return void
 * @code     
      _asyncSocket = [[GCAsyncSocket alloc] init];
      _asyncSocket.delegate = self;
      [_asyncSocket connectWithHost:@"127.0.0.1" port:8888];
 */
- (void)connectWithHost:(NSString *)host port:(UInt16)port;


/*!
 *  @brief 关闭socket连接
 */
- (void)close;

- (BOOL)isClose;
- (void)readDataWithTimeout:(NSTimeInterval)timeout tag:(long)tag;
- (void)writeData:(NSData *)data timeout:(NSTimeInterval)timeout tag:(long)tag;

@end
