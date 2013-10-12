//
//  FCContainerViewController.m
//  MyPlane
//
//  Created by Arjun Bhatnagar on 8/23/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "FCContainerViewController.h"
#import "CurrentUser.h"
#import "CreateCircleViewController.h"

@interface FCContainerViewController ()

@property (nonatomic, strong) CurrentUser *sharedManager;

@end

@implementation FCContainerViewController {
    UINavigationController *fNavController;
    UINavigationController *cNavController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    self.sharedManager = [CurrentUser sharedManager];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveAddNotification:)
                                                 name:@"fCenterTabbarItemTapped"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveResetNotification:)
                                                 name:@"reloadTabs"
                                               object:nil];
    self.circContainer.hidden = YES;
    self.navigationController.navigationBar.hidden = YES;
    //UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"friendQuery"];
    
	// Do any additional setup after loading the view.
}


- (void)receiveAddNotification:(NSNotification *) notification
{
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.
    
    if ([[notification name] isEqualToString:@"fCenterTabbarItemTapped"]) {
        NSLog (@"Successfully received the add notification for friends or circles!");
        [self performSegueWithIdentifier:@"addReminder" sender:nil];
//        if (self.segmentedControl.selectedSegmentIndex == 0) {
//        [self performSegueWithIdentifier:@"containerAddFriend" sender:nil];
//        } else {
//            [self performSegueWithIdentifier:@"containerCreateCircle" sender:nil];
//        }
    }
    
}

- (void)receiveResetNotification:(NSNotification *) notification
{
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.
    
    if ([[notification name] isEqualToString:@"reloadTabs"]) {
        [self resetAllTabs];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)changePage:(id)sender {
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showFriends" object:nil];
        self.FCContainer.hidden = NO;
        self.circContainer.hidden = YES;
        //NSLog(@"showFriends");
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showCircles" object:nil];
        self.FCContainer.hidden = YES;
        self.circContainer.hidden = NO;
        //NSLog(@"show circles");
    }
}

- (void)friendsSegmentChanged:(UISegmentedControl *)segmentedController
{
    if (segmentedController.selectedSegmentIndex == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showFriends" object:nil];
        self.FCContainer.hidden = NO;
        self.circContainer.hidden = YES;
        self.segmentedControl.selectedSegmentIndex = 0;
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showCircles" object:nil];
        self.FCContainer.hidden = YES;
        self.circContainer.hidden = NO;
        self.segmentedControl.selectedSegmentIndex = 1;
    }
}

- (void)circlesSegmentDidChange:(UISegmentedControl *)segmentedController
{
    if (segmentedController.selectedSegmentIndex == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showFriends" object:nil];
        self.FCContainer.hidden = NO;
        self.circContainer.hidden = YES;
        self.segmentedControl.selectedSegmentIndex = 0;
        //NSLog(@"showFriends");
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showCircles" object:nil];
        self.FCContainer.hidden = YES;
        self.circContainer.hidden = NO;
        self.segmentedControl.selectedSegmentIndex = 1;
        //NSLog(@"show circles");
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Circles"]) {
        cNavController = (UINavigationController *)[segue destinationViewController];
        CirclesViewController *controller = (CirclesViewController *)cNavController.topViewController;
        controller.delegate = self;
    } else if ([segue.identifier isEqualToString:@"Friends"]) {
        fNavController = (UINavigationController *)[segue destinationViewController];
        FriendsQueryViewController *controller = (FriendsQueryViewController *)fNavController.topViewController;
        controller.delegate = self;
    } else if ([segue.identifier isEqualToString:@"containerCreateCircle"]) {
        UINavigationController *nav = (UINavigationController *)[segue destinationViewController];
        CreateCircleViewController *controller = (CreateCircleViewController *)nav.topViewController;
        controller.currentUser = self.sharedManager.currentUser;
    }
}

- (void)resetAllTabs{
//    for (id controller in self.circContainer.subviews){
//        NSLog(@"LEVEL ONE: %@", controller);
//        if ([controller isMemberOfClass:[UIView class]]) {
////            for (id newCont in controller.subviews) {
////                NSLog(@"LEVEL 2: %@", newCont);
////                if ([newCont isMemberOfClass:[UINavigationController class]]) {
////                    [newCont popToRootViewControllerAnimated:NO];
////                }
////            }
//        }
//    }
    [cNavController popToRootViewControllerAnimated:NO];
    [fNavController popToRootViewControllerAnimated:NO];
    if (self.FCContainer.hidden) {
        self.circContainer.hidden = YES;
        self.FCContainer.hidden = NO;
    }
    
}

@end
