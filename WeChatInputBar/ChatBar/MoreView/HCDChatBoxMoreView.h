//
//  HCDChatBoxMoreView.h
//  WeChatInputBar
//
//  Created by hcd on 2018/11/5.
//  Copyright © 2018 hcd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HCDChatBoxItemView.h"

@class HCDChatBoxMoreView;
@protocol HCDChatBoxMoreViewDelegate <NSObject>
- (void)chatBoxMoreView:(HCDChatBoxMoreView *)chatBoxMoreView didSelectItemAtIndex:(NSInteger)itemIndex;
@end

@interface HCDChatBoxMoreView : UIView
@property (nonatomic, strong) id<HCDChatBoxMoreViewDelegate>delegate;
@property (nonatomic, strong) NSMutableArray<HCDChatBoxItemView *> *items;
@end
