//
//  WFItemController.m
//  WFNavigation
//
//  Created by 滕 松 on 12-12-11.
//  Copyright (c) 2012年 shawnt22@gmail.com. All rights reserved.
//

#import "WFItemController.h"

#pragma mark - WFItem Controller
@interface WFItemController ()

@end

@implementation WFItemController
@synthesize parentItem, pushDirection, popDirection;
@synthesize supportedDirection;
@synthesize wfNavigationController;
@synthesize animationType;

#pragma mark init
- (id)init {
    self = [super init];
    if (self) {
        self.wantsFullScreenLayout = YES;
        self.wfNavigationController = nil;
        self.parentItem = nil;
        self.supportedDirection = WFGestureLeft | WFGestureRight | WFGestureUp | WFGestureDown;
    }
    return self;
}
- (void)dealloc {
    [super dealloc];
}
- (UIImage *)screenshotImage {
    return [WFItemController screenshotImageInView:self.view];
}
- (WFItemController *)wfItemController {
    return self;
}
- (WFGestureDirection)popDirection {
    return self.pushDirection;
}

#pragma mark controller delegate
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end

#pragma mark - WFItem Util
#import <QuartzCore/QuartzCore.h>
@implementation WFItemController (Util)
+ (UIImage *)screenshotImageInView:(UIView *)view {
    CGSize screenShotSize = view.bounds.size;
    UIImage *img;
    UIGraphicsBeginImageContext(screenShotSize);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:ctx];
    img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}
@end
