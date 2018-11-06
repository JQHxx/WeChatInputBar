//
//  HCDChatHelper.h
//  WeChatInputBar
//
//  Created by hcd on 2018/11/5.
//  Copyright © 2018 hcd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HCDChatHelper : NSObject
@property (nonatomic, strong) NSMutableArray *faceGroupArray;
+ (NSAttributedString *)formatMessageString:(NSString *)text;
@end
