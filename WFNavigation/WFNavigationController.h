//
//  WFNavigationController.h
//  WFNavigation
//
//  Created by 滕 松 on 12-12-11.
//  Copyright (c) 2012年 shawnt22@gmail.com. All rights reserved.
//

/****
 
 未解决问题 :
 
 1. 设备旋转后的布局
 2. pile效果时的截屏时机
 3. visiableFrame的自定义，目前只支持满屏的controller更迭
 
 ****/

#import <Foundation/Foundation.h>
#import "WFControllerProtocol.h"

#pragma mark - WFBoard Controller
@class WFNavigationController;
@class WFItemController;
@protocol WFNavigationControllerDelegate <NSObject>
@optional
- (void)navigationController:(WFNavigationController *)navigation didFinishAnimation:(BOOL)isPush Item:(WFItemController *)item;
@end

@interface WFNavigationController : UIViewController <UIGestureRecognizerDelegate, WFAnimationDelegate>
@property (nonatomic, assign) id<WFGestureDelegate> gestureDelegate;

- (id)initWithRootItem:(WFItemController *)item;
- (void)pushItem:(WFItemController *)item Direction:(WFGestureDirection)direction Type:(WFNavigationAnimationType)type Animated:(BOOL)animated;
- (void)popItem:(WFItemController *)item Animated:(BOOL)animated;

- (void)addObserver:(id<WFNavigationControllerDelegate>)observer;
- (void)removeObserver:(id<WFNavigationControllerDelegate>)observer;

@end

@interface WFNavigationController (Util)
+ (void)parentViewController:(UIViewController *)parent addChildViewController:(UIViewController *)child;
+ (void)childViewControllerRemoveFromParentViewController:(UIViewController *)child;
@end


#pragma mark - WFAnimation
@interface WFAnimation : NSObject {
@protected
    BOOL _isAnimating;
}
@property (nonatomic, readonly) BOOL isAnimating;
@property (nonatomic, assign) id<WFAnimationDelegate> animationDelegate;
- (id)initWithNavigationController:(WFNavigationController *)navigation;
- (void)pushItem:(WFItemController *)item Animated:(BOOL)animated;
- (void)popItem:(WFItemController *)item Animated:(BOOL)animated;

- (void)updateCurrentItem;
- (void)regulateCurrentItemWithGesture:(UIGestureRecognizer *)gesture Aniamted:(BOOL)animated;
@end

@interface WFPileAnimation : WFAnimation

@end

@interface WFSmoothAnimation : WFAnimation

@end

#pragma mark - WFAnimation Layer
@interface WFAnimationLayer : UIImageView
- (void)updateWithProportion:(CGFloat)proportion;
@end
