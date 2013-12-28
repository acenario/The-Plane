//
//  ArchivedRemindersViewController.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 12/26/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "ArchivedRemindersViewController.h"
#import "ReminderCell.h"
#import "SubclassHeader.h"

static NSString *const ReminderCellIdentifier = @"ReminderTemplateCell";


@interface ArchivedRemindersViewController ()

@end

@implementation ArchivedRemindersViewController {
    NSDateFormatter *dateFormatter;
    BOOL sortingBool; // NO = Popularity, YES = date;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    // ReminderTemplateCell
    
    UINib *cellNib = [UINib nibWithNibName:@"ReminderCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:ReminderCellIdentifier];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];

    
    [self configureViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureViewController {
    self.tableView.rowHeight = 70;
    
    UIImageView *av = [[UIImageView alloc] init];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    UIImage *background = [UIImage imageNamed:@"tableBackground"];
    av.image = background;
    
    self.tableView.backgroundView = av;
}

- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:@"Reminders"];
    
    CurrentUser *sharedManager = [CurrentUser sharedManager];
    
    if([PFUser currentUser]) {
        //Checks if logged in
        
        [query whereKey:@"user" equalTo:[PFUser currentUser].username];
        [query whereKey:@"fromUser" notContainedIn:sharedManager.currentUser.blockedUsernames];
        [query whereKey:@"archived" equalTo:[NSNumber numberWithBool:YES]]; //Searches for non-archived reminders (archive = false)
    }
    
    [query includeKey:@"fromFriend"];
    [query includeKey:@"recipient"];
    [query includeKey:@"comments"];
    [query includeKey:@"socialPost"];
    [query includeKey:@"circle"];
    
    if (sortingBool) {
        [query orderByDescending:@"date"];
    } else {
        [query orderByDescending:@"popularity"];
    }
    
    if([PFUser currentUser]) {
        if (self.objects.count == 0) {
            query.cachePolicy = kPFCachePolicyCacheThenNetwork;
        }
    }
        
    return query;
}

#pragma mark - Table View Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object;
{
    ReminderCell *cell = (ReminderCell *)[tableView dequeueReusableCellWithIdentifier:ReminderCellIdentifier];
    
    Reminders *reminder = (Reminders *)object;
    
    cell.taskLabel.text = reminder.title;
    cell.usernameLabel.text = reminder.fromUser;
    cell.dateLabel.text = [dateFormatter stringFromDate:reminder.date];
    
    
    PFObject *fromFriend = reminder.fromFriend;
    
    cell.userImage.file = (PFFile *)[fromFriend objectForKey:@"profilePicture"]; // remote image
    
    [cell.userImage loadInBackground];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Reminders *reminder = (Reminders *)[self.objects objectAtIndex:indexPath.row];
    
    [self performSegueWithIdentifier:@"ArchiveAddReminder" sender:reminder];
}

#pragma mark - Popularity


- (IBAction)segmentChanged:(id)sender {
    switch (self.popularitySegment.selectedSegmentIndex) {
        
        case 0:
            [self sortByPopularity];
            break;
            
        case 1:
            [self sortByDate];
            break;
            
        default:
            break;
    }
}

- (void)sortByPopularity {
    
    if (sortingBool) {
    sortingBool = NO;
    [self loadObjects];
    }
    
}

- (void)sortByDate {
    if (!sortingBool) {
    sortingBool = YES;
    [self loadObjects];
    }
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ArchiveAddReminder"]) {
        UINavigationController *nav = (UINavigationController *)[segue destinationViewController];
        AddReminderViewController *controller = (AddReminderViewController *)nav.topViewController;
        controller.templateReminder = sender;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:[self dataFilePath]];
    //
    //    NSString *myObjectID = [dict objectForKey:@"objectID"];
    
    
    Reminders *deleteReminder = [self.objects objectAtIndex:indexPath.row];
//    NSString *deleteName = [deleteReminder objectForKey:@"fromUser"];
//    NSString *tempName = [deleteReminder objectForKey:@"user"];
    NSMutableArray *commentsToDelete = [[NSMutableArray alloc] init];
    
    for (Comments *comment in deleteReminder.comments) {
        [commentsToDelete addObject:[Comments objectWithoutDataWithObjectId:comment.objectId]];
    }
    
    SocialPosts *post;
    if ((deleteReminder.socialPost)) {
        post = (SocialPosts *)deleteReminder.socialPost;
        if (post.claimerUsernames.count == 1) {
            [post setIsClaimed:NO];
        }
        [post removeObject:[Reminders objectWithoutDataWithObjectId:deleteReminder.objectId] forKey:@"reminder"];
        [post removeObject:deleteReminder.user forKey:@"claimerUsernames"];
        [post removeObject:[UserInfo objectWithoutDataWithObjectId:deleteReminder.recipient.objectId] forKey:@"claimers"];
    }
    
    [deleteReminder deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [Comments deleteAllInBackground:commentsToDelete block:^(BOOL succeeded, NSError *error) {
                [post saveInBackground];
            }];
            NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
            [self loadObjects];
            [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationRight];
            [SVProgressHUD showSuccessWithStatus:@"Denied Reminder"];
            
                    }
            
    }];
}



@end
