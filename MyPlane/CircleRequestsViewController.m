//
//  CircleRequestsViewController.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/23/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "CircleRequestsViewController.h"

@interface CircleRequestsViewController ()

@property (nonatomic, strong) NSString *segmentName;
@property (nonatomic, strong) NSMutableArray *invites;
@property (nonatomic, strong) NSMutableArray *requests;
@property (nonatomic, strong) CurrentUser *sharedManager;

@end

@implementation CircleRequestsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = YES;
        self.objectsPerPage = 25;
        self.loadingViewEnabled = NO;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Preload Methods

- (PFQuery *)queryForTable
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"receiverUsername = %@ OR circle IN %@ AND sender = %@", [PFUser currentUser].username, self.circles, NULL];
    PFQuery *query = [PFQuery queryWithClassName:@"Requests" predicate:predicate];
    //    PFQuery *query = [Requests query];
    //    [query whereKey:@"receiverUsername" equalTo:[PFUser currentUser].username];
    [query includeKey:@"circle"];
    [query includeKey:@"sender"];
    [query includeKey:@"receiver"];
    
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    return query;
    
}


-(void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    [self.invites removeAllObjects];
    [self.requests removeAllObjects];
    
    for (Requests *request in self.objects) {
        if ((request.sender)) {
            [self.invites addObject:request];
        } else {
            Circles *circle = (Circles *)request.circle;
            if ([circle.admins containsObject:[PFUser currentUser].username]) {
                [self.requests addObject:request];
            }
        }
    }
    
    if (error) {
        NSLog(@"error: %@", error);
        
    }
    
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.segmentName = @"invites";
    
    self.invites = [[NSMutableArray alloc] initWithCapacity:5];
    self.requests = [[NSMutableArray alloc] initWithCapacity:5];
    self.sharedManager = [CurrentUser sharedManager];
    
    [self configureViewController];
}

-(void)configureViewController {
    UIImageView *av = [[UIImageView alloc] init];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    UIImage *background = [UIImage imageNamed:@"tableBackground"];
    av.image = background;
    
    self.tableView.backgroundView = av;
    
    self.tableView.rowHeight = 70;
    
    self.segmentedControl.selectedFont = [UIFont boldFlatFontOfSize:16];
    self.segmentedControl.selectedFontColor = [UIColor cloudsColor];
    self.segmentedControl.deselectedFont = [UIFont flatFontOfSize:16];
    self.segmentedControl.deselectedFontColor = [UIColor cloudsColor];
    self.segmentedControl.selectedColor = [UIColor colorFromHexCode:@"FF7140"];
    self.segmentedControl.deselectedColor = [UIColor colorFromHexCode:@"FF9773"];
    self.segmentedControl.dividerColor = [UIColor colorFromHexCode:@"FF7140"];
    self.segmentedControl.cornerRadius = 5.0f;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.delegate circleRequestsDidFinish:self];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        return self.invites.count;
    } else {
        return self.requests.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        
        static NSString *cellIdentifier = @"InviteCell";
        PFTableViewCell *cell = (PFTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        
        Requests *request = (Requests *)[self.invites objectAtIndex:indexPath.row];
        
        Circles *circle = (Circles *)request.circle;
        UserInfo *inviter = (UserInfo *)request.sender;
        
        UILabel *inviterName = (UILabel *)[cell viewWithTag:6001];
        UILabel *circleName = (UILabel *)[cell viewWithTag:6002];
        PFImageView *inviterImage = (PFImageView *)[cell viewWithTag:6011];
        UIButton *accept = (UIButton *)[cell viewWithTag:6041];
        
        inviterName.text = [NSString stringWithFormat:@"%@ %@. invites you to join:", inviter.firstName, [inviter.lastName substringToIndex:1]];
        circleName.text = circle.displayName;
        inviterImage.file = inviter.profilePicture;
        [inviterImage loadInBackground];
        
        [accept addTarget:self action:@selector(acceptRequest:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
        
    } else {
        static NSString *CellIdentifier = @"RequestCell";
        PFTableViewCell *cell = (PFTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        Requests *request = (Requests *)[self.requests objectAtIndex:indexPath.row];
        
        Circles *circle = (Circles *)request.circle;
        UserInfo *requester = (UserInfo *)request.receiver;
        
        UILabel *name = (UILabel *)[cell viewWithTag:6003];
        UILabel *requesterName = (UILabel *)[cell viewWithTag:6004];
        PFImageView *requesterImage = (PFImageView *)[cell viewWithTag:6012];
        UIButton *accept = (UIButton *)[cell viewWithTag:6042];
        
        name.text = circle.displayName;
        requesterName.text = [NSString stringWithFormat:@"%@ %@", requester.firstName, requester.lastName];
        requesterImage.file = requester.profilePicture;
        [requesterImage loadInBackground];
        
        [accept addTarget:self action:@selector(acceptRequest:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
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
    
    if (self.segmentedControl.selectedSegmentIndex == 0) {
    
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:6001];
    UILabel *circleLabel = (UILabel *)[cell viewWithTag:6002];
    FUIButton *joinBtn = (FUIButton *)[cell viewWithTag:6041];
    nameLabel.font = [UIFont flatFontOfSize:13];
    circleLabel.font = [UIFont boldFlatFontOfSize:13];
        
    joinBtn.buttonColor = [UIColor colorFromHexCode:@"FF7140"];
    joinBtn.shadowColor = [UIColor colorFromHexCode:@"FF9773"];
    joinBtn.shadowHeight = 2.0f;
    joinBtn.cornerRadius = 3.0f;
    joinBtn.titleLabel.font = [UIFont boldFlatFontOfSize:15];
        
    [joinBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [joinBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    
    } else {
        UILabel *requestCircleLabel = (UILabel *)[cell viewWithTag:6003];
        UILabel *requestNamecircleLabel = (UILabel *)[cell viewWithTag:6004];
        UILabel *requestInviteLabel = (UILabel *)[cell viewWithTag:6005];
        FUIButton *acceptBtn = (FUIButton *)[cell viewWithTag:6042];
        requestCircleLabel.font = [UIFont flatFontOfSize:14];
        requestNamecircleLabel.font = [UIFont boldFlatFontOfSize:13];
        requestInviteLabel.font = [UIFont flatFontOfSize:12];
        
        acceptBtn.buttonColor = [UIColor colorFromHexCode:@"FF7140"];
        acceptBtn.shadowColor = [UIColor colorFromHexCode:@"FF9773"];
        acceptBtn.shadowHeight = 2.0f;
        acceptBtn.cornerRadius = 3.0f;
        acceptBtn.titleLabel.font = [UIFont boldFlatFontOfSize:15];
        
        [acceptBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [acceptBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        
    }
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    nil;
    //[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        
        Requests *deleteInvite = [self.invites objectAtIndex:indexPath.row];
        Circles *circle = (Circles *)deleteInvite.circle;
        [circle removeObject:self.currentUser.user forKey:@"pendingMembers"];
        [circle removeObject:[Requests objectWithoutDataWithObjectId:deleteInvite.objectId] forKey:@"requestsArray"];
        
        [deleteInvite deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [circle saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    [self.currentUser incrementKey:@"circleRequestsCount" byAmount:[NSNumber numberWithInt:-1]];
                    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {                        
                        NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
                        [self loadObjects];
                        
                        [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationRight];
                        [SVProgressHUD showSuccessWithStatus:@"Removed Invite!"];
                    }];
                }];
            }
        }];
        
        
    } else {
        
        Requests *deleteRequest = [self.requests objectAtIndex:indexPath.row];
        Circles *circle = (Circles *)deleteRequest.circle;
        NSMutableArray *usersToEdit = [[NSMutableArray alloc]init];
        [circle removeObject:self.currentUser.user forKey:@"pendingMembers"];
        [circle removeObject:[Requests objectWithoutDataWithObjectId:deleteRequest.objectId] forKey:@"requestsArray"];
        
        for (UserInfo *user in circle.adminPointers) {
            [user incrementKey:@"circleRequestsCount" byAmount:[NSNumber numberWithInt:-1]];
            [usersToEdit addObject:user];
        }
        
        [deleteRequest deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [circle saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    
                [UserInfo saveAllInBackground:usersToEdit block:^(BOOL succeeded, NSError *error) {
                    NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
                    [self loadObjects];
                    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationRight];
                    [SVProgressHUD showSuccessWithStatus:@"Removed Request!"];
                    }];
                }];
            }
        }];
        
        
    }
    
    
    
    
    
    
}

- (void)acceptRequest:(id)sender
{
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        UITableViewCell *clickedCell = (UITableViewCell *)[[sender superview] superview];
        NSIndexPath *clickedButtonPath = [self.tableView indexPathForCell:clickedCell];
        Requests *request = [self.invites objectAtIndex:clickedButtonPath.row];
        Circles *circle = (Circles *)request.circle;
        UserInfo *user = [UserInfo objectWithoutDataWithObjectId:self.currentUser.objectId];
//        NSMutableArray *usersToSave = [[NSMutableArray alloc] init];
        
        [self.currentUser incrementKey:@"circleRequestsCount" byAmount:[NSNumber numberWithInt:-1]];
        
        [circle addObject:user forKey:@"members"];
        [circle addObject:self.currentUser.user forKey:@"memberUsernames"];
        [circle removeObject:self.currentUser.user forKey:@"pendingMembers"];
        [circle removeObject:[Requests objectWithoutDataWithObjectId:request.objectId] forKey:@"requestsArray"];
        
        [request deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [circle saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    self.sharedManager.currentUser = self.currentUser;
                }];
            }];
            [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"You have joined %@", circle.name]];
            [self loadObjects];
        }];
        
    } else {
        UITableViewCell *clickedCell = (UITableViewCell *)[[sender superview] superview];
        NSIndexPath *clickedButtonPath = [self.tableView indexPathForCell:clickedCell];
        Requests *request = [self.requests objectAtIndex:clickedButtonPath.row];
        Circles *circle = (Circles *)request.circle;
        UserInfo *user = [UserInfo objectWithoutDataWithObjectId:request.receiver.objectId];
        
        NSMutableArray *usersToSave = [[NSMutableArray alloc] init];
        
        if ([circle.members containsObject:user]) {
            [self loadObjects];
        } else {
            
            for (UserInfo *obj in circle.members) {
                [obj incrementKey:@"circleRequestsCount" byAmount:[NSNumber numberWithInt:-1]];
                [usersToSave addObject:obj];
            }
            
            [circle addObject:user forKey:@"members"];
            [circle addObject:request.receiverUsername forKey:@"memberUsernames"];
            [circle removeObject:request.receiverUsername forKey:@"pendingMembers"];
            [circle removeObject:[Requests objectWithoutDataWithObjectId:request.objectId] forKey:@"requestsArray"];
            
            [request deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [circle saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"%@ is now part of %@", request.receiverUsername,circle.name]];
                    [UserInfo saveAllInBackground:usersToSave block:^(BOOL succeeded, NSError *error) {
                        [self loadObjects];
                    }];
                }];
            }];
        }
    }
}

- (IBAction)segmentedChange:(id)sender {
    //self.segmentName = [[self.segmentedControl titleForSegmentAtIndex:self.segmentedControl.selectedSegmentIndex] lowercaseString];
    [self.tableView reloadData];
}

@end
