//
//  LoadBalancer.h
//  BaiduHi
//  Funtion: 负载均衡器，通过确保时间间隔里，最多触发2次回调（首次回调与最后一次回调），从而控制调用频次。
//  Created by sunjinglin on 2020/4/28.
//  Copyright © 2020 baidu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ERunStatus) {
    ERunStatus_NotRunning = 0,
    ERunStatus_Running,
    ERunStatus_RepeatRunning,
};

typedef void (^RunningCallback)(ERunStatus runningStatus, int balancedCnt);

NS_ASSUME_NONNULL_BEGIN

@interface LoadBalancer : NSObject
@property (assign, nonatomic) ERunStatus runningStatus;
@property (assign) NSTimeInterval interVal;

- (instancetype)initWithInterval:(NSTimeInterval)interVal;
- (void)triggerRunning:(RunningCallback)callback dispatchQueue:(dispatch_queue_t)queue;
@end

NS_ASSUME_NONNULL_END
