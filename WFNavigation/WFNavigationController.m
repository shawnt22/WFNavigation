//
//  WFNavigationController.m
//  WFNavigation
//
//  Created by 滕 松 on 12-12-11.
//  Copyright (c) 2012年 shawnt22@gmail.com. All rights reserved.
//

#import "WFNavigationController.h"
#import "WFItemController.h"

#pragma mark - Interface
@interface WFNavigationController ()
@property (nonatomic, retain) NSMutableArray *itemStack;
@property (nonatomic, assign) WFItemController *rootItem;

@property (nonatomic, readonly) WFItemController *currentItem;
@property (nonatomic, retain) WFAnimation *wfAnimation;

@property (nonatomic, assign) CGPoint originalPoint;
@property (nonatomic, assign) CGPoint currentPoint;
@property (nonatomic, assign) BOOL isHorizontalUpdate;

- (void)addItemToStack:(WFItemController *)item Direction:(WFGestureDirection)direction Type:(WFNavigationAnimationType)type;
- (void)removeItemFromStack:(WFItemController *)item;

- (BOOL)isRootItem:(WFItemController *)item;
- (WFAnimation *)animationWithType:(WFNavigationAnimationType)type;
@end

@interface WFNavigationController (Gesture)
- (void)addWFGesture;
- (void)handleGesture:(UIGestureRecognizer *)gesture;
- (WFGestureDirection)gestureDirectionWithGesture:(UIPanGestureRecognizer *)panGesture;
- (void)updateCurrentItem;
- (void)regulateCurrentItem:(UIGestureRecognizer *)gesture;
- (void)notifyGestureManager:(id)manager beganGesture:(UIGestureRecognizer *)gesture;
- (void)notifyGestureManager:(id)manager changedGesture:(UIGestureRecognizer *)gesture;
- (void)notifyGestureManager:(id)manager endedGesture:(UIGestureRecognizer *)gesture;
- (void)notifyGestureManager:(id)manager canceledGesture:(UIGestureRecognizer *)gesture;
- (BOOL)notifyGestureManager:(id)manager shouldBeginGesture:(UIGestureRecognizer *)gesture;
@end

#pragma mark - Implementation
@implementation WFNavigationController
@synthesize itemStack, rootItem;
@synthesize currentItem;
@synthesize gestureDelegate, originalPoint, currentPoint, isHorizontalUpdate;
@synthesize wfAnimation;

#pragma mark init
- (id)initWithRootItem:(WFItemController *)item {
    self = [self init];
    if (self) {
        self.rootItem = item;
        [self pushItem:item Direction:WFGestureLeft Type:WFNavigationAnimationSmooth Animated:NO];
    }
    return self;
}
- (id)init {
    self = [super init];
    if (self) {
        self.gestureDelegate = nil;
        self.itemStack = [NSMutableArray array];
    }
    return self;
}
- (void)dealloc {
    self.wfAnimation = nil;
    self.itemStack = nil;
    [super dealloc];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self addWFGesture];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (BOOL)shouldAutorotate {
    return NO;
}
- (NSInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark item stack
- (BOOL)isRootItem:(WFItemController *)item {
    return item == self.rootItem ? YES : NO;
}
- (void)addItemToStack:(WFItemController *)item Direction:(WFGestureDirection)direction Type:(WFNavigationAnimationType)type {
    if (!item) {
        return;
    }
    item.pushDirection = direction;
    item.animationType = type;
    item.parentItem = self.currentItem;
    item.wfNavigationController = self;
    [self.itemStack addObject:item];
    [WFNavigationController parentViewController:self addChildViewController:item];
}
- (void)removeItemFromStack:(WFItemController *)item {
    [WFNavigationController childViewControllerRemoveFromParentViewController:item];
    [self.itemStack removeObject:item];
}
- (WFAnimation *)animationWithType:(WFNavigationAnimationType)type {
    WFAnimation *_animation = nil;
    switch (type) {
        case WFNavigationAnimationSmooth:
            _animation = [[[WFSmoothAnimation alloc] initWithNavigationController:self] autorelease];
            break;
        default:
            _animation = [[[WFPileAnimation alloc] initWithNavigationController:self] autorelease];
            break;
    }
    return _animation;
}
- (WFItemController *)currentItem {
    return [self.itemStack lastObject];
}
- (void)pushItem:(WFItemController *)item Direction:(WFGestureDirection)direction Type:(WFNavigationAnimationType)type Animated:(BOOL)animated {
    if (!item) {
        return;
    }
    [self addItemToStack:item Direction:direction Type:type];
    
    self.wfAnimation = [self animationWithType:type];
    [self.wfAnimation pushItem:item Animated:animated];
}
- (void)popItem:(WFItemController *)item Animated:(BOOL)animated {
    if (!item) {
        return;
    }
    if ([self isRootItem:item]) {
        return;
    }
    self.wfAnimation = [self animationWithType:item.animationType];
    [self.wfAnimation popItem:item Animated:animated];
}
- (void)animation:(WFAnimation *)animation finishAnimation:(BOOL)isPush {
    self.wfAnimation = nil;
}

@end

#pragma mark - Gesture
@implementation WFNavigationController (Gesture)

- (void)addWFGesture {
    UIPanGestureRecognizer *_pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    _pan.delegate = self;
    [self.view addGestureRecognizer:_pan];
    [_pan release];
}
- (WFGestureDirection)gestureDirectionWithGesture:(UIPanGestureRecognizer *)panGesture {
    WFGestureDirection _direction = WFGestureLeft;
    CGPoint _velocity = [panGesture velocityInView:self.view];
    if (fabsf(_velocity.x) > fabsf(_velocity.y)) {
        _direction = _velocity.x > 0 ? WFGestureRight : WFGestureLeft;
    } else {
        _direction = _velocity.y > 0 ? WFGestureDown : WFGestureUp;
    }
    return _direction;
}
- (void)handleGesture:(UIGestureRecognizer *)gesture {
    if (![gesture isKindOfClass:[UIPanGestureRecognizer class]]) {
        return;
    }
    UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer *)gesture;
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan: {
            self.originalPoint = self.currentPoint = [panGesture translationInView:self.view];
            [self notifyGestureManager:self beganGesture:panGesture];
        }
            break;
        case UIGestureRecognizerStateChanged: {
            self.originalPoint = self.currentPoint;
            self.currentPoint = [panGesture translationInView:self.view];
            [self updateCurrentItem];
            [self notifyGestureManager:self changedGesture:panGesture];
        }
            break;
        case UIGestureRecognizerStateEnded: {
            [self regulateCurrentItem:gesture];
            [self notifyGestureManager:self endedGesture:panGesture];
        }
            break;
        default: {
            [self regulateCurrentItem:gesture];
            [self notifyGestureManager:self canceledGesture:panGesture];
        }
            break;
    }
}
- (void)updateCurrentItem {
    if (!self.wfAnimation) {
        self.wfAnimation = [self animationWithType:self.currentItem.animationType];
    }
    [self.wfAnimation updateCurrentItem];
}
- (void)regulateCurrentItem:(UIGestureRecognizer *)gesture {
    if (!self.wfAnimation) {
        self.wfAnimation = [self animationWithType:self.currentItem.animationType];
    }
    [self.wfAnimation regulateCurrentItemWithGesture:gesture Aniamted:YES];
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (self.wfAnimation.isAnimating) {
        return NO;
    }
    if ([self isRootItem:self.currentItem]) {
        return NO;
    }
    return [self notifyGestureManager:self shouldBeginGesture:gestureRecognizer];
}
- (void)notifyGestureManager:(id)manager beganGesture:(UIGestureRecognizer *)gesture {
    if (self.gestureDelegate && [self.gestureDelegate respondsToSelector:@selector(gestureManager:beganGesture:)]) {
        [self.gestureDelegate gestureManager:manager beganGesture:gesture];
    }
}
- (void)notifyGestureManager:(id)manager changedGesture:(UIGestureRecognizer *)gesture {
    if (self.gestureDelegate && [self.gestureDelegate respondsToSelector:@selector(gestureManager:changedGesture:)]) {
        [self.gestureDelegate gestureManager:manager changedGesture:gesture];
    }
}
- (void)notifyGestureManager:(id)manager endedGesture:(UIGestureRecognizer *)gesture {
    if (self.gestureDelegate && [self.gestureDelegate respondsToSelector:@selector(gestureManager:endedGesture:)]) {
        [self.gestureDelegate gestureManager:manager endedGesture:gesture];
    }
}
- (void)notifyGestureManager:(id)manager canceledGesture:(UIGestureRecognizer *)gesture {
    if (self.gestureDelegate && [self.gestureDelegate respondsToSelector:@selector(gestureManager:canceledGesture:)]) {
        [self.gestureDelegate gestureManager:manager canceledGesture:gesture];
    }
}
- (BOOL)notifyGestureManager:(id)manager shouldBeginGesture:(UIGestureRecognizer *)gesture {
    if (self.gestureDelegate && [self.gestureDelegate respondsToSelector:@selector(gestureManager:shouldBeginGesture:)]) {
        return [self.gestureDelegate gestureManager:manager shouldBeginGesture:gesture];
    }
    return YES;
}

@end


@implementation WFNavigationController (Util)
+ (void)parentViewController:(UIViewController *)parent addChildViewController:(UIViewController *)child {
    //  todo : os版本适配
    [parent addChildViewController:child];
}
+ (void)childViewControllerRemoveFromParentViewController:(UIViewController *)child {
    //  todo : os版本适配
    [child removeFromParentViewController];
}
@end


#pragma mark - WFAnimation
#import <QuartzCore/QuartzCore.h>
@interface WFAnimation ()
@property (nonatomic, assign) WFNavigationController *wfNavigationController;
@property (nonatomic, readonly) WFItemController *currentItem;
@property (nonatomic, readonly) WFGestureDirection gestureDirection;
@property (nonatomic, readonly) UIView *view;
@property (nonatomic, readonly) CGRect visiableFrame;
@property (nonatomic, readonly) CGRect unvisiableFrame;
@property (nonatomic, assign) NSTimeInterval animationDuration;
- (void)pushAnimationWithItem:(WFItemController *)item Animated:(BOOL)animated;
- (void)popAnimationWithItem:(WFItemController *)item Animated:(BOOL)animated;
- (void)finishPushAnimation;
- (void)finishPopAnimation:(WFItemController *)item;
- (void)hideItemController:(WFItemController *)item;
- (void)showItemController:(WFItemController *)item;

- (void)notifyAnimation:(WFAnimation *)animation finishAnimation:(BOOL)isPush;

- (CGFloat)deltaWhileUpdate;
@end
@implementation WFAnimation
@synthesize isAnimating = _isAnimating;
@synthesize visiableFrame, unvisiableFrame;
@synthesize currentItem;
@synthesize view;
@synthesize animationDuration;

- (id)initWithNavigationController:(WFNavigationController *)navigation {
    self = [super init];
    if (self) {
        self.wfNavigationController = navigation;
        self.animationDuration = WFAnimationDuration;
    }
    return self;
}
- (void)notifyAnimation:(WFAnimation *)animation finishAnimation:(BOOL)isPush {
    if (self.wfNavigationController && [self.wfNavigationController respondsToSelector:@selector(animation:finishAnimation:)]) {
        [self.wfNavigationController animation:animation finishAnimation:isPush];
    }
}
- (WFItemController *)currentItem {
    return self.wfNavigationController.currentItem;
}
- (UIView *)view {
    return self.wfNavigationController.view;
}
- (WFGestureDirection)gestureDirection {
    return self.currentItem.pushDirection;
}
- (CGRect)visiableFrame {
    return self.view.bounds;
}
- (CGRect)unvisiableFrame {
    CGRect _f = self.view.bounds;
    switch (self.gestureDirection) {
        case WFGestureLeft:
            _f.origin.x += self.view.bounds.size.width;
            break;
        case WFGestureRight:
            _f.origin.x -= self.view.bounds.size.width;
            break;
        case WFGestureUp:
            _f.origin.y += self.view.bounds.size.height;
            break;
        case WFGestureDown:
            _f.origin.y -= self.view.bounds.size.height;
            break;
        default:
            break;
    }
    return _f;
}
- (void)hideItemController:(WFItemController *)item {
    [item.view removeFromSuperview];
}
- (void)showItemController:(WFItemController *)item {
    [self.view addSubview:item.view];
}
- (void)pushItem:(WFItemController *)item Animated:(BOOL)animated {}
- (void)pushAnimationWithItem:(WFItemController *)item Animated:(BOOL)animated {
    _isAnimating = YES;
}
- (void)finishPushAnimation {
    _isAnimating = NO;
}
- (void)popItem:(WFItemController *)item Animated:(BOOL)animated {};
- (void)popAnimationWithItem:(WFItemController *)item Animated:(BOOL)animated {
    _isAnimating = YES;
}
- (void)finishPopAnimation:(WFItemController *)item {
    _isAnimating = NO;
}

- (CGFloat)deltaWhileUpdate {
    CGFloat _delta = 0.0;
    if (WFGestureIsHorizontal(self.gestureDirection)) {
        _delta = self.wfNavigationController.currentPoint.x - self.wfNavigationController.originalPoint.x;
    } else {
        _delta = self.wfNavigationController.currentPoint.y - self.wfNavigationController.originalPoint.y;
    }
    return _delta;
}
- (void)updateCurrentItem {
    CGRect _f = self.currentItem.view.frame;
    switch (self.gestureDirection) {
        case WFGestureRight: {
            _f.origin.x += [self deltaWhileUpdate];
            if (_f.origin.x < self.visiableFrame.origin.x - self.visiableFrame.size.width) {
                _f.origin.x = self.visiableFrame.origin.x - self.visiableFrame.size.width;
            } else if (_f.origin.x > self.visiableFrame.origin.x) {
                _f.origin.x = self.visiableFrame.origin.x;
            }
        }
            break;
        case WFGestureLeft: {
            _f.origin.x += [self deltaWhileUpdate];
            if (_f.origin.x > self.visiableFrame.origin.x + self.visiableFrame.size.width) {
                _f.origin.x = self.visiableFrame.origin.x + self.visiableFrame.size.width;
            } else if (_f.origin.x < self.visiableFrame.origin.x ) {
                _f.origin.x = self.visiableFrame.origin.x;
            }
        }
            break;
        case WFGestureUp: {
            _f.origin.y += [self deltaWhileUpdate];
            if (_f.origin.y < self.visiableFrame.origin.y) {
                _f.origin.y = self.visiableFrame.origin.y;
            } else if (_f.origin.y > self.visiableFrame.origin.y + self.visiableFrame.size.height) {
                _f.origin.y = self.visiableFrame.origin.y + self.visiableFrame.size.height;
            }
        }
            break;
        case WFGestureDown: {
            _f.origin.y += [self deltaWhileUpdate];
            if (_f.origin.y > self.visiableFrame.origin.y) {
                _f.origin.y = self.visiableFrame.origin.y;
            } else if (_f.origin.y < self.visiableFrame.origin.y - self.visiableFrame.size.height) {
                _f.origin.y = self.visiableFrame.origin.y - self.visiableFrame.size.height;
            }
        }
            break;
        default:
            break;
    }
    self.currentItem.view.frame = _f;
}
- (void)regulateCurrentItemWithGesture:(UIGestureRecognizer *)gesture Aniamted:(BOOL)animated {
    if (![gesture isKindOfClass:[UIPanGestureRecognizer class]]) {
        return;
    }
    UIPanGestureRecognizer *_pan = (UIPanGestureRecognizer *)gesture;
    //  pop or push animation
    BOOL _pop = NO;
    //  优先响应 swap 手势
    CGRect _f = self.currentItem.view.frame;
    CGFloat _popLimit = 0.3;
    CGFloat _swapLimit = 700.0;
    switch (self.gestureDirection) {
        case WFGestureRight: {
            CGFloat _v = [_pan velocityInView:self.view].x;
            if (_v < -_swapLimit) {
                _pop = YES;
            } else if (_f.origin.x < self.visiableFrame.origin.x - self.visiableFrame.size.width * _popLimit) {
                _pop = YES;
            }
        }
            break;
        case WFGestureLeft: {
            CGFloat _v = [_pan velocityInView:self.view].x;
            if (_v > _swapLimit) {
                _pop = YES;
            } else if (_f.origin.x > self.visiableFrame.origin.x + self.visiableFrame.size.width * _popLimit) {
                _pop = YES;
            }
        }
            break;
        case WFGestureUp: {
            CGFloat _v = [_pan velocityInView:self.view].y;
            if (_v > _swapLimit) {
                _pop = YES;
            } else if (_f.origin.y > self.visiableFrame.origin.y + self.visiableFrame.size.height * _popLimit) {
                _pop = YES;
            }
        }
            break;
        case WFGestureDown: {
            CGFloat _v = [_pan velocityInView:self.view].y;
            if (_v < -_swapLimit) {
                _pop = YES;
            } else if (_f.origin.y < self.visiableFrame.origin.y - self.visiableFrame.size.height * _popLimit) {
                _pop = YES;
            }
        }
            break;
        default:
            break;
    }
    if (_pop) {
        [self popAnimationWithItem:self.currentItem Animated:animated];
    } else {
        [self pushAnimationWithItem:self.currentItem Animated:animated];
    }
}

@end

#pragma mark Pile
@interface WFPileAnimation ()
@property (nonatomic, retain) WFAnimationLayer *screenshotLayer;
@property (nonatomic, readonly) WFItemController *downItemController;
- (void)addScreenshotLayer;
- (void)removeScreenshotLayer;
- (CGFloat)downScreenshotLayerProportion;
@end
@implementation WFPileAnimation
@synthesize screenshotLayer;

- (id)initWithNavigationController:(WFNavigationController *)navigation {
    self = [super initWithNavigationController:navigation];
    if (self) {
        self.screenshotLayer = nil;
    }
    return self;
}
- (void)dealloc {
    self.screenshotLayer = nil;
    [super dealloc];
}
- (WFItemController *)downItemController {
    return self.currentItem.parentItem;
}
- (void)addScreenshotLayer {
    if (self.downItemController) {
        if (!self.screenshotLayer) {
            self.screenshotLayer = [[[WFAnimationLayer alloc] initWithFrame:self.downItemController.view.bounds] autorelease];
            self.screenshotLayer.userInteractionEnabled = NO;
            self.screenshotLayer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            self.screenshotLayer.image = self.downItemController.screenshotImage;
        }
        [self.view insertSubview:self.screenshotLayer belowSubview:self.currentItem.view];
    }
}
- (void)removeScreenshotLayer {
    [self.screenshotLayer removeFromSuperview];
    self.screenshotLayer = nil;
}
- (CGFloat)downScreenshotLayerProportion {
    CGFloat _proportion = 0.0;
    CGRect _f = CGRectIntersection(self.currentItem.view.frame, self.visiableFrame);
    _proportion = (_f.size.width * _f.size.height) / (self.visiableFrame.size.width * self.visiableFrame.size.height);
    return _proportion;
}
- (void)pushItem:(WFItemController *)item Animated:(BOOL)animated {
    [super pushItem:item Animated:animated];
    
    [self hideItemController:self.downItemController];
    [self showItemController:self.currentItem];
    [self addScreenshotLayer];
    
    self.currentItem.view.frame = self.unvisiableFrame;
    [self pushAnimationWithItem:item Animated:animated];
}
- (void)pushAnimationWithItem:(WFItemController *)item Animated:(BOOL)animated {
    [super pushAnimationWithItem:item Animated:animated];
    if (animated) {
        [UIView animateWithDuration:self.animationDuration
                         animations:^{
                             self.currentItem.view.frame = self.visiableFrame;
                             [self.screenshotLayer updateWithProportion:[self downScreenshotLayerProportion]];
                         }
                         completion:^(BOOL finished){
                             [self finishPushAnimation];
                         }];
    } else {
        self.currentItem.view.frame = self.visiableFrame;
        [self.screenshotLayer updateWithProportion:[self downScreenshotLayerProportion]];
        [self finishPushAnimation];
    }
}
- (void)finishPushAnimation {
    [super finishPushAnimation];
    [self removeScreenshotLayer];
    [self notifyAnimation:self finishAnimation:YES];
}
- (void)popItem:(WFItemController *)item Animated:(BOOL)animated {
    [super popItem:item Animated:animated];
    
    [self addScreenshotLayer];
    
    self.currentItem.view.frame = self.visiableFrame;
    [self.screenshotLayer updateWithProportion:[self downScreenshotLayerProportion]];
    
    [self popAnimationWithItem:item Animated:animated];
}
- (void)popAnimationWithItem:(WFItemController *)item Animated:(BOOL)animated {
    [super popAnimationWithItem:item Animated:animated];
    if (animated) {
        [UIView animateWithDuration:self.animationDuration
                         animations:^{
                             self.currentItem.view.frame = self.unvisiableFrame;
                             [self.screenshotLayer updateWithProportion:[self downScreenshotLayerProportion]];
                         }
                         completion:^(BOOL finished){
                             [self finishPopAnimation:item];
                         }];
    } else {
        self.currentItem.view.frame = self.unvisiableFrame;
        [self.screenshotLayer updateWithProportion:[self downScreenshotLayerProportion]];
        [self finishPopAnimation:item];
    }
}
- (void)finishPopAnimation:(WFItemController *)item {
    [super finishPopAnimation:item];
    [self hideItemController:self.currentItem];
    [self.wfNavigationController removeItemFromStack:item];
    [self showItemController:self.currentItem];
    
    [self removeScreenshotLayer];
    [self notifyAnimation:self finishAnimation:NO];
}

- (void)updateCurrentItem {
    [super updateCurrentItem];
    [self addScreenshotLayer];
    [self.screenshotLayer updateWithProportion:[self downScreenshotLayerProportion]];
}

@end


#pragma mark Smooth
@interface WFSmoothAnimation ()
@property (nonatomic, readonly) CGRect unvisiableFrameOfParent;
@end
@implementation WFSmoothAnimation
@synthesize unvisiableFrameOfParent;

- (CGRect)unvisiableFrameOfParent {
    CGRect _f = self.view.bounds;
    switch (self.gestureDirection) {
        case WFGestureLeft:
            _f.origin.x -= self.view.bounds.size.width;
            break;
        case WFGestureRight:
            _f.origin.x += self.view.bounds.size.width;
            break;
        case WFGestureUp:
            _f.origin.y -= self.view.bounds.size.height;
            break;
        case WFGestureDown:
            _f.origin.y += self.view.bounds.size.height;
            break;
        default:
            break;
    }
    return _f;
}
- (void)pushItem:(WFItemController *)item Animated:(BOOL)animated {
    [super pushItem:item Animated:animated];
    
    [self showItemController:self.currentItem];
    self.currentItem.view.frame = self.unvisiableFrame;
    self.currentItem.parentItem.view.frame = self.visiableFrame;
    
    [self pushAnimationWithItem:item Animated:animated];
}
- (void)pushAnimationWithItem:(WFItemController *)item Animated:(BOOL)animated {
    [super pushAnimationWithItem:item Animated:animated];
    if (animated) {
        [UIView animateWithDuration:self.animationDuration
                         animations:^{
                             self.currentItem.view.frame = self.visiableFrame;
                             self.currentItem.parentItem.view.frame = self.unvisiableFrameOfParent;
                         }
                         completion:^(BOOL finished){
                             [self finishPushAnimation];
                         }];
    } else {
        self.currentItem.view.frame = self.visiableFrame;
        self.currentItem.parentItem.view.frame = self.unvisiableFrameOfParent;
        [self finishPushAnimation];
    }
}
- (void)finishPushAnimation {
    [super finishPushAnimation];
    [self hideItemController:self.currentItem.parentItem];
    [self notifyAnimation:self finishAnimation:YES];
}
- (void)popItem:(WFItemController *)item Animated:(BOOL)animated {
    [super popItem:item Animated:animated];
    
    [self showItemController:self.currentItem.parentItem];
    self.currentItem.view.frame = self.visiableFrame;
    self.currentItem.parentItem.view.frame = self.unvisiableFrameOfParent;
    
    [self popAnimationWithItem:item Animated:animated];
}
- (void)popAnimationWithItem:(WFItemController *)item Animated:(BOOL)animated {
    [super popAnimationWithItem:item Animated:animated];
    if (animated) {
        [UIView animateWithDuration:self.animationDuration
                         animations:^{
                             self.currentItem.view.frame = self.unvisiableFrame;
                             self.currentItem.parentItem.view.frame = self.visiableFrame;
                         }
                         completion:^(BOOL finished){
                             [self finishPopAnimation:item];
                         }];
    } else {
        self.currentItem.view.frame = self.unvisiableFrame;
        self.currentItem.parentItem.view.frame = self.visiableFrame;
        [self finishPopAnimation:item];
    }
}
- (void)finishPopAnimation:(WFItemController *)item {
    [super finishPopAnimation:item];
    [self hideItemController:self.currentItem];
    [self.wfNavigationController removeItemFromStack:item];
    
    [self notifyAnimation:self finishAnimation:NO];
}
- (void)updateCurrentItem {
    [super updateCurrentItem];
    [self showItemController:self.currentItem.parentItem];
    CGRect _f = self.unvisiableFrameOfParent;
    switch (self.gestureDirection) {
        case WFGestureDown:
            _f.origin.y = self.currentItem.view.frame.origin.y + self.currentItem.view.frame.size.height;
            break;
        case WFGestureUp:
            _f.origin.y = self.currentItem.view.frame.origin.y - self.currentItem.parentItem.view.frame.size.height;
            break;
        case WFGestureLeft:
            _f.origin.x = self.currentItem.view.frame.origin.x - self.currentItem.parentItem.view.frame.size.width;
            break;
        case WFGestureRight:
            _f.origin.x = self.currentItem.view.frame.origin.x + self.currentItem.view.frame.size.width;
            break;
        default:
            break;
    }
    self.currentItem.parentItem.view.frame = _f;
}

@end


#pragma mark - WFAnimation Layer
@interface WFAnimationLayer ()
@property (nonatomic, assign) CGRect originalFrame;
@property (nonatomic, assign) UIView *coverView;
@end
@implementation WFAnimationLayer
@synthesize originalFrame;
@synthesize coverView;
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.originalFrame = frame;
        
        UIView *_c = [[UIView alloc] initWithFrame:self.bounds];
        _c.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        _c.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_c];
        self.coverView = _c;
        [_c release];
    }
    return self;
}
- (void)updateWithProportion:(CGFloat)proportion {
    CGFloat _inset = 10.0;
    _inset = _inset * proportion;
    CGRect _f = self.originalFrame;
    _f = CGRectInset(_f, _inset, _inset);
    self.frame = _f;
    
    self.coverView.alpha = proportion;
}
@end


