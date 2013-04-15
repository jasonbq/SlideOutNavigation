//
//  MainViewController.m
//  Navigation
//
//  Created by Tammy Coron on 1/19/13.
//  Copyright (c) 2013 Tammy L Coron. All rights reserved.
//

#import "MainViewController.h"
#import "CenterViewController.h"
#import "LeftPanelViewController.h"
#import "RightPanelViewController.h"
#import <QuartzCore/QuartzCore.h>

#define CENTER_TAG 1
#define LEFT_PANEL_TAG 2
#define RIGHT_TAG 3
#define CORNER_RADIUS 4
#define SLIDE_TIMING .25
#define PANEL_WIDTH 63
#define RIGHT_PANEL_TAG 3


@interface MainViewController () <CenterViewControllerDelegate, UIGestureRecognizerDelegate>
@property (strong, nonatomic) CenterViewController *centerViewController;
@property (strong, nonatomic) LeftPanelViewController *leftPanelViewController;
@property (strong, nonatomic) RightPanelViewController *rightPanelViewController;
@property (assign, nonatomic) BOOL showingLeftPanel;
@property (assign, nonatomic) BOOL showingRightPanel;
@property (assign, nonatomic) BOOL showPanel;
@property (assign, nonatomic) CGPoint preVelocity;
@end

@implementation MainViewController

#pragma mark -
#pragma mark View Did Load/Unload

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

#pragma mark -
#pragma mark View Will/Did Appear

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

#pragma mark -
#pragma mark View Will/Did Disappear

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

#pragma mark -
#pragma mark Setup View

- (void)setupView
{
    // setup center view
    self.centerViewController = [[CenterViewController alloc] initWithNibName:@"CenterViewController" bundle:nil];
    self.centerViewController.view.tag = CENTER_TAG;
    self.centerViewController.delegate = self;
    [self.view addSubview:self.centerViewController.view];
    [self addChildViewController:self.centerViewController];
    [self.centerViewController didMoveToParentViewController:self];
    
    // add gesture
    [self setupGestures];
    
}

- (void)showCenterViewWithShadow:(BOOL)value withOffset:(double)offset
{
    if (value) {
        self.centerViewController.view.layer.cornerRadius = CORNER_RADIUS;
        self.centerViewController.view.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.centerViewController.view.layer.shadowOpacity = 0.8;
        self.centerViewController.view.layer.shadowOffset = CGSizeMake(offset, offset);
    }else{
        self.centerViewController.view.layer.cornerRadius = 0;
        self.centerViewController.view.layer.shadowOffset = CGSizeMake(offset, offset);
    }
}

- (void)resetMainView
{
    if (self.leftPanelViewController != nil) {
        [self.leftPanelViewController.view removeFromSuperview];
        self.leftPanelViewController = nil;
        
        self.centerViewController.leftButton.tag = 1;
        self.showingLeftPanel = NO;
    }
    if (self.rightPanelViewController != nil) {
        [self.rightPanelViewController.view removeFromSuperview];
        self.rightPanelViewController = nil;
        
        self.centerViewController.rightButton.tag = 1;
        self.showingRightPanel = NO;
    }
    [self showCenterViewWithShadow:NO withOffset:0];
}

- (UIView *)getLeftView
{
    if (self.leftPanelViewController == nil) {
        self.leftPanelViewController = [[LeftPanelViewController alloc] initWithNibName:@"LeftPanelViewController" bundle:nil];
        self.leftPanelViewController.view.tag = LEFT_PANEL_TAG;
        self.leftPanelViewController.delegate = self.centerViewController;
        
        [self.view addSubview:self.leftPanelViewController.view];
        [self addChildViewController:self.leftPanelViewController];
        [self.leftPanelViewController didMoveToParentViewController:self];
        self.leftPanelViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }
    self.showingLeftPanel = YES;
    [self showCenterViewWithShadow:YES withOffset:-2];
    UIView *view = self.leftPanelViewController.view;
    return view;
}

- (UIView *)getRightView
{
    if (self.rightPanelViewController == nil) {
        self.rightPanelViewController = [[RightPanelViewController alloc] initWithNibName:@"RightPanelViewController" bundle:nil];
        self.rightPanelViewController.view.tag = RIGHT_TAG;
        self.rightPanelViewController.delegate = self.centerViewController;
        
        [self.view addSubview:self.rightPanelViewController.view];
        [self addChildViewController:self.rightPanelViewController];
        [self.rightPanelViewController didMoveToParentViewController:self];
        self.rightPanelViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }
    self.showingRightPanel = YES;
    [self showCenterViewWithShadow:YES withOffset:2];
    UIView *view = self.rightPanelViewController.view;
    return view;
}

#pragma mark -
#pragma mark Swipe Gesture Setup/Actions

#pragma mark - setup

- (void)setupGestures
{
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(movePanel:)];
    panRecognizer.maximumNumberOfTouches = 1;
    panRecognizer.minimumNumberOfTouches = 1;
    panRecognizer.delegate = self;
    
    [self.centerViewController.view addGestureRecognizer:panRecognizer];
}

-(void)movePanel:(id)sender
{
    UIPanGestureRecognizer *panRecognizer = (UIPanGestureRecognizer *)sender;
    [panRecognizer.view.layer removeAllAnimations];
    CGPoint translatedPoint = [panRecognizer translationInView:self.view];
    CGPoint velocity = [panRecognizer velocityInView:panRecognizer.view];
    
    if(panRecognizer.state == UIGestureRecognizerStateBegan) {
        UIView *childView = nil;
        
        if(velocity.x > 0) {
            if (!self.showingRightPanel) {
                childView = [self getLeftView];
            }
        } else {
            if (!self.showingLeftPanel) {
                childView = [self getRightView];
            }
            
        }
        // Make sure the view you're working with is front and center.
        [self.view sendSubviewToBack:childView];
        [[sender view] bringSubviewToFront:[(UIPanGestureRecognizer*)sender view]];
    }
    
    if(panRecognizer.state == UIGestureRecognizerStateEnded) {
        
        if(velocity.x > 0) {
            // NSLog(@"gesture went right");
        } else {
            // NSLog(@"gesture went left");
        }
        
        if (!self.showPanel) {
            [self movePanelToOriginalPosition];
        } else {
            if (self.showingLeftPanel) {
                [self movePanelRight];
            }  else if (self.showingRightPanel) {
                [self movePanelLeft];
            }
        }
    }
    
    if(panRecognizer.state == UIGestureRecognizerStateChanged) {
        if(velocity.x > 0) {
            // NSLog(@"gesture went right");
        } else {
            // NSLog(@"gesture went left");
        }
        
        // Are you more than halfway? If so, show the panel when done dragging by setting this value to YES (1).
        self.showPanel = abs([sender view].center.x - _centerViewController.view.frame.size.width/2) > _centerViewController.view.frame.size.width/2;
        
        // Allow dragging only in x-coordinates by only updating the x-coordinate with translation position.
        [sender view].center = CGPointMake([sender view].center.x + translatedPoint.x, [sender view].center.y);
        [(UIPanGestureRecognizer*)sender setTranslation:CGPointMake(0,0) inView:self.view];
        
        // If you needed to check for a change in direction, you could use this code to do so.
        if(velocity.x*_preVelocity.x + velocity.y*_preVelocity.y > 0) {
            // NSLog(@"same direction");
        } else {
            // NSLog(@"opposite direction");
        }
        
        self.preVelocity = velocity;
    }
}

#pragma mark -
#pragma mark Delegate Actions

- (void)movePanelLeft // to show right panel
{
    UIView *childView = [self getRightView];
    [self.view sendSubviewToBack:childView];
    
    [UIView animateWithDuration:SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.centerViewController.view.frame = CGRectMake(-self.view.frame.size.width + PANEL_WIDTH, 0, self.view.frame.size.width, self.view.frame.size.height);
    } completion:^(BOOL finished) {
        if (finished) {
            self.centerViewController.rightButton.tag = 0;
        }
    }];
}

- (void)movePanelRight // to show left panel
{
    UIView *childView = [self getLeftView];
    [self.view sendSubviewToBack:childView];
    
    [UIView animateWithDuration:SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.centerViewController.view.frame = CGRectMake(self.view.frame.size.width - PANEL_WIDTH, 0, self.view.frame.size.width, self.view.frame.size.height);
    } completion:^(BOOL finished) {
        if (finished) {
            self.centerViewController.leftButton.tag = 0;
        }
    }];
}

- (void)movePanelToOriginalPosition
{
    [UIView animateWithDuration:SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.centerViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    } completion:^(BOOL finished){
        if (finished) {
            [self resetMainView];
        }
    }];
}

#pragma mark -
#pragma mark Default System Code

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
