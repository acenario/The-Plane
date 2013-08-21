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
    NSMutableArray *selectedUsers;
    BOOL optionToggle;
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

//- (void)userQuery
//{
//    PFQuery *query = [UserInfo query];
//    [query whereKey:@"user" equalTo:[PFUser currentUser].username];
////    [query includeKey:@"members"];
//    
//    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
//        userObject = (UserInfo *)object;
//        if ([self.circle.admins containsObject:userObject.user]) {
//            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Admin Options" style:UIBarButtonItemStyleBordered target:self action:@selector(adminPanel:)];
//        }
//    }];
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UzysSMMenuItem *item0 = [[UzysSMMenuItem alloc] initWithTitle:@"Create Reminder for Selected Users" image:[UIImage imageNamed:@"a1.png"] action:^(UzysSMMenuItem *item) {
        [self createReminder];
    }];
    item0.tag = 0;

    if ([self.circle.admins containsObject:self.currentUser.user]) {
        UzysSMMenuItem *item1 = [[UzysSMMenuItem alloc] initWithTitle:@"Promote Selected Users to Admin" image:[UIImage imageNamed:@"a0.png"] action:^(UzysSMMenuItem *item) {
        }];
        item0.tag = 1;
        
        UzysSMMenuItem *item2 = [[UzysSMMenuItem alloc] initWithTitle:@"Kick Selected Users" image:[UIImage imageNamed:@"a1.png"] action:^(UzysSMMenuItem *item) {
        }];
        item0.tag = 2;
        
        self.uzysSMenu = [[UzysSlideMenu alloc] initWithItems:@[item0,item1, item2]];
    } else {
        self.uzysSMenu = [[UzysSlideMenu alloc] initWithItems:@[item0]];;
    }
    
    [self.view addSubview:self.uzysSMenu];
    optionToggle = NO;
    
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    Circles *circle = (Circles *)[self.objects objectAtIndex:0];
    UserInfo *user = (UserInfo *)[circle.members objectAtIndex:indexPath.row];
    
    NSUInteger index = [selectedUsers indexOfObject:user];
    
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
            [selectedUsers removeObjectAtIndex:index];
    } else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [selectedUsers addObject:user];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)kickSelectedUsers
{
    NSMutableArray *usernames = [[NSMutableArray alloc] init];
    for (UserInfo *user in selectedUsers) {
        if (![self.circle.admins containsObject:user.user]) {
            [usernames addObject:user.user];
        }
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
        if (![self.circle.admins containsObject:user.user]) {
            [usernames addObject:user.user];
        }
    }
    
    [self.circle addObjectsFromArray:usernames forKey:@"admins"];
    [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat: @"Promoted %d Members", selectedUsers.count]];
    [self.circle saveInBackground];
}

- (void)createReminder
{
    [self performSegueWithIdentifier:@"CreateReminder" sender:nil];
}

- (IBAction)options:(id)sender
{
    if (optionToggle) {
        //Arjun do something
    } else {
        //Arjun do something
    }
    
    optionToggle = !optionToggle;
}

- (void)addCircleReminderViewController:(AddCircleReminderViewController *)controller didFinishAddingReminderInCircle:(Circles *)circle withUsers:(NSArray *)users withTask:(NSString *)task withDescription:(NSString *)description withDate:(NSDate *)date
{
    NSMutableArray *toSave = [[NSMutableArray alloc] init];
    
    for (UserInfo *user in users) {
        Reminders *reminder = [Reminders object];
        reminder.date = date;
        if (![description isEqualToString:@"Enter more information about the reminder..."]) {
            [reminder setObject:description forKey:@"description"];
        } else {
            [reminder setObject:@"No description available." forKey:@"description"];
        }
        reminder.fromFriend = self.currentUser;
        reminder.fromUser = self.currentUser.user;
        reminder.recipient = user;
        reminder.title = task;
        reminder.user = user.user;
        [reminder setObject:circle forKey:@"circle"];
        [toSave addObject:reminder];
    }
    
    [SVProgressHUD showWithStatus:@"Sending Reminders..."];
    [Reminders saveAllInBackground:toSave block:^(BOOL succeeded, NSError *error) {
        for (Reminders *reminder in toSave) {
            PFRelation *relation = [self.circle relationforKey:@"reminders"];
            //            NSLog(@"%@", reminder);
            [relation addObject:reminder];
        }
        [self.circle saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [self dismissViewControllerAnimated:YES completion:^{
                [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"Reminder Sent to %d Members of %@", toSave.count, circle.name]];
            }];
        }];
    }];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"CreateReminder"]) {
        UINavigationController *nav = (UINavigationController *)[segue destinationViewController];
        AddCircleReminderViewController *controller = (AddCircleReminderViewController *)nav.topViewController;
        
        controller.delegate = self;
        controller.circle = self.circle;
        controller.currentUser = self.currentUser;
        controller.circleCheck = YES;
//        controller.circleCell.userInteractionEnabled = NO;
        controller.invitedMembers = [[NSArray alloc] initWithArray:selectedUsers];
    }
}

@end
