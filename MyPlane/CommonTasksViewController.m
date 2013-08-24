//
//  CommonTasksViewController.m
//  MyPlane
//
//  Created by Arjun Bhatnagar on 8/15/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "CommonTasksViewController.h"
#import "MZFormSheetController.h"

@interface CommonTasksViewController ()

@end

@implementation CommonTasksViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommonTasks *task = [self.objects objectAtIndex:indexPath.row];
    
    [self dismissFormSheetControllerWithCompletionHandler:^(MZFormSheetController *formSheetController) {
        [self.delegate commonTasksViewControllerDidFinishWithTask:task.text];
    }];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
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
    [self dismissFormSheetControllerWithCompletionHandler:^(MZFormSheetController *formSheetController) {
        
    }];
}

- (void)didFinish {
    [self loadObjects];
}

@end
