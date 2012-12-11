//
//  WFControllerProtocol.h
//  WFNavigation
//
//  Created by 滕 松 on 12-12-11.
//  Copyright (c) 2012年 shawnt22@gmail.com. All rights reserved.
//

#pragma mark - WFAniamtion
typedef enum {
    WFNavigationAnimationPile,          //  堆叠效果
    WFNavigationAnimationSmooth,        //  平整效果
}WFNavigationAnimationType;

#define WFAnimationDuration 0.3

@class WFAnimation;
@protocol WFAnimationDelegate <NSObject>
@optional
- (void)animation:(WFAnimation *)animation finishAnimation:(BOOL)isPush;
@end

#pragma mark - WFGesture
typedef enum {
    WFGestureLeft   = 1 << 0,           //  手指 自右至左 ← 滑动
    WFGestureRight  = 1 << 1,           //  手指 自左至右 → 滑动
    WFGestureUp     = 1 << 2,           //  手指 自下至上 ↑ 滑动
    WFGestureDown   = 1 << 3,           //  手指 自上至下 ↓ 滑动
}WFGestureDirection;

NS_INLINE WFGestureDirection WFGestureReverseDirection(WFGestureDirection gesture){
    WFGestureDirection reverse;
    switch (gesture) {
        case WFGestureLeft:
            reverse = WFGestureRight;
            break;
        case WFGestureRight:
            reverse = WFGestureLeft;
            break;
        case WFGestureDown:
            reverse = WFGestureUp;
            break;
        case WFGestureUp:
            reverse = WFGestureDown;
            break;
        default:
            break;
    }
    return reverse;
};

#define WFGestureIsHorizontal(gesture) (gesture == WFGestureLeft || gesture == WFGestureRight)
#define WFGestureIsVertical(gesture) (gesture == WFGestureUp || gesture == WFGestureDown)
#define WFGestureIsReversed(gesture, another) (gesture == WFGestureReverseDirection(another))

@protocol WFGestureDelegate <NSObject>
@optional
- (void)gestureManager:(id)manager beganGesture:(UIGestureRecognizer *)gesture;
- (void)gestureManager:(id)manager changedGesture:(UIGestureRecognizer *)gesture;
- (void)gestureManager:(id)manager endedGesture:(UIGestureRecognizer *)gesture;
- (void)gestureManager:(id)manager canceledGesture:(UIGestureRecognizer *)gesture;
- (BOOL)gestureManager:(id)manager shouldBeginGesture:(UIGestureRecognizer *)gesture;
@end


