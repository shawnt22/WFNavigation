//
//  WFItemController.h
//  WFNavigation
//
//  Created by 滕 松 on 12-12-11.
//  Copyright (c) 2012年 shawnt22@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WFControllerProtocol.h"
#import "WFNavigationController.h"

#pragma mark - WFItem Protocol
@class WFItemController;
@protocol WFItemProtocol <NSObject>

@required
@property (nonatomic, assign) WFItemController *parentItem;
@property (nonatomic, assign) WFGestureDirection supportedDirection;
@property (nonatomic, assign) WFGestureDirection pushDirection;
@property (nonatomic, readonly) WFGestureDirection popDirection;
@property (nonatomic, assign) WFNavigationAnimationType animationType;

@optional
@property (nonatomic, assign) WFNavigationController *wfNavigationController;
- (UIImage *)screenshotImage;

@end

#pragma mark - WFItem Controller
@interface WFItemController : UIViewController<WFItemProtocol>

@end


#pragma mark - WFItem Util
@interface WFItemController (Util)
+ (UIImage *)screenshotImageInView:(UIView *)view;
@end
