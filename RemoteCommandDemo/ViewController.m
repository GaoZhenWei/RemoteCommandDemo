//
//  ViewController.m
//  RemoteCommandDemo
//
//  Created by 高振伟 on 17/8/28.
//  Copyright © 2017年 高振伟. All rights reserved.
//

#import "ViewController.h"
#import <AVOSCloudIM/AVOSCloudIM.h>
#import "MessageDelegate.h"

@interface ViewController ()<AVIMClientDelegate>

@property (nonatomic, strong) AVIMClient *tomClient;
@property (nonatomic, strong) AVIMClient *jerryClient;
@property (nonatomic, strong) AVIMConversation *conversation;
@property (weak, nonatomic) IBOutlet UITextField *deviceIdTF;
@property (weak, nonatomic) IBOutlet UITextField *sendMsgTF;
@property (nonatomic, strong) MessageDelegate *messageDelegate;
@property (weak, nonatomic) IBOutlet UITextField *replyTF;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tomClient = [[AVIMClient alloc] initWithClientId:@"Tom"];
    self.tomClient.delegate = self;
    
    self.jerryClient = [[AVIMClient alloc] initWithClientId:@"Jerry"];
    self.messageDelegate = [[MessageDelegate alloc] init];
    self.jerryClient.delegate = self.messageDelegate;
}

- (IBAction)startService:(UIButton *)sender {
    [self.tomClient openWithCallback:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            NSLog(@"tom open client success");
        } else {
            NSLog(@"tom open client error: %@", error);
        }
    }];
    
    [self.jerryClient openWithCallback:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            NSLog(@"jerry open client success");
        } else {
            NSLog(@"jerry open client error: %@", error);
        }
    }];
}

- (IBAction)closeService:(UIButton *)sender {
    [self.tomClient closeWithCallback:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            NSLog(@"tom close client success");
        } else {
            NSLog(@"tom close client error: %@", error);
        }
    }];
    
    [self.jerryClient closeWithCallback:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            NSLog(@"jerry close client success");
        } else {
            NSLog(@"jerry close client error: %@", error);
        }
    }];
}

- (IBAction)checkStatus:(UIButton *)sender {
    [self.tomClient queryOnlineClientsInClients:@[self.deviceIdTF.text] callback:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (!error) {
            if (objects.count > 0) {
                NSLog(@"current status is online");
            } else {
                NSLog(@"current status is offline");
            }
        } else {
            NSLog(@"query status error: %@", error);
        }
    }];
}

- (IBAction)createConversation:(UIButton *)sender {
    // 创建原子会话
    __weak typeof(self) weakSelf = self;
    AVIMConversationOption option = AVIMConversationOptionNone | AVIMConversationOptionUnique;
    [self.tomClient createConversationWithName:self.deviceIdTF.text clientIds:@[self.deviceIdTF.text] attributes:nil options:option callback:^(AVIMConversation * _Nullable conversation, NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!error) {
            strongSelf.conversation = conversation;
            NSLog(@"create conversation success");
        } else {
            NSLog(@"create conversation error: %@", error);
        }
    }];
    
    // 每次都创建新的会话
//    __weak typeof(self) weakSelf = self;
//    [self.tomClient createConversationWithName:self.deviceIdTF.text clientIds:@[self.deviceIdTF.text] callback:^(AVIMConversation * _Nullable conversation, NSError * _Nullable error) {
//        __strong typeof(weakSelf) strongSelf = weakSelf;
//        if (!error) {
//            strongSelf.conversation = conversation;
//            NSLog(@"create conversation success");
//        } else {
//            NSLog(@"create conversation error: %@", error);
//        }
//    }];
}

- (IBAction)sendMessage:(UIButton *)sender {
    // 设置消息回执
    AVIMMessageOption *option = [[AVIMMessageOption alloc] init];
    option.receipt = YES;
    [self.conversation sendMessage:[AVIMTextMessage messageWithText:self.sendMsgTF.text attributes:nil] option:option callback:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            NSLog(@"send message success");
        } else {
            NSLog(@"send message error: %@", error);
        }
    }];
    
    // 未设置消息回执
//    [self.conversation sendMessage:[AVIMTextMessage messageWithText:self.sendMsgTF.text attributes:nil] callback:^(BOOL succeeded, NSError * _Nullable error) {
//        if (succeeded) {
//            NSLog(@"send message success");
//        } else {
//            NSLog(@"send message error: %@", error);
//        }
//    }];
}

- (IBAction)replyMessage:(UIButton *)sender {
    
    if (self.messageDelegate.msgConversation) {
        [self.messageDelegate.msgConversation sendMessage:[AVIMTextMessage messageWithText:self.replyTF.text attributes:nil] callback:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                NSLog(@"reply message success");
            } else {
                NSLog(@"reply message error: %@", error);
            }
        }];
    }
}

- (IBAction)fetchHistoryMessage:(UIButton *)sender {
    AVIMConversationQuery *query = [self.tomClient conversationQuery];
    [query whereKey:@"name" equalTo:self.deviceIdTF.text];
    [query findConversationsWithCallback:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (!error) {
            if (objects.count > 0) {
                AVIMConversation *conversation = objects[0];
                [conversation queryMessagesWithLimit:20 callback:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                    if (!error) {
                        for (AVIMTextMessage *msg in objects) {
                            NSLog(@"message: %@", msg.text);
                        }
                    }
                }];
            }
        } else {
            NSLog(@"query history message error: %@", error);
        }
    }];
}


#pragma mark - AVIMClientDelegate

/*!
 接收到新的普通消息。
 @param conversation － 所属对话
 @param message - 具体的消息
 */
- (void)conversation:(AVIMConversation *)conversation didReceiveCommonMessage:(AVIMMessage *)message
{
    NSLog(@"[Tom]: receive common msg: %@", message.content);
}

/*!
 接收到新的富媒体消息。
 @param conversation － 所属对话
 @param message - 具体的消息
 */
- (void)conversation:(AVIMConversation *)conversation didReceiveTypedMessage:(AVIMTypedMessage *)message
{
    NSLog(@"[Tom]: receive typed msg: %@", message.content);
}

/*!
 消息已投递给对方。
 @param conversation － 所属对话
 @param message - 具体的消息
 */
- (void)conversation:(AVIMConversation *)conversation messageDelivered:(AVIMMessage *)message
{
    NSLog(@"[Tom]: deliver msg succed: %@", message.content);
}

/*!
 客户端下线通知。
 @param client 已下线的 client。
 @param error 错误信息。
 */
- (void)client:(AVIMClient *)client didOfflineWithError:(NSError *)error
{
    NSLog(@"[Tom]: %@ has go offline", client.clientId);
}

@end
