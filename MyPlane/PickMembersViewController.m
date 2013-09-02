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
    [self configureViewController];
    allChecked = NO;

    [self.checkAllButton setTitle:@"Check All" forState:UIControlStateNormal];
    self.doneBarButton.enabled = NO;
    self.invitedMembers = [[NSMutableArray alloc] initWithCapacity:10];
    self.invitedUsernames = [[NSMutableArray alloc] initWithCapacity:10];
}

-(void)configureViewController {
    UIImageView *av = [[UIImageView alloc] init];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    UIImage *background = [UIImage imageNamed:@"tableBackground"];
    av.image = background;
    
    self.tableView.backgroundView = av;
    
    self.tableView.rowHeight = 70;
    
    self.checkAllButton.buttonColor = [UIColor colorFromHexCode:@"FF7140"];
    self.checkAllButton.shadowColor = [UIColor colorFromHexCode:@"FF9773"];
    self.checkAllButton.shadowHeight = 2.0f;
    self.checkAllButton.cornerRadius = 3.0f;
    self.checkAllButton.titleLabel.font = [UIFont boldFlatFontOfSize:13];
    
    [self.checkAllButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.checkAllButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
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
    PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
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
    
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:1];
    UILabel *usernameLabel = (UILabel *)[cell viewWithTag:2];
    
    nameLabel.font = [UIFont flatFontOfSize:16];
    usernameLabel.font = [UIFont flatFontOfSize:14];
    
    
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
        [self.checkAllButton setTitle:@"Uncheck All" forState:UIControlStateNormal];
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
        [self.checkAllButton setTitle:@"Check All" forState:UIControlStateNormal];
        for (UserInfo *user in self.circle.members) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.circle.members indexOfObject:user] inSection:0];
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        self.doneBarButton.enabled = NO;
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
    } else {
        self.doneBarButton.enabled = NO;
    }
}

@end
