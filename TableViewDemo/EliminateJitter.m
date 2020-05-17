//
//  EliminateJitter.m
//  TableViewDemo
//
//  Created by sunjinglin on 2020/5/17.
//  Copyright © 2020 sunjinglin. All rights reserved.
//

#import "EliminateJitter.h"

typedef NS_ENUM(NSUInteger, ERunStatus) {
    ERunStatus_NotRun = 0,
    ERunStatus_Running = 1,
    ERunStatus_ReRunning = 2,
};

@interface EliminateJitter ()
@property (assign, nonatomic) NSInteger triggerCnt;
@property (assign, nonatomic) NSTimeInterval interval;
@property (assign, nonatomic) ERunStatus status;

@end

@implementation EliminateJitter

- (instancetype)initWithTriggerInterval:(NSTimeInterval)interval {
    self = [super init];
    if (self) {
        _interval = interval;
        _triggerCnt = 0;
    }
    
    return self;
}

- (void)triggerWithCallback:(DataResultBlock)callback {
    if (self.status == ERunStatus_Running ||
               self.status == ERunStatus_ReRunning) {
        self.status = ERunStatus_ReRunning;
    } else {
        NSLog(@"新的触发调用：last=%ld, triggerCnt=%ld", (unsigned long)self.status, (long)self.triggerCnt);
        self.status = ERunStatus_Running;
        self.block = callback; //仅仅记录首次的回调（每次外面调用都是覆盖）。
        [self didEliminateJitter];
    }
}

- (void)didEliminateJitter {
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.interval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) self = weakSelf;
        if (self.status != ERunStatus_NotRun) {
            NSLog(@"间隔抖动次数：last=%lu, triggerCnt=%ld", (unsigned long)self.status, (long)self.triggerCnt);
            self.status = ERunStatus_NotRun; //消除一次抖动标识, 同时第二次运行判读是否扔在抖动
            [self didEliminateJitter];
            return;
        }
        
        
        if (self.block && self.triggerCnt > 0) {
            self.triggerCnt = 0;
            self.block();
        }
    });
}

- (void)setStatus:(ERunStatus)status {
    _status = status;
    if (_status == ERunStatus_Running || _status == ERunStatus_ReRunning) {
        self.triggerCnt ++;
    }
}

- (void)setTriggerCnt:(NSInteger)triggerCnt {
    if (0 == triggerCnt) {
        NSLog(@"最终复位时抖动次数：triggerCnt=%ld", (long)self.triggerCnt);
    }
    _triggerCnt = triggerCnt;
}

@end
