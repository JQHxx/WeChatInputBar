//
//  ViewController.m
//  WeChatInputBar
//
//  Created by hcd on 2018/11/5.
//  Copyright © 2018 hcd. All rights reserved.
//

#import "ViewController.h"
#import "HCDChatBoxController.h"
#import "HCDChatInputBarDefine.h"
#import "UIView+HCD_Extension.h"

@interface ViewController ()<HCDChatBoxViewControllerDelegate>
@property (nonatomic, strong) HCDChatBoxController *chatBoxVC;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addChildViewController:self.chatBoxVC];
    [self.view addSubview:self.chatBoxVC.view];
}

- (HCDChatBoxController *)chatBoxVC {
    if (_chatBoxVC == nil) {
        _chatBoxVC = [[HCDChatBoxController alloc] init];
        [_chatBoxVC.view setFrame:CGRectMake(0, SCREEN_HEIGHT - HEIGHT_TABBAR, SCREEN_WIDTH, SCREEN_HEIGHT)];
        [_chatBoxVC setDelegate:self];
    }
    return _chatBoxVC;
}

#pragma mark - HCDChatBoxViewControllerDelegate
- (void)chatBoxViewController:(HCDChatBoxController *)chatboxViewController didChangeChatBoxHeight:(CGFloat)height {
    if (height == CHATBOX_HEIGHT) {
        self.chatBoxVC.view.y = SCREEN_HEIGHT - HEIGHT_TABBAR;
    } else {
        self.chatBoxVC.view.y = SCREEN_HEIGHT - height;
    }
}

@end
