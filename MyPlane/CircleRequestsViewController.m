//
//  CircleRequestsViewController.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/23/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "CircleRequestsViewController.h"

@interface CircleRequestsViewController ()

@end

@implementation CircleRequestsViewController {
    PFQuery *userQuery;
    UserInfo *userObject;
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

- (PFQuery *)queryForTable
{
    userQuery = [UserInfo query];
    [userQuery whereKey:@"user" equalTo:[PFUser currentUser].username];
    
    PFQuery *query = [Circles query];
    [query whereKey:@"pendingMembers" matchesQuery:userQuery];
    [query includeKey:@"owner"];
    
    return query;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [userQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        userObject = (UserInfo *)object;
    }];
    
    self.tableView.rowHeight = 60;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    static NSString *CellIdentifier = @"Cell";
    PFTableViewCell *cell = (PFTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Circles *circle = (Circles *)object;
    UserInfo *owner = (UserInfo *)circle.owner;
    
    UILabel *name = (UILabel *)[cell viewWithTag:6001];
    UILabel *creator = (UILabel *)[cell viewWithTag:6002];
    PFImageView *creatorImage = (PFImageView *)[cell viewWithTag:6011];
    UIButton *accept = (UIButton *)[cell viewWithTag:6041];
    
    name.text = circle.searchName;
    creator.text = [NSString stringWithFormat:@"Created by %@ %@", owner.firstName, owner.lastName];
    creatorImage.file = owner.profilePicture;
    [creatorImage loadInBackground];
    
    [accept addTarget:self action:@selector(acceptRequest:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    nil;
}

- (void)acceptRequest:(id)sender
{
    UITableViewCell *clickedCell = (UITableViewCell *)[[sender superview] superview];
    NSIndexPath *clickedButtonPath = [self.tableView indexPathForCell:clickedCell];
    Circles *circle = [self.objects objectAtIndex:clickedButtonPath.row];
    UserInfo *object = [UserInfo objectWithoutDataWithObjectId:userObject.objectId];
    
    [circle addObject:userObject forKey:@"members"];
    [circle removeObject:object forKey:@"pendingMembers"];
    [circle saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [userObject removeObject:[Circles objectWithoutDataWithObjectId:circle.objectId] forKey:@"circleRequests"];
        [userObject saveInBackground];
        [self loadObjects];
    }];
}

@end
