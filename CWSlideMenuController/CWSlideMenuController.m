//
//  CWSlideMenuController.m
//  CWSlideMenuControllerDemo
//
//  Created by Cezary Wojcik on 9/20/13.
//  Copyright (c) 2013 Cezary Wojcik. All rights reserved.
//

#import "CWSlideMenuController.h"
#import <QuartzCore/QuartzCore.h>

#define ELASTICITY 0.4f
#define DENSITY 5.0f
#define GRAVITY_MAGNITUDE 1.0f
#define SHOW 22.0f
#define PUSH_STRENGTH 400.0f

@interface CWSlideMenuController ()

@end

@implementation CWSlideMenuController {
    BOOL isSetup;
    BOOL isAnimating;
    BOOL isMainCentered;
}

@synthesize animator;
@synthesize collisionBehavior, gravityBehavior, pushBehavior, attachmentBehavior;
@synthesize leftViewController, mainViewController, rightViewController;
@synthesize leftScreenEdgePanGestureRecognizer, rightScreenEdgePanGestureRecognizer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - setup

- (void)setup {
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    self.animator.delegate = self;

    self.leftScreenEdgePanGestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(screenEdgePan:)];
    self.leftScreenEdgePanGestureRecognizer.edges = UIRectEdgeLeft;
    [self.view addGestureRecognizer:self.leftScreenEdgePanGestureRecognizer];

    self.rightScreenEdgePanGestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(screenEdgePan:)];
    self.rightScreenEdgePanGestureRecognizer.edges = UIRectEdgeRight;
    [self.view addGestureRecognizer:self.rightScreenEdgePanGestureRecognizer];

    isSetup = YES;
}

# pragma mark - dimensions

- (CGFloat)getViewWidth {
    return [UIScreen mainScreen].bounds.size.width - SHOW;
}

- (CGFloat)getViewHeight {
    return [UIScreen mainScreen].bounds.size.height;
}

# pragma mark - button actions

- (void)leftViewControllerButton {
    if (isMainCentered) {
        [self showLeftViewController];
        self.pushBehavior.pushDirection = CGVectorMake(PUSH_STRENGTH, 0.0f);
        self.pushBehavior.active = YES;
    } else {
        [self showMainViewController];
        self.pushBehavior.pushDirection = CGVectorMake(-1*PUSH_STRENGTH, 0.0f);
        self.pushBehavior.active = YES;
    }
}

- (void)rightViewControllerButton {
    if (isMainCentered) {
        [self showRightViewController];
        self.pushBehavior.pushDirection = CGVectorMake(-1*PUSH_STRENGTH, 0.0f);
        self.pushBehavior.active = YES;
    } else {
        [self showMainViewController];
        self.pushBehavior.pushDirection = CGVectorMake(PUSH_STRENGTH, 0.0f);
        self.pushBehavior.active = YES;
    }
}

# pragma mark - non-gesture movement

- (void)showLeftViewController {
    if (self.leftViewController != nil) {
        isMainCentered = NO;
        if (self.rightViewController != nil) {
            [self.view sendSubviewToBack:self.rightViewController.view];
        }
        [self.collisionBehavior setTranslatesReferenceBoundsIntoBoundaryWithInsets:UIEdgeInsetsMake(0, -1*[self getViewWidth], 0, -1*[self getViewWidth])];
        self.gravityBehavior.gravityDirection = CGVectorMake(GRAVITY_MAGNITUDE, 0.0f);
    }
}

- (void)showMainViewController {
    isMainCentered = YES;
    if (self.mainViewController.view.frame.origin.x > 0) {
        // main is on the right
        [self.collisionBehavior setTranslatesReferenceBoundsIntoBoundaryWithInsets:UIEdgeInsetsMake(0, 0, 0, -1*[self getViewWidth])];
        self.gravityBehavior.gravityDirection = CGVectorMake(-1*GRAVITY_MAGNITUDE, 0.0f);
    } else if (self.mainViewController.view.frame.origin.x < 0) {
        // main is on the left
        [self.collisionBehavior setTranslatesReferenceBoundsIntoBoundaryWithInsets:UIEdgeInsetsMake(0, -1*[self getViewWidth], 0, 0)];
        self.gravityBehavior.gravityDirection = CGVectorMake(GRAVITY_MAGNITUDE, 0.0f);
    }
}

- (void)showRightViewController {
    if (self.rightViewController != nil) {
        isMainCentered = NO;
        if (self.leftViewController != nil) {
            [self.view sendSubviewToBack:self.leftViewController.view];
        }
        [self.collisionBehavior setTranslatesReferenceBoundsIntoBoundaryWithInsets:UIEdgeInsetsMake(0, -1*[self getViewWidth], 0, -1*[self getViewWidth])];
        self.gravityBehavior.gravityDirection = CGVectorMake(-1*GRAVITY_MAGNITUDE, 0.0f);
    }
}

# pragma mark - gesture movement

- (void)screenEdgePan:(UIScreenEdgePanGestureRecognizer *)gestureRecognizer {
    CGPoint location = [gestureRecognizer locationInView:self.view];
    location.y = CGRectGetMidY(self.mainViewController.view.bounds);

    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self.animator removeBehavior:self.gravityBehavior];
        self.attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:self.mainViewController.view attachedToAnchor:location];
        [self.animator addBehavior:self.attachmentBehavior];
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        if (self.mainViewController.view.frame.origin.x > 0) {
            [self.view sendSubviewToBack:self.rightViewController.view];
        } else if (self.mainViewController.view.frame.origin.x < 0) {
            [self.view sendSubviewToBack:self.leftViewController.view];
        }
        self.attachmentBehavior.anchorPoint = location;
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self.animator removeBehavior:self.attachmentBehavior];
        self.attachmentBehavior = nil;

        [self.animator addBehavior:self.gravityBehavior];

        CGPoint velocity = [gestureRecognizer velocityInView:self.view];

        if (velocity.x > 0) {
            if (isMainCentered && gestureRecognizer == self.leftScreenEdgePanGestureRecognizer) {
                [self showLeftViewController];
            } else if (self.mainViewController.view.frame.origin.x > 0 && !isMainCentered) {
                [self showLeftViewController];
            } else {
                [self showMainViewController];
            }
        } else {
            if (isMainCentered && gestureRecognizer == self.rightScreenEdgePanGestureRecognizer) {
                [self showRightViewController];
            } else if (self.mainViewController.view.frame.origin.x < 0 && !isMainCentered) {
                [self showRightViewController];
            } else {
                [self showMainViewController];
            }
        }

        self.pushBehavior.pushDirection = CGVectorMake(velocity.x / 10.0f, 0.0f);
        self.pushBehavior.active = YES;
    }
}

# pragma mark - gesture delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (isMainCentered) {
        return YES;
    } else if (gestureRecognizer == self.leftScreenEdgePanGestureRecognizer) {
        return self.mainViewController.view.frame.origin.x < 0;
    } else if (gestureRecognizer == self.rightScreenEdgePanGestureRecognizer) {
        return self.mainViewController.view.frame.origin.x > 0;
    }
    return NO;
}

# pragma mark - dynamic animator delegate methods

- (void)dynamicAnimatorDidPause:(UIDynamicAnimator *)animator {
    [self.collisionBehavior setTranslatesReferenceBoundsIntoBoundaryWithInsets:UIEdgeInsetsMake(0, -1*[self getViewWidth], 0, -1*[self getViewWidth])];
    self.gravityBehavior.gravityDirection = CGVectorMake(0.0f, 0.0f);
    isAnimating = NO;
}

- (void)dynamicAnimatorWillResume:(UIDynamicAnimator *)animator {
    isAnimating = YES;
}

# pragma mark - overriding setters

- (void)setLeftViewController:(UIViewController *)_leftViewController {
    // setup
    if (!isSetup) {
        [self setup];
    }

    // the actual setter
    self->leftViewController = _leftViewController;

    // view frame
    self.leftViewController.view.frame = CGRectMake(0, 0, [self getViewWidth], [self getViewHeight]);

    // add view
    [self.view addSubview:self.leftViewController.view];
    [self.view sendSubviewToBack:self.leftViewController.view];
}

- (void)setMainViewController:(UIViewController *)_mainViewController {
    // setup
    if (!isSetup) {
        [self setup];
    }

    // the actual setter
    self->mainViewController = _mainViewController;

    // view frame
    self.mainViewController.view.frame = CGRectMake(0, 0, [self getViewWidth] + SHOW, [self getViewHeight]);

    // add view
    [self.view addSubview:self.mainViewController.view];
    [self.view bringSubviewToFront:self.mainViewController.view];
    isMainCentered = YES;

    // ui dynamics
    self.collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[self.mainViewController.view]];
    [self.animator addBehavior:self.collisionBehavior];

    self.pushBehavior = [[UIPushBehavior alloc] initWithItems:@[self.mainViewController.view] mode:UIPushBehaviorModeInstantaneous];
    self.pushBehavior.magnitude = 0.0f;
    self.pushBehavior.angle = 0.0f;
    [self.animator addBehavior:self.pushBehavior];

    self.gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[self.mainViewController.view]];
    self.gravityBehavior.gravityDirection = CGVectorMake(0.0f, 0.0f);
    [self.animator addBehavior:self.gravityBehavior];

    UIDynamicItemBehavior *dynamicItemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.mainViewController.view]];
    dynamicItemBehavior.elasticity = ELASTICITY;
    dynamicItemBehavior.density = DENSITY;
    [self.animator addBehavior:dynamicItemBehavior];

    // shadow
    self.mainViewController.view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.mainViewController.view.layer.shadowOpacity = 0.5f;
    self.mainViewController.view.layer.shadowRadius = 5.0f;
    self.mainViewController.view.layer.shadowOffset = CGSizeZero;
    self.mainViewController.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.mainViewController.view.bounds].CGPath;
}

- (void)setRightViewController:(UIViewController *)_rightViewController {
    // setup
    if (!isSetup) {
        [self setup];
    }

    // the actual setter
    self->rightViewController = _rightViewController;

    // view frame
    self.rightViewController.view.frame = CGRectMake(SHOW, 0, [self getViewWidth], [self getViewHeight]);

    // add view
    [self.view addSubview:self.rightViewController.view];
    [self.view sendSubviewToBack:self.rightViewController.view];
}

@end
