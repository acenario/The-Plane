//
//  DuplicateFriendsViewController.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 10/27/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "DuplicateFriendsViewController.h"

@interface DuplicateFriendsViewController ()

@property (strong, nonatomic) NSMutableArray *peopleWhoNeedToBeFixed;

@end

@implementation DuplicateFriendsViewController

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
	// Do any additional setup after loading the view.
    self.tableView.rowHeight = 60;
    self.fixButton.enabled = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (PFQuery *)queryForTable
{
    PFQuery *query = [UserInfo query];
    
    [query whereKeyExists:@"friends"];
    
    [query includeKey:@"friends"];
    
    return query;
}

- (void)objectsDidLoad:(NSError *)error
{
    self.peopleWhoNeedToBeFixed = [[NSMutableArray alloc] initWithCapacity:10];
    
    NSMutableArray *friends = [[NSMutableArray alloc] initWithCapacity:10];
//    NSLog(@"%d", self.objects.count);
    for (UserInfo *user in self.objects) {
        [friends removeAllObjects];
        for (UserInfo *friend in user.friends) {
//            NSLog(@"user: %@ friend: %@", user.user, friend.user);
            if (![friends containsObject:friend.user]) {
                [friends addObject:friend.user];
//                NSLog(@"user: %@ non-duplicate-friend: %@", user.user, friend.user);
            } else {
//                NSLog(@"user to be fixed: %@", user.user);
                [self.peopleWhoNeedToBeFixed addObject:user];
                self.fixButton.enabled = YES;
                break;
            }
        }
    }
    
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    NSLog(@"%d", self.peopleWhoNeedToBeFixed.count);
    return self.peopleWhoNeedToBeFixed.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserInfo *user = [self.peopleWhoNeedToBeFixed objectAtIndex:indexPath.row];
    
    PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    UILabel *username = (UILabel *)[cell viewWithTag:1];
    UILabel *count = (UILabel *)[cell viewWithTag:2];
    PFImageView *imageView = (PFImageView *)[cell viewWithTag:11];
    
    username.text = user.user;
//    count.text = [NSString stringWithFormat:@"%@ duplicate friends", ];
    count.text = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
    
    imageView.file = user.profilePicture;
    [imageView loadInBackground];
    
    return cell;
}

- (IBAction)FixAll:(id)sender
{
    NSMutableArray *usersToSave = [[NSMutableArray alloc] initWithCapacity:10];
    
    for (UserInfo *user in self.peopleWhoNeedToBeFixed) {
        NSMutableArray *friends = [[NSMutableArray alloc] initWithCapacity:10];

            [friends removeAllObjects];
            for (UserInfo *friend in user.friends) {
                if (![friends containsObject:friend.user]) {
                    [friends addObject:friend.user];
//NSLog(@"user: %@ non-duplicate-friend: %@", user.user, friend.user);
                } else {
//NSLog(@"user to be fixed: %@", user.user);
                    
//NSLog(@"user: %@ friends: %d", user.user, user.friends.count);
                    
                    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:user.friends];
//NSLog(@"count: %d index: %d", tempArray.count, [tempArray indexOfObject:friend]);
                    [tempArray removeObjectAtIndex:[tempArray indexOfObject:friend]];
                    
                    user.friends = tempArray;
                    
                    if (![usersToSave containsObject:user]) {
                        [usersToSave addObject:user];
                    }
//NSLog(@"Fixed: %d", user.friends.count);
                    
                }
            }
        [UserInfo saveAllInBackground:usersToSave];
    }
}

@end
