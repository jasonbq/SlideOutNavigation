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


@interface MainViewController () <CenterViewControllerDelegate>
@property (strong, nonatomic) CenterViewController *centerViewController;
@property (strong, nonatomic) LeftPanelViewController *leftPanelViewController;
@property (strong, nonatomic) RightPanelViewController *rightPanelViewController;
@property (assign, nonatomic) BOOL showingLeftPanel;
@property (assign, nonatomic) BOOL showingRightPanel;
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
    
}

-(void)movePanel:(id)sender
{
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
