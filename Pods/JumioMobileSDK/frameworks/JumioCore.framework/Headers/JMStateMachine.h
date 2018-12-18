//
//  JMStateMachine.h
//
//  Copyright © 2018 Jumio Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JMState;
@class JMBaseState;
@class JMStateTransition;
@class JMStateTransitionEvent;

__attribute__((visibility("default"))) @interface JMStateMachine : NSObject

@property (nonatomic, weak, readonly) JMBaseState*        initialState;
@property (nonatomic, weak)           JMBaseState*        currentState;
@property (nonatomic, assign, readonly) BOOL                isActive;
@property (nonatomic, strong, readonly) NSRecursiveLock*    fireEventLock;

+ (instancetype)stateMachine;

- (BOOL)canFireEventWithName:(NSString*)eventName;
- (BOOL)fireEventWithName:(NSString*)eventName;

- (void)addState:(JMBaseState*)state;
- (void)removeState:(JMBaseState*)state;

- (void)activate;
- (void)reset;
- (void)cleanUp;
- (void)resetToStateWithName:(NSString*)stateName;

- (JMStateTransition*)transitionWithEventName:(NSString*)name;

- (BOOL) isCurrentStateName:(NSString *)name;
- (JMState *)stateWithName:(NSString *)name;
- (NSSet*)allStates;

@end
