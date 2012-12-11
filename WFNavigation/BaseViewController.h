//
//  BaseViewController.h
//  WFNavigation
//
//  Created by 滕 松 on 12-12-11.
//  Copyright (c) 2012年 shawnt22@gmail.com. All rights reserved.
//

#import "WFItemController.h"

@interface BaseViewController : WFItemController
@property (nonatomic, assign) UILabel *titleLabel;

@end

@interface BaseViewController (Util)
+ (WFGestureDirection)gestureDirection;
+ (WFNavigationAnimationType)animationType;
@end
