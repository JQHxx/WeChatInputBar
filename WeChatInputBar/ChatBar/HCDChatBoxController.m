//
//  HCDChatBoxController.m
//  WeChatInputBar
//
//  Created by hcd on 2018/11/5.
//  Copyright © 2018 hcd. All rights reserved.
//

#import "HCDChatBoxController.h"
#import "UIView+HCD_Extension.h"
#import "HCDChatInputBarDefine.h"

@interface HCDChatBoxController ()<HCDChatBoxFaceViewDelegate, HCDChatBoxDelegate >
@property (nonatomic, assign) CGRect keyboardFrame;
@end

@implementation HCDChatBoxController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = COLOR(235, 235, 235);
//    self.view.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:self.chatBox];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    // 键盘的Frame值即将发生变化的时候创建的额监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self resignFirstResponder];
}

#pragma mark - Public Methods
- (BOOL)resignFirstResponder {
    if (self.chatBox.status != HCDChatBoxStatusNothing && self.chatBox.status != HCDChatBoxStatusShowVoice) {
        // 回收键盘
        [self.chatBox resignFirstResponder];
        /**
         *  在外层已经判断是不是声音状态 和 Nothing 状态了，且判断是都不是才进来的，下面在判断是否多余了？
         *  它是判断是不是要设置成Nothing状态
         */
        self.chatBox.status = (self.chatBox.status == HCDChatBoxStatusShowVoice ? self.chatBox.status : HCDChatBoxStatusNothing);
        
        if (_delegate && [_delegate respondsToSelector:@selector(chatBoxViewController:didChangeChatBoxHeight:)]) {
            [UIView animateWithDuration:0.3 animations:^{
                [self.delegate chatBoxViewController:self didChangeChatBoxHeight:self.chatBox.curHeight];
                
            } completion:^(BOOL finished) {
                [self.chatBoxFaceView removeFromSuperview];
                [self.chatBoxMoreView removeFromSuperview];
                
            }];
        }
    }
    return [super resignFirstResponder];
}


#pragma mark - HCDChatBoxDelegate
- (void)chatBox:(HCDChatBoxView *)chatBox changeChatBoxHeight:(CGFloat)height {
    self.chatBoxFaceView.y = height;
    self.chatBoxMoreView.y = height;
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatBoxViewController:didChangeChatBoxHeight:)])
    {
        // 改变 控制器高度
        float h = (self.chatBox.status == HCDChatBoxStatusShowFace ? HEIGHT_CHATBOXVIEW : self.keyboardFrame.size.height) + height;
        [self.delegate chatBoxViewController:self didChangeChatBoxHeight: h];
    }
}

- (void)chatBox:(HCDChatBoxView *)chatBox changeStatusForm:(HCDChatBoxStatus)fromStatus to:(HCDChatBoxStatus)toStatus {
    if (toStatus == HCDChatBoxStatusShowKeyboard) { // 显示键盘 删除FaceView 和 MoreView
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.chatBoxFaceView removeFromSuperview];
            [self.chatBoxMoreView removeFromSuperview];
    
        });
        return;
    } else if (toStatus == HCDChatBoxStatusShowVoice) {
        // 显示语音输入按钮
        // 从显示更多或表情状态 到 显示语音状态需要动画
        if (fromStatus == HCDChatBoxStatusShowMore || fromStatus == HCDChatBoxStatusShowFace) {
            [UIView animateWithDuration:0.3 animations:^{
                if (self.delegate && [self.delegate respondsToSelector:@selector(chatBoxViewController:didChangeChatBoxHeight:)]) {
                    [self.delegate chatBoxViewController:self didChangeChatBoxHeight:self.chatBox.curHeight];
                }
            } completion:^(BOOL finished) {
                [self.chatBoxFaceView removeFromSuperview];
                [self.chatBoxMoreView removeFromSuperview];
            }];
        } else {
            [UIView animateWithDuration:0.3 animations:^{
                if (self.delegate && [self.delegate respondsToSelector:@selector(chatBoxViewController:didChangeChatBoxHeight:)]) {
                    [self.delegate chatBoxViewController:self didChangeChatBoxHeight:self.chatBox.curHeight];
                }
            }];
        }
    } else if (toStatus == HCDChatBoxStatusShowFace) {
        /**
         *   变化到展示 表情View 的状态，这个过程中，根据 fromStatus 区分，要是是声音和无状态改变过来的，则高度变化是一样的。 其他的高度就是另外一种，根据 fromStatus 来进行一个区分。
         */
        if (fromStatus == HCDChatBoxStatusShowVoice || fromStatus == HCDChatBoxStatusNothing) {
            self.chatBoxFaceView.y = self.chatBox.curHeight;
            // 添加表情View
            [self.view addSubview:self.chatBoxFaceView];
            [UIView animateWithDuration:0.3 animations:^{
                if (self.delegate && [self.delegate respondsToSelector:@selector(chatBoxViewController:didChangeChatBoxHeight:)]) {
                    [self.delegate chatBoxViewController:self didChangeChatBoxHeight:self.chatBox.curHeight + HEIGHT_CHATBOXVIEW];
                }
            }];
        } else {
            // 表情高度变化
            self.chatBoxFaceView.y = self.chatBox.curHeight + HEIGHT_CHATBOXVIEW;
            [self.view addSubview:self.chatBoxFaceView];
            [UIView animateWithDuration:0.3 animations:^{
                self.chatBoxFaceView.y = self.chatBox.curHeight;
            } completion:^(BOOL finished) {
                [self.chatBoxMoreView removeFromSuperview];
            }];
            // 整个界面高度变化
            if (fromStatus != HCDChatBoxStatusShowMore) {
                [UIView animateWithDuration:0.2 animations:^{
                    if (self.delegate && [self.delegate respondsToSelector:@selector(chatBoxViewController:didChangeChatBoxHeight:)]) {
                        [self.delegate chatBoxViewController:self didChangeChatBoxHeight:self.chatBox.curHeight + HEIGHT_CHATBOXVIEW];
                    }
                }];
            }
        }
    } else if (toStatus == HCDChatBoxStatusShowMore) {
        // 显示更多面板
        if (fromStatus == HCDChatBoxStatusShowVoice || fromStatus == HCDChatBoxStatusNothing) {
            self.chatBoxMoreView.y = self.chatBox.curHeight;
            [self.view addSubview:self.chatBoxMoreView];
            [UIView animateWithDuration:0.3 animations:^{
                if (self.delegate && [self.delegate respondsToSelector:@selector(chatBoxViewController:didChangeChatBoxHeight:)]) {
                    [self.delegate chatBoxViewController:self didChangeChatBoxHeight:self.chatBox.curHeight + HEIGHT_CHATBOXVIEW];
                }
            }];
        } else {
            self.chatBoxMoreView.y = self.chatBox.curHeight + HEIGHT_CHATBOXVIEW;
            [self.view addSubview:self.chatBoxMoreView];
            [UIView animateWithDuration:0.3 animations:^{
                self.chatBoxMoreView.y = self.chatBox.curHeight;
            } completion:^(BOOL finished) {
                [self.chatBoxFaceView removeFromSuperview];
            }];
            
            if (fromStatus != HCDChatBoxStatusShowFace) {
                [UIView animateWithDuration:0.2 animations:^{
                    if (self.delegate && [self.delegate respondsToSelector:@selector(chatBoxViewController:didChangeChatBoxHeight:)]) {
                        [self.delegate chatBoxViewController:self didChangeChatBoxHeight:self.chatBox.curHeight + HEIGHT_CHATBOXVIEW];
                    }
                }];
            }
        }
    }
}

#pragma mark - HCDChatBoxFaceViewDelegate
- (void)chatBoxFaceViewDidSelectedFace:(HCDChatFace *)face type:(HCDFaceType)type {
    if (type == HCDFaceTypeEmoji) {
        [self.chatBox addEmojiFace:face];
    }
}

- (void)chatBoxFaceViewDeleteButtonDown {
    [self.chatBox deleteButtonDown];
}

- (void)chatBoxFaceViewSendButtonDown {
    [self.chatBox sendCurrentMessage];
}

#pragma mark - Getter
- (HCDChatBoxView *)chatBox {
    // 6 的初始化 0.0.375.49
    if (_chatBox == nil) {
        _chatBox = [[HCDChatBoxView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, CHATBOX_HEIGHT)];
        [_chatBox setDelegate:self]; // 0 0 宽 49
    }
    return _chatBox;
}

// 添加创建更多View
- (HCDChatBoxMoreView *)chatBoxMoreView {
    if (_chatBoxMoreView == nil) {
        _chatBoxMoreView = [[HCDChatBoxMoreView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, HEIGHT_CHATBOXVIEW)];
        // [_chatBoxMoreView setDelegate:self];
        
        HCDChatBoxItemView *photosItem = [HCDChatBoxItemView createChatBoxMoreItemWithTitle:@"照片" imageName:@"sharemore_pic"];
        HCDChatBoxItemView *takePictureItem = [HCDChatBoxItemView createChatBoxMoreItemWithTitle:@"拍摄" imageName:@"sharemore_video"];
        HCDChatBoxItemView *videoItem = [HCDChatBoxItemView createChatBoxMoreItemWithTitle:@"小视频" imageName:@"sharemore_sight"];
        HCDChatBoxItemView *videoCallItem = [HCDChatBoxItemView createChatBoxMoreItemWithTitle:@"视频聊天" imageName:@"sharemore_videovoip"];
        HCDChatBoxItemView *giftItem = [HCDChatBoxItemView createChatBoxMoreItemWithTitle:@"红包" imageName:@"sharemore_wallet"];
        HCDChatBoxItemView *transferItem = [HCDChatBoxItemView createChatBoxMoreItemWithTitle:@"转账" imageName:@"sharemorePay"];
        HCDChatBoxItemView *positionItem = [HCDChatBoxItemView createChatBoxMoreItemWithTitle:@"位置" imageName:@"sharemore_location"];
        HCDChatBoxItemView *favoriteItem = [HCDChatBoxItemView createChatBoxMoreItemWithTitle:@"收藏" imageName:@"sharemore_myfav"];
        HCDChatBoxItemView *businessCardItem = [HCDChatBoxItemView createChatBoxMoreItemWithTitle:@"名片" imageName:@"sharemore_friendcard" ];
        HCDChatBoxItemView *interphoneItem = [HCDChatBoxItemView createChatBoxMoreItemWithTitle:@"实时对讲机" imageName:@"sharemore_wxtalk" ];
        HCDChatBoxItemView *voiceItem = [HCDChatBoxItemView createChatBoxMoreItemWithTitle:@"语音输入" imageName:@"sharemore_voiceinput"];
        HCDChatBoxItemView *cardsItem = [HCDChatBoxItemView createChatBoxMoreItemWithTitle:@"卡券" imageName:@"sharemore_wallet"];
        [_chatBoxMoreView setItems:[[NSMutableArray alloc] initWithObjects:photosItem, takePictureItem, videoItem, videoCallItem, giftItem, transferItem, positionItem, favoriteItem, businessCardItem, interphoneItem, voiceItem, cardsItem, nil]];
    }
    return _chatBoxMoreView;
}

- (HCDChatBoxFaceView *)chatBoxFaceView {
    if (_chatBoxFaceView == nil) {
        _chatBoxFaceView = [[HCDChatBoxFaceView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, HEIGHT_CHATBOXVIEW)];
        [_chatBoxFaceView setDelegate:self];
    }
    return _chatBoxFaceView;
}

#pragma mark - Private Methods
- (void)keyboardWillHide:(NSNotification *)notification {
    self.keyboardFrame = CGRectZero;
    if (_chatBox.status == HCDChatBoxStatusShowFace || _chatBox.status == HCDChatBoxStatusShowMore) {
        return;
    }
    if (_delegate && [_delegate respondsToSelector:@selector(chatBoxViewController:didChangeChatBoxHeight:)]) {
        [_delegate chatBoxViewController:self didChangeChatBoxHeight:self.chatBox.curHeight];
    }
}

- (void)keyboardFrameWillChange:(NSNotification *)notification {
    // 键盘的Frame
    // po self.keyboardFrame 第一次点击 textview 的时候的值
    // (origin = (x = 0, y = 409), size = (width = 375, height = 258))
    // po self.chatBox.curHeight   49

    self.keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    if (_chatBox.status == HCDChatBoxStatusShowKeyboard && self.keyboardFrame.size.height <= HEIGHT_CHATBOXVIEW) {
        return;
    } else if ((_chatBox.status == HCDChatBoxStatusShowFace || _chatBox.status == HCDChatBoxStatusShowMore) && self.keyboardFrame.size.height <= HEIGHT_CHATBOXVIEW) {
        return;
    }
    if (_delegate && [_delegate respondsToSelector:@selector(chatBoxViewController:didChangeChatBoxHeight:)]) {
        // 改变控制器.View 的高度 键盘的高度 + 当前的 49
        [_delegate chatBoxViewController:self didChangeChatBoxHeight: self.keyboardFrame.size.height + self.chatBox.curHeight];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

@end
