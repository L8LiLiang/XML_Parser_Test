//
//  ViewController.m
//  B04-xml解析
//
//  Created by apple on 15/6/8.
//  Copyright (c) 2015年 itcast. All rights reserved.
//


//第一天
//1. HTTP协议的介绍
//1.1    请求 -- 响应
//1.2    使用NSURLConnection 请求百度首页
//NSURL
//NSURLRequest    封装(请求报文(请求行 请求头 请求体))
//NSURLConnection    发送异步请求  socket   connect连接服务器  send发送请求报文   recv接收响应报文
//1.3    http协议底层使用的协议是tcp
//2. 网络概念
//a. ip地址
//b. 端口号
//c. 了解  tcp和udp
//了解socket



//第二天
//1. 配置Apache
//2. NSURLRequest  --  配置缓存策略   设置超时时长   请求头
//3. JSON
//a. JSON是什么
//b. JSON怎么定义  {"":""}
//c. JSON的解析  NSJSONSerialization
//i. JSONObjectWithData 的返回值  id (数组或者字典)
//ii.  NSJSONReadingOptions取值   了解
//d. charles  监视http请求
//e. 获取 科技头条  的数据 解析 并显示到tableView
//f. plist的解析
//4. xml
//a. 什么是xml
//b. xml中注意的内容  标签 要有结束标签    每一个xml文档有且只有一个根节点
//c. 解析xml     sax
//i. 解析的步骤
//NSXMLParser    模型

#import "ViewController.h"
#import "Video.h"
@interface ViewController () <NSXMLParserDelegate>
@property (nonatomic, strong) NSMutableArray *videos;

@property (nonatomic, strong) Video *currentVideo;

@property (nonatomic, copy) NSMutableString *mStr;
@end

@implementation ViewController
- (NSMutableArray *)videos{
    if (_videos == nil) {
        _videos = [NSMutableArray array];
    }
    return _videos;
}

- (NSMutableString *)mStr{
    if (_mStr == nil) {
        _mStr = [NSMutableString string];
    }
    return _mStr;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self loadXML];
}

- (void)loadXML{
    //解析xml
    NSURL *url = [NSURL URLWithString:@"http://127.0.0.1/videos.xml"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue new] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError && data) {
            //设置代理  和代理方法所在的线程是一样的
            NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
            parser.delegate = self;
            [parser parse];
        }else{
            NSLog(@"获取数据出错");
        }
    }];

}

//NSXMLParser 的代理方法
//1 开始解析xml文档
- (void)parserDidStartDocument:(NSXMLParser *)parser{
    NSLog(@"1 开始解析文档");
//    NSLog(@"%@",[NSThread currentThread]);
    
    //移除所有内容
    [self.videos removeAllObjects];
}
//2 找开始节点(包括节点的属性)
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    // element  xml文档中的标签
    NSLog(@"2 找开始节点 %@----%@",elementName,attributeDict);
    
    //video的开始节点.创建video对象
    if ([elementName isEqualToString:@"video"]) {
        self.currentVideo = [Video new];
        self.currentVideo.videoId = attributeDict[@"videoId"];
        [self.videos addObject:self.currentVideo];
    }
    
    //清空mSTr
    [self.mStr setString:@""];
}

//3 找节点之间的内容
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    NSLog(@"3 节点之间的内容     %@",string);
    //拼接 节点之间的内容
    [self.mStr appendString:string];
}

// 4  结束节点
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    NSLog(@"4 结束节点   %@",elementName);

    //kvc
    if (![elementName isEqualToString:@"videos"] && ![elementName isEqualToString:@"video"]) {
        [self.currentVideo setValue:self.mStr forKey:elementName];

    }
    
   

//    if ([elementName isEqualToString:@"name"]) {
//        self.currentVideo.name = self.mStr;
//    }else if([elementName isEqualToString:@"length"]){
//        self.currentVideo.length = @(self.mStr.intValue);
//
//    }else if([elementName isEqualToString:@"videoURL"]){
//        self.currentVideo.videoURL = self.mStr;
//
//    }else if([elementName isEqualToString:@"imageURL"]){
//        self.currentVideo.imageURL = self.mStr;
//
//    }else if([elementName isEqualToString:@"desc"]){
//        self.currentVideo.desc = self.mStr;
//
//    }else if([elementName isEqualToString:@"teacher"]){
//        self.currentVideo.teacher = self.mStr;
//    }
    
    
}

//5 结束解析文档
- (void)parserDidEndDocument:(NSXMLParser *)parser{
    NSLog(@"5 结束");
    
    NSLog(@"%@",self.videos);
}

//6 解析文档出错
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
    NSLog(@"6 出错");

}









@end
