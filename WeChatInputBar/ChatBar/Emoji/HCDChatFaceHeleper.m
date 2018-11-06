//
//  HCDChatFaceHeleper.m
//  WeChatInputBar
//
//  Created by hcd on 2018/11/5.
//  Copyright © 2018 hcd. All rights reserved.
//

#import "HCDChatFaceHeleper.h"
#import "HCDChatFace.h"

static HCDChatFaceHeleper * faceHeleper = nil;
@implementation HCDChatFaceHeleper

+ (HCDChatFaceHeleper * )sharedFaceHelper {
    if (!faceHeleper) {
        faceHeleper = [[HCDChatFaceHeleper alloc] init];
    }
    return faceHeleper;
}

#pragma mark - Public Methods
- (NSArray<HCDChatFace *>*)getFaceArrayByGroupID:(NSString *)groupID {
    NSArray *array = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:groupID ofType:@"plist"]];
    NSMutableArray *data = [[NSMutableArray alloc] initWithCapacity:array.count];
    for (NSDictionary *dic in array) {
        HCDChatFace *face = [[HCDChatFace alloc] init];
        face.faceID = [dic objectForKey:@"face_id"];
        face.faceName = [dic objectForKey:@"face_name"];
        [data addObject:face];
    }
    return data;
}

#pragma mark - Getter
- (NSMutableArray<HCDChatFaceGroup *> *)faceGroupArray {
    if (_faceGroupArray == nil) {
        _faceGroupArray = [[NSMutableArray alloc] init];
        HCDChatFaceGroup *group = [[HCDChatFaceGroup alloc] init];
        group.faceType = HCDFaceTypeEmoji;
        group.groupID = @"normal_face";
        group.groupImageName = @"EmotionsEmojiHL";
        group.facesArray = nil;
        [_faceGroupArray addObject:group];
    }
    return _faceGroupArray;
}

@end
