//
//  HCDChatBoxView.h
//  WeChatInputBar
//
//  Created by hcd on 2018/11/5.
//  Copyright © 2018 hcd. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, HCDChatBoxStatus) {
    HCDChatBoxStatusNothing = 0,
    HCDChatBoxStatusShowVoice,
    HCDChatBoxStatusShowFace,
    HCDChatBoxStatusShowMore,
    HCDChatBoxStatusShowKeyboard
};

@class HCDChatBoxView, HCDChatFace;
@protocol HCDChatBoxDelegate <NSObject>
@optional
- (void)chatBox:(HCDChatBoxView *)chatBox changeStatusForm:(HCDChatBoxStatus)fromStatus to:(HCDChatBoxStatus)toStatus;
- (void)chatBox:(HCDChatBoxView *)chatBox sendTextMessage:(NSString *)textMessage;
- (void)chatBox:(HCDChatBoxView *)chatBox changeChatBoxHeight:(CGFloat)height;
@end

@interface HCDChatBoxView : UIView
@property (nonatomic, assign) id<HCDChatBoxDelegate>delegate;
@property (nonatomic, assign) HCDChatBoxStatus status;
@property (nonatomic, assign) CGFloat curHeight;

- (void)addEmojiFace:(HCDChatFace *)face;
- (void)sendCurrentMessage;
- (void)deleteButtonDown;

@end

NS_ASSUME_NONNULL_END
