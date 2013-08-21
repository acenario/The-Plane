//
//  PickMembersViewController.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 8/19/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "PickMembersViewController.h"

@interface PickMembersViewController ()

//@property (nonatomic, strong) NSMutableArray *members;

@end

@implementation PickMembersViewController {
    BOOL allChecked;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    allChecked = NO;
//    self.members = [[NSMutableArray alloc]initWithArray:self.circle.members];
//    for (UserInfo *object in self.circle.members) {
//        if ([object.user isEqualToString:[PFUser currentUser].username]) {
//            [self.members removeObject:object];
//        }
//    }
    [self setButtonTitle:self.checkAllButton withTitle:@"Check All"];
    self.doneBarButton.enabled = NO;
    self.invitedMembers = [[NSMutableArray alloc] initWithCapacity:10];
    self.invitedUsernames = [[NSMutableArray alloc] initWithCapacity:10];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.circle.members.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    UILabel *name = (UILabel *)[cell viewWithTag:1];
    UILabel *username = (UILabel *)[cell viewWithTag:2];
    PFImageView *image = (PFImageView *)[cell viewWithTag:11];
    
    UserInfo *user = (UserInfo *)[self.circle.members objectAtIndex:indexPath.row];
    
    name.text = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
    username.text = user.user;
    image.file = user.profilePicture;
    [image loadInBackground];
    
    if ([self.invitedMembers containsObject:user]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UserInfo *user = [self.circle.members objectAtIndex:indexPath.row];
    
    NSUInteger index = [self.invitedUsernames indexOfObject:user.user];
    
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.invitedMembers removeObjectAtIndex:index];
        [self.invitedUsernames removeObject:user.user];
        allChecked = NO;
    } else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.invitedMembers addObject:user];
        [self.invitedUsernames addObject:user.user];
    }
    
    [self checkDoneBarState];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)checkAll:(id)sender
{
//    [self.invitedMembers removeAllObjects];
//    [self.invitedUsernames removeAllObjects];
    
    if (!allChecked) {
        [self setButtonTitle:self.checkAllButton withTitle:@"Uncheck All"];
        for (UserInfo *user in self.circle.members) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.circle.members indexOfObject:user] inSection:0];
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            self.doneBarButton.enabled = YES;
            [self.invitedMembers addObject:user];
            [self.invitedUsernames addObject:user.user];
        }
        allChecked = YES;
    } else {
        [self setButtonTitle:self.checkAllButton withTitle:@"Check All"];
        for (UserInfo *user in self.circle.members) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.circle.members indexOfObject:user] inSection:0];
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        [self.invitedMembers removeAllObjects];
        [self.invitedUsernames removeAllObjects];
        
        allChecked = NO;
    }
    
    [self checkDoneBarState];
}

- (IBAction)cancel:(id)sender {
    if (self.isFromCircles) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self performSegueWithIdentifier:@"UnwindToAddCircleReminder" sender:nil];
    }
}

- (IBAction)done:(id)sender {
//    [self.invitedMembers removeAllObjects];
//    [self.invitedUsernames removeAllObjects];
//
//    for (UserInfo *user in self.circle.members) {
//        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.circle.members indexOfObject:user] inSection:0];
//        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
//        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
//            [self.invitedMembers addObject:user];
//            [self.invitedUsernames addObject:user.user];
//        }
//    }
    
    [self.delegate pickMembersViewController:self didFinishPickingMembers:self.invitedMembers withUsernames:self.invitedUsernames withCircle:self.circle];
    
    if (self.isFromCircles) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self performSegueWithIdentifier:@"UnwindToAddCircleReminder" sender:nil];
    }
}

- (void)setButtonTitle:(UIButton *)button withTitle:(NSString *)title
{
    [button setTitle:title forState: UIControlStateNormal];
    [button setTitle:title forState: UIControlStateApplication];
    [button setTitle:title forState: UIControlStateHighlighted];
    [button setTitle:title forState: UIControlStateReserved];
    [button setTitle:title forState: UIControlStateSelected];
    [button setTitle:title forState: UIControlStateDisabled];
}

- (void)checkDoneBarState
{
    if (self.invitedMembers.count > 0) {
        self.doneBarButton.enabled = YES;
    }
}

@end