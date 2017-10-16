//
//  MessageDelegate.h
//  RemoteCommandDemo
//
//  Created by 高振伟 on 17/8/29.
//  Copyright © 2017年 高振伟. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVOSCloudIM/AVOSCloudIM.h>

@interface MessageDelegate : NSObject<AVIMClientDelegate>

@property (nonatomic, strong) AVIMConversation *msgConversation;

@end
