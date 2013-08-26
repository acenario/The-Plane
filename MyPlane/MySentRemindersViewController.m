//
//  MySentReminderViewController.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/14/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "MySentRemindersViewController.h"
#import "Reachability.h"

@interface MySentRemindersViewController ()

@end

@implementation MySentRemindersViewController {
    PFObject *selectedReminderObject;
    UIImage *userProfilePicture;
    NSDateFormatter *dateFormatter;
    Reachability *reachability;
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
    reachability = [Reachability reachabilityForInternetConnection];
    //    [self getUserPicture];
	// Do any additional setup after loading the view.
    
    self.tableView.rowHeight = 70;
    
    UIImageView *av = [[UIImageView alloc] init];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    UIImage *background = [UIImage imageNamed:@"tableBackground"];
    av.image = background;
    
    self.tableView.backgroundView = av;
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    
    // Dispose of any resources that can be recreated.
}

//-(void)getUserPicture {
//    PFQuery *query = [UserInfo query];
//    [query whereKey:@"user" equalTo:[PFUser currentUser].username];
//    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
//        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//        dispatch_async(queue, ^{
//        PFFile *theImage = (PFFile *)[object objectForKey:@"profilePicture"];
//        UIImage *fromUserImage = [[UIImage alloc] initWithData:theImage.getData];
//        userProfilePicture = fromUserImage;
//        });
//
//    }];
//
//}

- (PFQuery *)queryForTable {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Reminders"];
    [query whereKey:@"fromUser" equalTo:[PFUser currentUser].username];
    [query includeKey:@"fromFriend"];
    [query includeKey:@"recipient"];
    
    [query orderByDescending:@"date"];
    
    
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    return query;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *identifier = @"Cell";
    PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    UserInfo *recipient = (UserInfo *)[object objectForKey:@"recipient"];
    UILabel *title = (UILabel *)[cell viewWithTag:1];
    UILabel *name = (UILabel *)[cell viewWithTag:2];
    UILabel *date = (UILabel *)[cell viewWithTag:3];
    PFImageView *image = (PFImageView *)[cell viewWithTag:11];
    
    image.file = recipient.profilePicture;
    name.text = [object objectForKey:@"user"];
    title.text = [object objectForKey:@"title"];
    date.text = [dateFormatter stringFromDate:[object objectForKey:@"date"]];
    [image loadInBackground];
    
    
    
    /*UIImageView *picImage = (UIImageView *)[cell viewWithTag:1000];
     UILabel *reminderText = (UILabel *)[cell viewWithTag:1001];
     UILabel *detailText = (UILabel *)[cell viewWithTag:1002];
     
     reminderText.text = [object objectForKey:@"title"];
     detailText.text = [object objectForKey:@"user"];
     
     
     //cell.imageView.image = [UIImage imageNamed:@"buttonAdd"];
     
     PFObject *fromFriend = [object objectForKey:@"fromFriend"];
     NSMutableArray *results = [[NSMutableArray alloc]initWithObjects:fromFriend, nil];
     
     dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
     dispatch_async(queue, ^{
     for (PFObject *object in results) {
     PFFile *theImage = (PFFile *)[object objectForKey:@"profilePicture"];
     UIImage *fromUserImage = [[UIImage alloc] initWithData:theImage.getData];
     
     dispatch_async(dispatch_get_main_queue(), ^{
     
     picImage.image = fromUserImage;
     
     });
     }
     
     });*/
    
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
    
    UILabel *reminderLabel = (UILabel *)[cell viewWithTag:1];
    UILabel *usernameLabel = (UILabel *)[cell viewWithTag:2];
    UILabel *dateLabel = (UILabel *)[cell viewWithTag:3];
    
    reminderLabel.font = [UIFont flatFontOfSize:16];
    usernameLabel.font = [UIFont flatFontOfSize:14];
    dateLabel.font = [UIFont flatFontOfSize:14];
    
    reminderLabel.textColor = [UIColor colorFromHexCode:@"A62A00"];

    
    
    /*cell.textLabel.backgroundColor = [UIColor clearColor];
     if ([cell respondsToSelector:@selector(detailTextLabel)])
     cell.detailTextLabel.backgroundColor = [UIColor clearColor];
     
     //Guess some good text colors
     cell.textLabel.textColor = selectedColor;
     cell.textLabel.highlightedTextColor = color;
     if ([cell respondsToSelector:@selector(detailTextLabel)]) {
     cell.detailTextLabel.textColor = selectedColor;
     cell.detailTextLabel.highlightedTextColor = color;
     }*/
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    selectedReminderObject = [self.objects objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"ReminderDisclosure" sender:selectedReminderObject];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (reachability.currentReachabilityStatus == NotReachable) {
        NSLog(@"No internet connection!");
        return UITableViewCellEditingStyleNone;
    } else {
        return UITableViewCellEditingStyleDelete;
    }
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    Reminders *deleteReminder = [self.objects objectAtIndex:indexPath.row];
    NSString *deleteName = [deleteReminder objectForKey:@"user"];
    NSString *tempName = [deleteReminder objectForKey:@"fromUser"];
    NSMutableArray *commentsToDelete = [[NSMutableArray alloc] init];
    
    for (Comments *comment in deleteReminder.comments) {
        [commentsToDelete addObject:[Comments objectWithoutDataWithObjectId:comment.objectId]];
    }
    
    [deleteReminder deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [Comments deleteAllInBackground:commentsToDelete];
            NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
            [self loadObjects];
            [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationRight];
            [SVProgressHUD showSuccessWithStatus:@"Removed Reminder!"];
            
            if (![deleteName isEqualToString:[PFUser currentUser].username]) {
            NSString *message = [NSString stringWithFormat:@"%@ has deleted his reminder", tempName];
            
            PFQuery *pushQuery = [PFInstallation query];
            [pushQuery whereKey:@"user" equalTo:deleteName];
            
            PFPush *push = [[PFPush alloc] init];
            [push setQuery:pushQuery];
            [push setMessage:message];
            [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                NSString *message = [NSString stringWithFormat:@"%@ has been notified!", deleteName];
                [SVProgressHUD showSuccessWithStatus:message];
                }];
            }
            
        }
    }];
    
    
    
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ReminderDisclosure"]) {
        ReminderDisclosureViewController *controller = [segue destinationViewController];
        controller.delegate = self;
        controller.reminderObject = sender;
    }
}
 
- (IBAction)doneButton:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
