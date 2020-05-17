//
//  EliminateJitterControll.h
//  TableViewDemo
//
//  Fucntion :去抖动助手，通过定时轮训标识状态，判断业务方的状态是否稳定。每次定时轮徐的时候，到时间后内部复位Not Running.
//  若相邻两次运行状态都是Not Running，则认为没有抖动。
//  Created by sunjinglin on 2020/5/17.
//  Copyright © 2020 sunjinglin. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^DataResultBlock)(void);

@interface EliminateJitter : NSObject
@property (copy) DataResultBlock block;

- (instancetype)initWithTriggerInterval:(NSTimeInterval)interval;
- (void)triggerWithCallback:(DataResultBlock)callback;
@end

NS_ASSUME_NONNULL_END
