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

@end

@implementation CircleRequestsViewController {
    PFQuery *userQuery;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = YES;
        self.objectsPerPage = 25;
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
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"receiverUsername = %@ OR circle IN %@ AND sender =  %@", [PFUser currentUser].username, self.circles, NULL];
    PFQuery *query = [PFQuery queryWithClassName:@"Requests" predicate:predicate];
    //    PFQuery *query = [Requests query];
    //    [query whereKey:@"receiverUsername" equalTo:[PFUser currentUser].username];
    [query includeKey:@"circle"];
    [query includeKey:@"sender"];
    [query includeKey:@"receiver"];
    
    return query;
    
}


-(void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    [self.invites removeAllObjects];
    [self.requests removeAllObjects];
    
    for (Requests *request in self.objects) {
        NSLog(@"%d", self.objects.count);
        if ((request.sender)) {
            [self.invites addObject:request];
        } else {
            [self.requests addObject:request];
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
    self.segmentName = @"invites";
    
    self.invites = [[NSMutableArray alloc] initWithCapacity:5];
    self.requests = [[NSMutableArray alloc] initWithCapacity:5];
    
    self.tableView.rowHeight = 60;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.segmentName isEqualToString:@"invites"]) {
        return self.invites.count;
    } else {
        return self.requests.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.segmentName isEqualToString:@"invites"]) {
        
        static NSString *cellIdentifier = @"InviteCell";
        PFTableViewCell *cell = (PFTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        
        Requests *request = (Requests *)[self.invites objectAtIndex:indexPath.row];
        
        Circles *circle = (Circles *)request.circle;
        UserInfo *inviter = (UserInfo *)request.sender;
        
        UITextView *inviterName = (UITextView *)[cell viewWithTag:6001];
        UITextView *circleName = (UITextView *)[cell viewWithTag:6002];
        PFImageView *inviterImage = (PFImageView *)[cell viewWithTag:6011];
        UIButton *accept = (UIButton *)[cell viewWithTag:6041];
        
        inviterName.text = [NSString stringWithFormat:@"%@ %@ invites you to join", inviter.firstName, [inviter.lastName substringToIndex:1]];
        circleName.text = circle.searchName;
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
        
        UITextView *name = (UITextView *)[cell viewWithTag:6003];
        UITextView *requesterName = (UITextView *)[cell viewWithTag:6004];
        PFImageView *requesterImage = (PFImageView *)[cell viewWithTag:6012];
        UIButton *accept = (UIButton *)[cell viewWithTag:6042];
        
        name.text = circle.searchName;
        requesterName.text = [NSString stringWithFormat:@"%@ %@", requester.firstName, requester.lastName];
        requesterImage.file = requester.profilePicture;
        [requesterImage loadInBackground];
        
        [accept addTarget:self action:@selector(acceptRequest:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)acceptRequest:(id)sender
{
    if ([self.segmentName isEqualToString:@"invites"]) {
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
        
        
        [request deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [circle saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    nil;
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
    self.segmentName = [[self.segmentedControl titleForSegmentAtIndex:self.segmentedControl.selectedSegmentIndex] lowercaseString];
    [self.tableView reloadData];
}

@end
