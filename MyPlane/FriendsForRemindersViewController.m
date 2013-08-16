//
//  FriendsForRemindersViewController.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/9/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "FriendsForRemindersViewController.h"

@interface FriendsForRemindersViewController ()

@end

@implementation FriendsForRemindersViewController {
    NSArray *friendsArray;
    NSMutableArray *fileArray;
    PFFile *pictureFile;
//    UserInfo *fromFriend;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveAddNotification:)
                                                 name:@"fCenterTabbarItemTapped"
                                               object:nil];
    
    [self queryForTable];
	// Do any additional setup after loading the view.
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)queryForTable {
    
    
    PFQuery *userQuery = [UserInfo query];
    [userQuery whereKey:@"user" equalTo:[PFUser currentUser].username];
    [userQuery includeKey:@"friends"];
    
    [userQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
//        fromFriend = (UserInfo *)object;
        friendsArray = [object objectForKey:@"friends"];
        [userQuery orderByAscending:@"friend"];
        [self.tableView reloadData];
    }];
    
    if (!pictureFile.isDataAvailable) {
        userQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [friendsArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  {
    static NSString *identifier = @"Cell";
    PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    PFImageView *picImage = (PFImageView *)[cell viewWithTag:1111];
    UILabel *contactText = (UILabel *)[cell viewWithTag:1101];
    UILabel *detailText = (UILabel *)[cell viewWithTag:1102];
    
    UserInfo *userObject = [friendsArray objectAtIndex:indexPath.row];
    NSString *username = userObject.user;
    NSString *firstName = userObject.firstName;
    NSString *lastName = userObject.lastName;
    picImage.file = userObject.profilePicture;
    contactText.text = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    detailText.text = username;
    
    [picImage loadInBackground];
    
    //SOMETHING NEEDED - CONVERT TO PFFILE
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //UserInfo *userObject = [friendsArray objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIImageView *picImage = (UIImageView *)[cell viewWithTag:1111];
    UILabel *contactText = (UILabel *)[cell viewWithTag:1101];
    UILabel *detailText = (UILabel *)[cell viewWithTag:1102];
    UserInfo *fromFriend = [friendsArray objectAtIndex:indexPath.row];
    
    [self.delegate friendsForReminders:self didFinishSelectingContactWithUsername:detailText.text withName:contactText.text withProfilePicture:picImage.image withObjectId:fromFriend];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
