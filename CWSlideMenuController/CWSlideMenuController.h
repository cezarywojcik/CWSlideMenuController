//
//  CWSlideMenuController.h
//  CWSlideMenuControllerDemo
//
//  Created by Cezary Wojcik on 9/20/13.
//  Copyright (c) 2013 Cezary Wojcik. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CWSlideMenuController : UIViewController <UIDynamicAnimatorDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) UIDynamicAnimator *animator;

@property (strong, nonatomic) UICollisionBehavior *collisionBehavior;
@property (strong, nonatomic) UIGravityBehavior *gravityBehavior;
@property (strong, nonatomic) UIPushBehavior *pushBehavior;
@property (strong, nonatomic) UIAttachmentBehavior *attachmentBehavior;

@property (strong, nonatomic) UIViewController *leftViewController;
@property (strong, nonatomic) UIViewController *mainViewController;
@property (strong, nonatomic) UIViewController *rightViewController;

@property (strong, nonatomic) UIScreenEdgePanGestureRecognizer *leftScreenEdgePanGestureRecognizer;
@property (strong, nonatomic) UIScreenEdgePanGestureRecognizer *rightScreenEdgePanGestureRecognizer;

- (void)leftViewControllerButton;
- (void)rightViewControllerButton;

@end
