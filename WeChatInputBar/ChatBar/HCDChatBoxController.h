//
//  HCDChatBoxController.h
//  WeChatInputBar
//
//  Created by hcd on 2018/11/5.
//  Copyright © 2018 hcd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HCDChatBoxView.h"
#import "HCDChatBoxFaceView.h"
#import "HCDChatBoxMoreView.h"

@class HCDChatBoxController;
@protocol HCDChatBoxViewControllerDelegate <NSObject>
//输入栏状态切换
- (void)chatBoxViewController:(HCDChatBoxController *)chatboxViewController didChangeChatBoxHeight:(CGFloat)height;
@end

@interface HCDChatBoxController : UIViewController

//将这三者公开方便用户自己设置代理  处理相应的事件，另外方便自己自定义数据
@property (nonatomic, strong) HCDChatBoxView *chatBox;
@property (nonatomic, strong) HCDChatBoxMoreView *chatBoxMoreView;
@property (nonatomic, strong) HCDChatBoxFaceView *chatBoxFaceView;
@property(nonatomic, weak) id<HCDChatBoxViewControllerDelegate> delegate;
@end
