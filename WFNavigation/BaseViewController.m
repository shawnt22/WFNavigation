//
//  BaseViewController.m
//  WFNavigation
//
//  Created by 滕 松 on 12-12-11.
//  Copyright (c) 2012年 shawnt22@gmail.com. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor greenColor];
    
    UILabel *ttl = [[UILabel alloc] initWithFrame:CGRectMake(30, 50, self.view.bounds.size.width-60, 44)];
    ttl.backgroundColor = [UIColor grayColor];
    ttl.textAlignment = NSTextAlignmentCenter;
    ttl.font = [UIFont boldSystemFontOfSize:18];
    ttl.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    ttl.text = [NSString stringWithFormat:@"%d", [[self.wfNavigationController performSelector:@selector(itemStack)] count]];
    [self.view addSubview:ttl];
    [ttl release];
    self.titleLabel = ttl;
    
    UIButton *_push = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _push.frame = CGRectMake(50, 200, 100, 44);
    _push.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [_push setTitle:@"push" forState:UIControlStateNormal];
    [_push addTarget:self action:@selector(pushItemAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_push];
    
    UIButton *_pop = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _pop.frame = CGRectMake(self.view.bounds.size.width - 100 - 50, _push.frame.origin.y, 100, 44);
    _pop.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [_pop setTitle:@"pop" forState:UIControlStateNormal];
    [_pop addTarget:self action:@selector(popItemAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_pop];
}
- (void)pushItemAction:(id)sender {
    BaseViewController *_item = [[BaseViewController alloc] init];
    [self.wfNavigationController pushItem:_item Direction:[BaseViewController gestureDirection] Type:[BaseViewController animationType] Animated:YES];
    [_item release];
}
- (void)popItemAction:(id)sender {
    [self.wfNavigationController popItem:self Animated:YES];
}

@end

@implementation BaseViewController (Util)
+ (WFGestureDirection)gestureDirection {
    return WFGestureLeft;
}
+ (WFNavigationAnimationType)animationType {
    return WFNavigationAnimationPile;
}
@end