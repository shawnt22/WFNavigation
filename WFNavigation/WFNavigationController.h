//
//  WFNavigationController.h
//  WFNavigation
//
//  Created by 滕 松 on 12-12-11.
//  Copyright (c) 2012年 shawnt22@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WFControllerProtocol.h"

#pragma mark - WFBoard Controller
@class WFItemController;
@interface WFNavigationController : UIViewController <UIGestureRecognizerDelegate, WFAnimationDelegate>
@property (nonatomic, assign) id<WFGestureDelegate> gestureDelegate;

- (void)pushItem:(WFItemController *)item Direction:(WFGestureDirection)direction Type:(WFNavigationAnimationType)type Animated:(BOOL)animated;
- (void)popItem:(WFItemController *)item Animated:(BOOL)animated;

@end

@interface WFNavigationController (Util)
+ (void)parentViewController:(UIViewController *)parent addChildViewController:(UIViewController *)child;
+ (void)childViewControllerRemoveFromParentViewController:(UIViewController *)child;
@end


#pragma mark - WFAnimation
@interface WFAnimation : NSObject
- (id)initWithNavigationController:(WFNavigationController<WFAnimationDelegate> *)navigation;
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
