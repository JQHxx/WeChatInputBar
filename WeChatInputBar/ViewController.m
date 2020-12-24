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

#define IS_iPHONE_X ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? ((NSInteger)(([[UIScreen mainScreen] currentMode].size.height/[[UIScreen mainScreen] currentMode].size.width)*100) == 216) : NO)

@interface ViewController ()<HCDChatBoxViewControllerDelegate>
@property (nonatomic, strong) HCDChatBoxController *chatBoxVC;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addChildViewController:self.chatBoxVC];
    [self.view addSubview:self.chatBoxVC.view];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.chatBoxVC resignFirstResponder];
}

- (HCDChatBoxController *)chatBoxVC {
    if (_chatBoxVC == nil) {
        _chatBoxVC = [[HCDChatBoxController alloc] init];
        [_chatBoxVC.view setFrame:CGRectMake(0, SCREEN_HEIGHT - HEIGHT_TABBAR - (IS_iPHONE_X ? 34 : 0), SCREEN_WIDTH, SCREEN_HEIGHT)];
        [_chatBoxVC setDelegate:self];
    }
    return _chatBoxVC;
}

#pragma mark - HCDChatBoxViewControllerDelegate
- (void)chatBoxViewController:(HCDChatBoxController *)chatboxViewController didChangeChatBoxHeight:(CGFloat)height {
    if (height == CHATBOX_HEIGHT) {
        self.chatBoxVC.view.y = SCREEN_HEIGHT - HEIGHT_TABBAR - (IS_iPHONE_X ? 34 : 0);
    } else {
        self.chatBoxVC.view.y = SCREEN_HEIGHT - height - (IS_iPHONE_X ? 34 : 0);
    }
}

@end
