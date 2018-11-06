//
//  HCDChatBoxView.m
//  WeChatInputBar
//
//  Created by hcd on 2018/11/5.
//  Copyright © 2018 hcd. All rights reserved.
//

#import "HCDChatBoxView.h"
#import "UIView+HCD_Extension.h"
#import "HCDChatInputBarDefine.h"
#import "HCDChatFace.h"
#import "UIImage+HCD_Extension.h"

@interface HCDChatBoxView ()<UITextViewDelegate>
@property (nonatomic, strong) UIView *topLine; // 顶部的线
@property (nonatomic, strong) UIButton *voiceButton; // 声音按钮
@property (nonatomic, strong) UITextView *textView;  // 输入框
@property (nonatomic, strong) UIButton *faceButton;  // 表情按钮
@property (nonatomic, strong) UIButton *moreButton;  // 更多按钮
@property (nonatomic, strong) UIButton *talkButton;  // 聊天键盘按钮
@end

@implementation HCDChatBoxView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _curHeight = frame.size.height;// 当前高度初始化为 49
        [self setBackgroundColor:DEFAULT_CHATBOX_COLOR];
        [self addSubview:self.topLine];
        [self addSubview:self.voiceButton];
        [self addSubview:self.textView];
        [self addSubview:self.faceButton];
        [self addSubview:self.moreButton];
        [self addSubview:self.talkButton];
        self.status = HCDChatBoxStatusNothing;//初始化状态是空
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    // 6 的初始化 0.0.375.49
    [super setFrame:frame];
    self.topLine.width = self.width;
    //  y=  49 -  ( CHATBOX_BUTTON_WIDTH )  37 - (View 的H - Button的H )/2
    //  Voice 的高度和宽度初始化的时候都是 37
    float y = self.height - self.voiceButton.height - (CHATBOX_HEIGHT - CHATBOX_BUTTON_WIDTH) / 2;
    if (self.voiceButton.y != y) {
        [UIView animateWithDuration:0.1 animations:^{
            // 根据 Voice 的 Y 改变 faceButton  moreButton de Y
            self.voiceButton.y = y;
            self.faceButton.y = self.voiceButton.y;
            self.moreButton.y = self.voiceButton.y;
        }];
    }
}

#pragma Public Methods
- (BOOL)resignFirstResponder {
    [self.textView resignFirstResponder];
    [_moreButton setImage:[UIImage imageNamed:@"TypeSelectorBtn_Black"] forState:UIControlStateNormal];
    [_moreButton setImage:[UIImage imageNamed:@"TypeSelectorBtnHL_Black"] forState:UIControlStateHighlighted];
    [_faceButton setImage:[UIImage imageNamed:@"ToolViewEmotion"] forState:UIControlStateNormal];
    [_faceButton setImage:[UIImage imageNamed:@"ToolViewEmotionHL"] forState:UIControlStateHighlighted];
    return [super resignFirstResponder];
}

- (void)addEmojiFace:(HCDChatFace *)face {
    [self.textView setText:[self.textView.text stringByAppendingString:face.faceName]];
    if (MAX_TEXTVIEW_HEIGHT < self.textView.contentSize.height) {
        float y = self.textView.contentSize.height - self.textView.height;
        y = y < 0 ? 0 : y;
        [self.textView scrollRectToVisible:CGRectMake(0, y, self.textView.width, self.textView.height) animated:YES];
    }
    [self textViewDidChange:self.textView];
}

- (void)sendCurrentMessage {
    if (self.textView.text.length > 0) {// send Text
        if (_delegate && [_delegate respondsToSelector:@selector(chatBox:sendTextMessage:)]) {
            [_delegate chatBox:self sendTextMessage:self.textView.text];
        }
    }
    [self.textView setText:@""];
    [self textViewDidChange:self.textView];
}

- (void)deleteButtonDown {
    [self textView:self.textView shouldChangeTextInRange:NSMakeRange(self.textView.text.length - 1, 1) replacementText:@""];
    [self textViewDidChange:self.textView];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    HCDChatBoxStatus lastStatus = self.status;
    self.status = HCDChatBoxStatusShowKeyboard;
    if (lastStatus == HCDChatBoxStatusShowFace) {
        [_faceButton setImage:[UIImage imageNamed:@"ToolViewEmotion"] forState:UIControlStateNormal];
        [_faceButton setImage:[UIImage imageNamed:@"ToolViewEmotionHL"] forState:UIControlStateHighlighted];
    } else if (lastStatus == HCDChatBoxStatusShowMore) {
        [_moreButton setImage:[UIImage imageNamed:@"TypeSelectorBtn_Black"] forState:UIControlStateNormal];
        [_moreButton setImage:[UIImage imageNamed:@"TypeSelectorBtnHL_Black"] forState:UIControlStateHighlighted];
    }
    if (_delegate && [_delegate respondsToSelector:@selector(chatBox:changeStatusForm:to:)]) {
        [_delegate chatBox:self changeStatusForm:lastStatus to:self.status];
    }
    
}

- (void)textViewDidChange:(UITextView *)textView {
    /**
     *   textView 的 Frame 值是按照 talkButton  设置的
     sizeThatSize并没有改变原始 textView 的大小
     [label sizeToFit]; 这样搞就直接改变了这个label的宽和高，使它根据上面字符串的大小做合适的改变
     */
    CGFloat height = [textView sizeThatFits:CGSizeMake(self.textView.width, MAXFLOAT)].height;
    height = height > HEIGHT_TEXTVIEW ? height : HEIGHT_TEXTVIEW; // height大于 TextView 的高度 就取height 否则就取 TextView 的高度
    
    height = height < MAX_TEXTVIEW_HEIGHT ? height : textView.height;  // height 小于 textView 的最大高度 104 就取出 height 不然就取出  textView.frameHeight
    
    _curHeight = height + CHATBOX_HEIGHT - HEIGHT_TEXTVIEW;
    if (_curHeight != self.height) {
        [UIView animateWithDuration:0.05 animations:^{
            self.height = self.curHeight;
            if (self.delegate && [self.delegate respondsToSelector:@selector(chatBox:changeChatBoxHeight:)]) {
                [self.delegate chatBox:self changeChatBoxHeight:self.curHeight];
            }
        }];
    }
    
    if (height != textView.height) {
        [UIView animateWithDuration:0.05 animations:^{
            textView.height = height;
        }];
    }
}

////内容将要发生改变编辑
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]){
        [self sendCurrentMessage];
        return NO;
    } else if (textView.text.length > 0 && [text isEqualToString:@""]) {// delete
        if ([textView.text characterAtIndex:range.location] == ']') {
            NSUInteger location = range.location;
            NSUInteger length = range.length;
            while (location != 0) {
                location --;
                length ++ ;
                char c = [textView.text characterAtIndex:location];
                if (c == '[') {
                    textView.text = [textView.text stringByReplacingCharactersInRange:NSMakeRange(location, length) withString:@""];
                    return NO;
                } else if (c == ']') {
                    return YES;
                }
            }
        } else {
            textView.text = [textView.text stringByReplacingCharactersInRange:NSMakeRange(textView.text.length - 1, 1) withString:@""];
            return NO;
        }
    }
    return YES;
}

#pragma mark - Event Response
- (void)voiceButtonDown:(UIButton *)sender {
    HCDChatBoxStatus lastStatus = self.status;
    if (lastStatus == HCDChatBoxStatusShowVoice) {      // 正在显示talkButton，改为现实键盘状态
        self.status = HCDChatBoxStatusShowKeyboard;
        [self.talkButton setHidden:YES];
        [self.textView setHidden:NO];
        [self.textView becomeFirstResponder];
        [_voiceButton setImage:[UIImage imageNamed:@"ToolViewInputVoice"] forState:UIControlStateNormal];
        [_voiceButton setImage:[UIImage imageNamed:@"ToolViewInputVoiceHL"] forState:UIControlStateHighlighted];
        
        [self textViewDidChange:self.textView];
        if (_delegate && [_delegate respondsToSelector:@selector(chatBox:changeStatusForm:to:)]) {
            [_delegate chatBox:self changeStatusForm:lastStatus to:self.status];
        }
    } else {
        // 显示talkButton
        self.curHeight = CHATBOX_HEIGHT;
        self.height = self.curHeight;
        self.status = HCDChatBoxStatusShowVoice;// 如果不是显示讲话的Button，就显示讲话的Button，状态也改变为 shouvoice
        [self.textView resignFirstResponder];
        [self.textView setHidden:YES];
        [self.talkButton setHidden:NO];
        [_voiceButton setImage:[UIImage imageNamed:@"ToolViewKeyboard"] forState:UIControlStateNormal];
        [_voiceButton setImage:[UIImage imageNamed:@"ToolViewKeyboardHL"] forState:UIControlStateHighlighted];
        if (lastStatus == HCDChatBoxStatusShowFace) {
            [_faceButton setImage:[UIImage imageNamed:@"ToolViewEmotion"] forState:UIControlStateNormal];
            [_faceButton setImage:[UIImage imageNamed:@"ToolViewEmotionHL"] forState:UIControlStateHighlighted];
        } else if (lastStatus == HCDChatBoxStatusShowMore) {
            [_moreButton setImage:[UIImage imageNamed:@"TypeSelectorBtn_Black"] forState:UIControlStateNormal];
            [_moreButton setImage:[UIImage imageNamed:@"TypeSelectorBtnHL_Black"] forState:UIControlStateHighlighted];
        }
        if (_delegate && [_delegate respondsToSelector:@selector(chatBox:changeStatusForm:to:)]) {
            [_delegate chatBox:self changeStatusForm:lastStatus to:self.status];
            
        }
    }
}

- (void)faceButtonDown:(UIButton *)sender {
    HCDChatBoxStatus lastStatus = self.status;// 记录下上次的状态
    if (lastStatus == HCDChatBoxStatusShowFace) {
        // 正在显示表情，改为现实键盘状态
        self.status = HCDChatBoxStatusShowKeyboard;
        [_faceButton setImage:[UIImage imageNamed:@"ToolViewEmotion"] forState:UIControlStateNormal];
        [_faceButton setImage:[UIImage imageNamed:@"ToolViewEmotionHL"] forState:UIControlStateHighlighted];
        [self.textView becomeFirstResponder];
        if (_delegate && [_delegate respondsToSelector:@selector(chatBox:changeStatusForm:to:)]) {
            [_delegate chatBox:self changeStatusForm:lastStatus to:self.status];
        }
    } else {
        self.status = HCDChatBoxStatusShowFace;
        [_faceButton setImage:[UIImage imageNamed:@"ToolViewKeyboard"] forState:UIControlStateNormal];
        [_faceButton setImage:[UIImage imageNamed:@"ToolViewKeyboardHL"] forState:UIControlStateHighlighted];
        if (lastStatus == HCDChatBoxStatusShowMore) {
            [_moreButton setImage:[UIImage imageNamed:@"TypeSelectorBtn_Black"] forState:UIControlStateNormal];
            [_moreButton setImage:[UIImage imageNamed:@"TypeSelectorBtnHL_Black"] forState:UIControlStateHighlighted];
        } else if (lastStatus == HCDChatBoxStatusShowVoice) {
            [_voiceButton setImage:[UIImage imageNamed:@"ToolViewInputVoice"] forState:UIControlStateNormal];
            [_voiceButton setImage:[UIImage imageNamed:@"ToolViewInputVoiceHL"] forState:UIControlStateHighlighted];
            [_talkButton setHidden:YES];
            [_textView setHidden:NO];
            [self textViewDidChange:self.textView];
        } else if (lastStatus == HCDChatBoxStatusShowKeyboard) {
            [self.textView resignFirstResponder];
        }
        
        if (_delegate && [_delegate respondsToSelector:@selector(chatBox:changeStatusForm:to:)]) {
            [_delegate chatBox:self changeStatusForm:lastStatus to:self.status];
        }
    }
}

- (void)moreButtonDown:(UIButton *)sender {
    HCDChatBoxStatus lastStatus = self.status;
    if (lastStatus == HCDChatBoxStatusShowMore) {
        self.status = HCDChatBoxStatusShowKeyboard;
        [_moreButton setImage:[UIImage imageNamed:@"TypeSelectorBtn_Black"] forState:UIControlStateNormal];
        [_moreButton setImage:[UIImage imageNamed:@"TypeSelectorBtnHL_Black"] forState:UIControlStateHighlighted];
        [self.textView becomeFirstResponder];
        if (_delegate && [_delegate respondsToSelector:@selector(chatBox:changeStatusForm:to:)]) {
            [_delegate chatBox:self changeStatusForm:lastStatus to:self.status];
        }
    } else {
        self.status = HCDChatBoxStatusShowMore;
        [_moreButton setImage:[UIImage imageNamed:@"ToolViewKeyboard"] forState:UIControlStateNormal];
        [_moreButton setImage:[UIImage imageNamed:@"ToolViewKeyboardHL"] forState:UIControlStateHighlighted];
        if (lastStatus == HCDChatBoxStatusShowFace) {
            [_faceButton setImage:[UIImage imageNamed:@"ToolViewEmotion"] forState:UIControlStateNormal];
            [_faceButton setImage:[UIImage imageNamed:@"ToolViewEmotionHL"] forState:UIControlStateHighlighted];
        } else if (lastStatus == HCDChatBoxStatusShowVoice) {
            [_voiceButton setImage:[UIImage imageNamed:@"ToolViewInputVoice"] forState:UIControlStateNormal];
            [_voiceButton setImage:[UIImage imageNamed:@"ToolViewInputVoiceHL"] forState:UIControlStateHighlighted];
            [_talkButton setHidden:YES];
            [_textView setHidden:NO];
            [self textViewDidChange:self.textView];
        } else if (lastStatus == HCDChatBoxStatusShowKeyboard) {
            [self.textView resignFirstResponder];
        }
        if (_delegate && [_delegate respondsToSelector:@selector(chatBox:changeStatusForm:to:)]) {
            [_delegate chatBox:self changeStatusForm:lastStatus to:self.status];
        }
    }
}

- (void)talkButtonDown:(UIButton *)sender {
    [_talkButton setTitle:@"松开 结束" forState:UIControlStateNormal];
    [_talkButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:0.5]] forState:UIControlStateNormal];
}

- (void)talkButtonUpInside:(UIButton *)sender {
    [_talkButton setTitle:@"按住 说话" forState:UIControlStateNormal];
    [_talkButton setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
}

- (void)talkButtonUpOutside:(UIButton *)sender {
    [_talkButton setTitle:@"按住 说话" forState:UIControlStateNormal];
    [_talkButton setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
}

#pragma mark - Getter
- (UIView *)topLine {
    if (_topLine == nil) {
        _topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.5)];
        [_topLine setBackgroundColor:COLORA(165, 165, 165, 1.0)];
    }
    return _topLine;
}

- (UIButton *)voiceButton {
    if (_voiceButton == nil) {
        _voiceButton = [[UIButton alloc] initWithFrame:CGRectMake(0, (CHATBOX_HEIGHT - CHATBOX_BUTTON_WIDTH) / 2, CHATBOX_BUTTON_WIDTH, CHATBOX_BUTTON_WIDTH)];
        [_voiceButton setImage:[UIImage imageNamed:@"ToolViewInputVoice"] forState:UIControlStateNormal];
        [_voiceButton setImage:[UIImage imageNamed:@"ToolViewInputVoiceHL"] forState:UIControlStateHighlighted];
        [_voiceButton addTarget:self action:@selector(voiceButtonDown:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _voiceButton;
}

- (UITextView *)textView {
    if (_textView == nil) {
        _textView = [[UITextView alloc] initWithFrame:self.talkButton.frame];
        [_textView setFont:[UIFont systemFontOfSize:16.0f]];
        [_textView.layer setMasksToBounds:YES];
        [_textView.layer setCornerRadius:4.0f];
        [_textView.layer setBorderWidth:0.5f];
        [_textView.layer setBorderColor:self.topLine.backgroundColor.CGColor];
        [_textView setScrollsToTop:NO];
        [_textView setReturnKeyType:UIReturnKeySend];// 返回按钮更改为发送
        [_textView setDelegate:self];
    }
    return _textView;
}

- (UIButton *)faceButton {
    if (_faceButton == nil) {
        _faceButton = [[UIButton alloc] initWithFrame:CGRectMake(self.moreButton.x - CHATBOX_BUTTON_WIDTH, self.voiceButton.y, CHATBOX_BUTTON_WIDTH, CHATBOX_BUTTON_WIDTH)];
        [_faceButton setImage:[UIImage imageNamed:@"ToolViewEmotion"] forState:UIControlStateNormal];
        [_faceButton setImage:[UIImage imageNamed:@"ToolViewEmotionHL"] forState:UIControlStateHighlighted];
        [_faceButton addTarget:self action:@selector(faceButtonDown:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _faceButton;
}

- (UIButton *)moreButton {
    if (_moreButton == nil) {
        _moreButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - CHATBOX_BUTTON_WIDTH, self.voiceButton.y, CHATBOX_BUTTON_WIDTH, CHATBOX_BUTTON_WIDTH)];
        [_moreButton setImage:[UIImage imageNamed:@"TypeSelectorBtn_Black"] forState:UIControlStateNormal];
        [_moreButton setImage:[UIImage imageNamed:@"TypeSelectorBtnHL_Black"] forState:UIControlStateHighlighted];
        [_moreButton addTarget:self action:@selector(moreButtonDown:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreButton;
}

- (UIButton *)talkButton {
    if (_talkButton == nil) {
        _talkButton = [[UIButton alloc] initWithFrame:CGRectMake(self.voiceButton.x + self.voiceButton.width + 4, self.height * 0.13, self.faceButton.x - self.voiceButton.x - self.voiceButton.width - 8, HEIGHT_TEXTVIEW)];
        [_talkButton setTitle:@"按住 说话" forState:UIControlStateNormal];
        [_talkButton setTitle:@"松开 结束" forState:UIControlStateHighlighted];
        [_talkButton setTitleColor:[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0] forState:UIControlStateNormal];
        [_talkButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:0.5]] forState:UIControlStateHighlighted];
        [_talkButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
        [_talkButton.layer setMasksToBounds:YES];
        [_talkButton.layer setCornerRadius:4.0f];
        [_talkButton.layer setBorderWidth:0.5f];
        [_talkButton.layer setBorderColor:self.topLine.backgroundColor.CGColor];
        [_talkButton setHidden:YES];
        [_talkButton addTarget:self action:@selector(talkButtonDown:) forControlEvents:UIControlEventTouchDown];
        [_talkButton addTarget:self action:@selector(talkButtonUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [_talkButton addTarget:self action:@selector(talkButtonUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
        [_talkButton addTarget:self action:@selector(talkButtonUpOutside:) forControlEvents:UIControlEventTouchCancel];
    }
    return _talkButton;
}

@end
