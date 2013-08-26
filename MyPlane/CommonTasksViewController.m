//
//  CommonTasksViewController.m
//  MyPlane
//
//  Created by Arjun Bhatnagar on 8/15/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "CommonTasksViewController.h"
#import "MZFormSheetController.h"
#import "Reachability.h"

@interface CommonTasksViewController ()

@end

@implementation CommonTasksViewController {
    Reachability *reachability;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.loadingViewEnabled = NO;
        
    }
    return self;
}
//
//- (PFQuery *)queryForTable
//{
//    PFQuery *query = [CommonTasks query];
//}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureViewController];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    if (self.isFromSettings) {
        self.cancelButton.title = @"Close";
    }
    
    if (reachability.currentReachabilityStatus == NotReachable) {
        self.addBtn.enabled = NO;
    } else {
        self.addBtn.enabled = YES;
    }
}

- (void)reachabilityChanged:(NSNotification*) notification
{
    if (reachability.currentReachabilityStatus == NotReachable) {
        self.addBtn.enabled = NO;
    } else {
        self.addBtn.enabled = YES;
    }
}

-(void)configureViewController {
    UIImageView *av = [[UIImageView alloc] init];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    UIImage *background = [UIImage imageNamed:@"tableBackground"];
    av.image = background;
    
    self.tableView.backgroundView = av;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (PFQuery *)queryForTable
{
    PFQuery *query = [CommonTasks query];
    [query whereKey:@"username" equalTo:[PFUser currentUser].username];
    
    [query orderByDescending:@"lastUsed"];
    
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }

    return query;
}

#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return 0;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    CommonTasks *task = (CommonTasks *)object;
    
    cell.textLabel.text = task.text;
    if (!self.isFromSettings) {
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    } else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

#pragma mark - Table view delegate

-(UITableViewCell *)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UIImageView *av = [[UIImageView alloc] init];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    UIImage *background = [UIImage imageNamed:@"list-item"];
    av.image = background;
    
    cell.backgroundView = av;
    
    UIColor *selectedColor = [UIColor colorFromHexCode:@"FF7140"];
    
    UIView *bgView = [[UIView alloc]init];
    bgView.backgroundColor = selectedColor;
    
    
    [cell setSelectedBackgroundView:bgView];
    
    cell.textLabel.font = [UIFont boldFlatFontOfSize:17];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.isFromSettings) {
    CommonTasks *task = [self.objects objectAtIndex:indexPath.row];
    task.lastUsed = [NSDate date];
    [task saveInBackground];
    [self dismissFormSheetControllerWithCompletionHandler:^(MZFormSheetController *formSheetController) {
        [self.delegate commonTasksViewControllerDidFinishWithTask:task.text];
    }];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else {
        CommonTasks *task = [self.objects objectAtIndex:indexPath.row];
        
        UINavigationController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"addCommonTask"];
        
        AddCommonTaskViewController *cVC = (AddCommonTaskViewController *)[vc topViewController];
        cVC.task = task;
        cVC.delegate = self;
        
        MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
        formSheet.shouldDismissOnBackgroundViewTap = YES;
        formSheet.transitionStyle = MZFormSheetTransitionStyleSlideAndBounceFromRight;
        formSheet.cornerRadius = 9.0;
        formSheet.portraitTopInset = 6.0;
        formSheet.landscapeTopInset = 6.0;
        formSheet.presentedFormSheetSize = CGSizeMake(320, 200);
        
        
        formSheet.willPresentCompletionHandler = ^(UIViewController *presentedFSViewController){
            presentedFSViewController.view.autoresizingMask = presentedFSViewController.view.autoresizingMask | UIViewAutoresizingFlexibleWidth;
        };
        
        
        [formSheet presentWithCompletionHandler:^(UIViewController *presentedFSViewController) {
            
            
        }];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    CommonTasks *task = [self.objects objectAtIndex:indexPath.row];
    
    UINavigationController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"addCommonTask"];
    
    AddCommonTaskViewController *cVC = (AddCommonTaskViewController *)[vc topViewController];
    cVC.task = task;
    cVC.delegate = self;
    
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
    formSheet.shouldDismissOnBackgroundViewTap = YES;
    formSheet.transitionStyle = MZFormSheetTransitionStyleSlideAndBounceFromRight;
    formSheet.cornerRadius = 9.0;
    formSheet.portraitTopInset = 6.0;
    formSheet.landscapeTopInset = 6.0;
    formSheet.presentedFormSheetSize = CGSizeMake(320, 200);
    
    
    formSheet.willPresentCompletionHandler = ^(UIViewController *presentedFSViewController){
        presentedFSViewController.view.autoresizingMask = presentedFSViewController.view.autoresizingMask | UIViewAutoresizingFlexibleWidth;
    };
    
    
    [formSheet presentWithCompletionHandler:^(UIViewController *presentedFSViewController) {
        
        
    }];
}

- (IBAction)addTask:(id)sender
{
    UINavigationController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"addCommonTask"];
    
    AddCommonTaskViewController *cVC = (AddCommonTaskViewController *)[vc topViewController];
    cVC.delegate = self;
    
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
    formSheet.shouldDismissOnBackgroundViewTap = YES;
    formSheet.transitionStyle = MZFormSheetTransitionStyleSlideAndBounceFromRight;
    formSheet.cornerRadius = 9.0;
    formSheet.portraitTopInset = 6.0;
    formSheet.landscapeTopInset = 6.0;
    formSheet.presentedFormSheetSize = CGSizeMake(320, 200);
    
    
    formSheet.willPresentCompletionHandler = ^(UIViewController *presentedFSViewController){
        presentedFSViewController.view.autoresizingMask = presentedFSViewController.view.autoresizingMask | UIViewAutoresizingFlexibleWidth;
    };
    
    
    [formSheet presentWithCompletionHandler:^(UIViewController *presentedFSViewController) {
        
        
    }];
}

- (void)cancel:(id)sender
{
    if (!self.isFromSettings) {
        [self dismissFormSheetControllerWithCompletionHandler:^(MZFormSheetController *formSheetController) {
            
        }];
    } else {
        [self performSegueWithIdentifier:@"UnwindToSettings" sender:nil];
    }
}

- (void)didFinish {
    [self loadObjects];
}

@end
