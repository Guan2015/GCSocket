# GCSocket
==========
##一、socket 通信，本demo使用到Socket C API 与 GCDAsynSocket，其中GCDAsynSocket使用pod管理

`target 'GCSocketDemo' do`
`pod 'CocoaAsyncSocket', '~> 7.5.1'`
`end`

### socket C API (OS底层-基于C的BSD Socket)
      //socket 创建并初始化 socket，返回该 socket 的文件描述符，如果描述符为 -1 表示创建失败。
      int socket(int addressFamily, int type,int protocol)
      //关闭socket连接
      int close(int socketFileDescriptor)
      //将 socket 与特定主机地址与端口号绑定，成功绑定返回0，失败返回 -1。
      int bind(int socketFileDescriptor,sockaddr *addressToBind,int addressStructLength)
      //接受客户端连接请求并将客户端的网络地址信息保存到 clientAddress 中。
      int accept(int socketFileDescriptor,sockaddr *clientAddress, int clientAddressStructLength)
      //客户端向特定网络地址的服务器发送连接请求，连接成功返回0，失败返回 -1。
      int connect(int socketFileDescriptor,sockaddr *serverAddress, int serverAddressLength)
      //使用 DNS 查找特定主机名字对应的 IP 地址。如果找不到对应的 IP 地址则返回 NULL。
      hostent* gethostbyname(char *hostname)
      //通过 socket 发送数据，发送成功返回成功发送的字节数，否则返回 -1。
      int send(int socketFileDescriptor, char *buffer, int bufferLength, int flags)
      //从 socket 中读取数据，读取成功返回成功读取的字节数，否则返回 -1。
      int receive(int socketFileDescriptor,char *buffer, int bufferLength, int flags)
      //通过UDP socket 发送数据到特定的网络地址，发送成功返回成功发送的字节数，否则返回 -1。
      int sendto(int socketFileDescriptor,char *buffer, int bufferLength, int flags, sockaddr *destinationAddress, int destinationAddressLength)
      //从UDP socket 中读取数据，并保存发送者的网络地址信息，读取成功返回成功读取的字节数，否则返回 -1 。
      int recvfrom(int socketFileDescriptor,char *buffer, int bufferLength, int flags, sockaddr *fromAddress, int *fromAddressLength)
            

### GCDAsynSocket
测试方法如下：
关闭socket c API 使用 GCDAsyncSocket 

在mac下使用Terminal键入`nc -lk 8888`模拟socket服务端 <br>
![](https://github.com/Guan2015/GCSocket/blob/master/GCSocketDemo/GCSocketDemo/terminal.png) <br>
如果想监测网络可以使用`sudo tcpdump -i any -n -X port 8888`
![](https://github.com/Guan2015/GCSocket/blob/master/GCSocketDemo/GCSocketDemo/check.png)

## 二、关于协议
方便理解这里放在示意图（拿别人的^_^)
![](https://github.com/Guan2015/GCSocket/blob/master/GCSocketDemo/GCSocketDemo/socket.png)

大家熟知网络由下往上分为物理层、数据链路层、网络层、传输层、会话层、表示层和应用层，物理层、数据链路层这里暂且不谈，很少涉及。`IP协议栈`属于网络层，`TCP/UDP`在传输层，而`HTTP协议`、`FTP`、`TELNET`、`XMPP`等对应于应用层，TPC/IP协议是传输层协议，主要解决数据如何在网络中传输，而HTTP是应用层协议，主要解决如何包装数据。实际上socket是对TCP/IP协议的封装，Socket本身并不是协议，而是一个调用接口（API），通过Socket，我们才能使用TCP/IP协议。实际上，Socket跟TCP/IP协议没有必然的联系。Socket编程接口在设计的时候，就希望也能适应其他的网络协议。所以说，Socket的出现只是使得程序员更方便地使用TCP/IP协议栈而已，是对TCP/IP协议的抽象，从而形成了我们知道的一些最基本的函数接口，比如create、listen、connect、accept、send、read和write等等
## 三、关于Socket消息粘包
资料来着网络整理 <br>
<nbsp>TCP粘包是指发送方发送的若干包数据到接收方接收时粘成一包，从接收缓冲区看，后一包数据的头紧接着前一包数据的尾。
      出现粘包现象的原因是多方面的，它既可能由发送方造成，也可能由接收方造成。发送方引起的粘包是由TCP协议本身造成的，TCP为提高传输效率，发送方往往要收集到足够多的数据后才发送一包数据。若连续几次发送的数据都很少，通常TCP会根据优化算法把这些数据合成一包后一次发送出去，这样接收方就收到了粘包数据。接收方引起的粘包是由于接收方用户进程不及时接收数据，从而导致粘包现象。这是因为接收方先把收到的数据放在系统接收缓冲区，用户进程从该缓冲区取数据，若下一包数据到达时前一包数据尚未被用户进程取走，则下一包数据放到系统接收缓冲区时就接到前一包数据之后，而用户进程根据预先设定的缓冲区大小从系统接收缓冲区取数据，这样就一次取到了多包数据。
      粘包情况有两种，一种是粘在一起的包都是完整的数据包，另一种情况是粘在一起的包有不完整的包，此处假设用户接收缓冲区长度为m个字节。
不是所有的粘包现象都需要处理，若传输的数据为不带结构的连续流数据（如文件传输），则不必把粘连的包分开（简称分包）。但在实际工程应用中，传输的数据一般为带结构的数据，这时就需要做分包处理。
      在处理定长结构数据的粘包问题时，分包算法比较简单；在处理不定长结构数据的粘包问题时，分包算法就比较复杂。特别是如图3所示的粘包情况，由于一包数据内容被分在了两个连续的接收包中，处理起来难度较大。实际工程应用中应尽量避免出现粘包现象。
      为了避免粘包现象，可采取以下几种措施。一是对于发送方引起的粘包现象，用户可通过编程设置来避免，TCP提供了强制数据立即传送的操作指令push，TCP软件收到该操作指令后，就立即将本段数据发送出去，而不必等待发送缓冲区满；二是对于接收方引起的粘包，则可通过优化程序设计、精简接收进程工作量、提高接收进程优先级等措施，使其及时接收数据，从而尽量避免出现粘包现象；三是由接收方控制，将一包数据按结构字段，人为控制分多次接收，然后合并，通过这种手段来避免粘包。
以上提到的三种措施，都有其不足之处。第一种编程设置方法虽然可以避免发送方引起的粘包，但它关闭了优化算法，降低了网络发送效率，影响应用程序的性能，一般不建议使用。第二种方法只能减少出现粘包的可能性，但并不能完全避免粘包，当发送频率较高时，或由于网络突发可能使某个时间段数据包到达接收方较快，接收方还是有可能来不及接收，从而导致粘包。第三种方法虽然避免了粘包，但应用程序的效率较低，对实时应用的场合不适合。

一种比较周全的对策是：接收方创建一预处理线程，对接收到的数据包进行预处理，将粘连的包分开。对这种方法我们进行了实验，证明是高效可行的。
