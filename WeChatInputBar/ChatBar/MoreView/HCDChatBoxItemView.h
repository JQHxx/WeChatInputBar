//
//  HCDChatBoxItemView.h
//  WeChatInputBar
//
//  Created by hcd on 2018/11/5.
//  Copyright © 2018 hcd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HCDChatBoxItemView : UIView


@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *imageName;

+ (HCDChatBoxItemView *)createChatBoxMoreItemWithTitle:(NSString *)title
                                             imageName:(NSString *)imageName;
- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;
@end
