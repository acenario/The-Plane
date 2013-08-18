//
//  CircleMembersViewController.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/25/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "CircleMembersViewController.h"

@interface CircleMembersViewController ()

@property (nonatomic,strong) UzysSlideMenu *uzysSMenu;

@end

@implementation CircleMembersViewController {
    UserInfo *userObject;
    NSMutableArray *selectedUsers;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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
    PFQuery *query = [Circles query];
    [query whereKey:@"name" equalTo:self.circle.name];
    [query includeKey:@"members"];
//    [query includeKey:@"memberUsernames"];
    
    return query;
}

- (void)userQuery
{
    PFQuery *query = [UserInfo query];
    [query whereKey:@"user" equalTo:[PFUser currentUser].username];
//    [query includeKey:@"members"];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        userObject = (UserInfo *)object;
        if ([self.circle.admins containsObject:userObject.user]) {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Admin Options" style:UIBarButtonItemStyleBordered target:self action:@selector(adminPanel:)];
        }
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UzysSMMenuItem *item0 = [[UzysSMMenuItem alloc] initWithTitle:@"Promote Selected Users to Admin" image:[UIImage imageNamed:@"a0.png"] action:^(UzysSMMenuItem *item) {
    }];
    item0.tag = 0;
    
    UzysSMMenuItem *item1 = [[UzysSMMenuItem alloc] initWithTitle:@"Kick Selected Users" image:[UIImage imageNamed:@"a1.png"] action:^(UzysSMMenuItem *item) {
    }];
    item0.tag = 1;
    
    //    UzysSMMenuItem *item2 = [[UzysSMMenuItem alloc] initWithTitle:@"UzysSlide Menu" image:[UIImage imageNamed:@"a2.png"] action:^(UzysSMMenuItem *item) {
    //        NSLog(@"Item: %@", item);
    //    }];
    //    item0.tag = 2;
    
    self.uzysSMenu = [[UzysSlideMenu alloc] initWithItems:@[item0,item1]];
    [self.view addSubview:self.uzysSMenu];

    
    selectedUsers = [[NSMutableArray alloc] initWithCapacity:5];
    self.tableView.rowHeight = 60;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.objects.count > 0) {
        return ((Circles *)[self.objects objectAtIndex:0]).members.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Cell";
    PFTableViewCell *cell = (PFTableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    
    UILabel *name = (UILabel *)[cell viewWithTag:6401];
    UILabel *username = (UILabel *)[cell viewWithTag:6402];
    PFImageView *image = (PFImageView *)[cell viewWithTag:6411];
    
    Circles *circle = (Circles *)[self.objects objectAtIndex:0];
    UserInfo *member = (UserInfo *)[circle.members objectAtIndex:indexPath.row];
    
    name.text = [NSString stringWithFormat:@"%@ %@", member.firstName, member.lastName];
    username.text = member.user;
    image.file = member.profilePicture;
    
    [image loadInBackground];
    
    return cell;
}

- (void)adminPanel:(id)sender {
    [self.uzysSMenu toggleMenu];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UserInfo *user = [self.objects objectAtIndex:indexPath.row];
    //    UserInfo *user2 = [UserInfo objectWithoutDataWithObjectId:user.objectId];
    
    NSUInteger index = [self.objects indexOfObject:user];
    
    if ([self.circle.admins containsObject:userObject.user]) {
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            cell.accessoryType = UITableViewCellAccessoryNone;
            if (![self.circle.admins containsObject:user.user]) {
                [selectedUsers removeObjectAtIndex:index];
            }
        } else {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            if (![self.circle.admins containsObject:user.user]) {
                [selectedUsers addObject:user];
            }
        }
    } else {
        nil;
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)kickSelectedUsers
{
    NSMutableArray *usernames = [[NSMutableArray alloc] init];
    for (UserInfo *user in selectedUsers) {
        [usernames addObject:user.user];
    }
    
    [self.circle removeObjectsInArray:selectedUsers forKey:@"members"];
    [self.circle removeObjectsInArray:usernames forKey:@"memberUsernames"];
    [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat: @"Kicked %d Members", selectedUsers.count]];
    [self.circle saveInBackground];
}

- (void)promoteSelectedUsers
{
    NSMutableArray *usernames = [[NSMutableArray alloc] init];
    for (UserInfo *user in selectedUsers) {
        [usernames addObject:user.user];
    }
    
    [self.circle addObjectsFromArray:usernames forKey:@"admins"];
    [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat: @"Promoted %d Members", selectedUsers.count]];
    [self.circle saveInBackground];
}

@end
