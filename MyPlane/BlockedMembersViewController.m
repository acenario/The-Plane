//
//  BlockedMembersViewController.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 8/25/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "BlockedMembersViewController.h"
#import "Reachability.h"

@interface BlockedMembersViewController ()

@property (nonatomic, strong) CurrentUser *sharedManager;

@end

@implementation BlockedMembersViewController {
    NSMutableArray *selectedUsers;
    UserInfo *currentUser;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureViewController];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    self.sharedManager = [CurrentUser sharedManager];
    
    self.unblockButton.enabled = NO;
    selectedUsers = [[NSMutableArray alloc] init];
}

- (void)reachabilityChanged:(NSNotification*) notification
{
    if (reachability.currentReachabilityStatus == NotReachable) {
        self.unblockButton.enabled = NO;
    }
}

-(void)configureViewController {
    UIImageView *av = [[UIImageView alloc] init];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    UIImage *background = [UIImage imageNamed:@"tableBackground"];
    av.image = background;
    
    self.tableView.backgroundView = av;
    self.tableView.rowHeight = 70;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (PFQuery *)queryForTable
{
    PFQuery *query = [UserInfo query];
    [query whereKey:@"user" equalTo:[PFUser currentUser].username];
    [query includeKey:@"blockedUsers"];
    
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    return query;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.objects.count > 0) {
        currentUser = (UserInfo *)[self.objects objectAtIndex:0];
        return currentUser.blockedUsers.count;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    UserInfo *user = [currentUser.blockedUsers objectAtIndex:indexPath.row];
    
    UILabel *name = (UILabel *)[cell viewWithTag:1];
    UILabel *username = (UILabel *)[cell viewWithTag:2];
    PFImageView *image = (PFImageView *)[cell viewWithTag:11];
    
    name.text = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
    username.text = user.user;
    image.file = user.profilePicture;
    [image loadInBackground];
    
    if ([selectedUsers containsObject:user]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
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
    UILabel *username = (UILabel *)[cell viewWithTag:2];
    
    nameLabel.font = [UIFont flatFontOfSize:16];
    username.font = [UIFont flatFontOfSize:14];
    
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UserInfo *user = (UserInfo *)[currentUser.blockedUsers objectAtIndex:indexPath.row];
    
    NSUInteger index = [selectedUsers indexOfObject:user];
    
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [selectedUsers removeObjectAtIndex:index];
    } else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [selectedUsers addObject:user];
    }
    [self configureDoneButton];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)unblock:(id)sender {
    for (UserInfo *user in selectedUsers) {
        [currentUser removeObject:[UserInfo objectWithoutDataWithObjectId:user.objectId] forKey:@"blockedUsers"];
        [currentUser removeObject:user.user forKey:@"blockedUsernames"];
    }
    
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        self.sharedManager.currentUser = currentUser;
        [self loadObjects];
    }];
}

- (void)configureDoneButton
{
    if (reachability.currentReachabilityStatus == NotReachable) {
        self.unblockButton.enabled = NO;
    } else {
    if (selectedUsers.count > 0) {
        self.unblockButton.enabled = YES;
    } else {
        self.unblockButton.enabled = NO;
        }
    }
}

@end
