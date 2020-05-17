//
//  LoadBalancer.m
//  BaiduHi
//
//  Created by sunjinglin on 2020/4/28.
//  Copyright © 2020 baidu. All rights reserved.
//

#import "LoadBalancer.h"

@interface LoadBalancer()
@property (assign) int count; //用作限流期间的数据统计
@end


@implementation LoadBalancer

- (instancetype)initWithInterval:(NSTimeInterval)interVal {
    self = [self init];
    if (self) {
        _interVal = interVal;
        _runningStatus = ERunStatus_NotRunning;
    }
    
    return self;
}

- (void)triggerRunning:(RunningCallback)callback dispatchQueue:(dispatch_queue_t)queue {
    if (!callback) {
        return;
    }
    
    if (self.runningStatus == ERunStatus_Running ||
        self.runningStatus == ERunStatus_RepeatRunning) {
        self.runningStatus = ERunStatus_RepeatRunning;
    } else if (self.runningStatus == ERunStatus_NotRunning) {
        self.runningStatus = ERunStatus_Running;
        callback(self.runningStatus, 1);
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.interVal * NSEC_PER_SEC)), queue, ^{
            __strong typeof(weakSelf) self = weakSelf;
            if (self.runningStatus == ERunStatus_RepeatRunning) {
                int balancedCnt = self.count;
                if (balancedCnt > 2) {
                    NSLog(@"拦截的流量: count=%d", balancedCnt);
                }
                self.runningStatus = ERunStatus_NotRunning;
                callback(self.runningStatus, balancedCnt);
            } else {
                if (self.runningStatus != ERunStatus_NotRunning) {
                    self.runningStatus = ERunStatus_NotRunning;
                }
            }
        });
    }
}

- (void)setRunningStatus:(ERunStatus)runningStatus {
    if (runningStatus == ERunStatus_NotRunning) {
        self.count = 0;
    } else if (self.runningStatus == ERunStatus_Running) {
        self.count = 1;;
    } else if (self.runningStatus == ERunStatus_RepeatRunning) {
        self.count++;
    }
    
    _runningStatus = runningStatus;
}

@end
