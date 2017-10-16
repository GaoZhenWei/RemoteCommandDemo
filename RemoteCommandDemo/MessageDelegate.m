//
//  MessageDelegate.m
//  RemoteCommandDemo
//
//  Created by 高振伟 on 17/8/29.
//  Copyright © 2017年 高振伟. All rights reserved.
//

#import "MessageDelegate.h"

@implementation MessageDelegate

#pragma mark - AVIMClientDelegate

/*!
 接收到新的普通消息。
 @param conversation － 所属对话
 @param message - 具体的消息
 */
- (void)conversation:(AVIMConversation *)conversation didReceiveCommonMessage:(AVIMMessage *)message
{
    NSLog(@"[Jerry]: receive common msg: %@", message.content);
}

/*!
 接收到新的富媒体消息。
 @param conversation － 所属对话
 @param message - 具体的消息
 */
- (void)conversation:(AVIMConversation *)conversation didReceiveTypedMessage:(AVIMTypedMessage *)message
{
    self.msgConversation = conversation;
    NSLog(@"[Jerry]: receive typed msg: %@", message.content);
}

/*!
 消息已投递给对方。
 @param conversation － 所属对话
 @param message - 具体的消息
 */
- (void)conversation:(AVIMConversation *)conversation messageDelivered:(AVIMMessage *)message
{
    NSLog(@"[Jerry]: deliver msg succed: %@", message.content);
}

/*!
 客户端下线通知。
 @param client 已下线的 client。
 @param error 错误信息。
 */
- (void)client:(AVIMClient *)client didOfflineWithError:(NSError *)error
{
    NSLog(@"[Jerry]: %@ has go offline", client.clientId);
}

@end
