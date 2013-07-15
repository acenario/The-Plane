//
//  MySentReminderViewController.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/14/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "MySentRemindersViewController.h"

@interface MySentRemindersViewController ()

@end

@implementation MySentRemindersViewController {
    PFObject *selectedReminderObject;
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (PFQuery *)queryForTable {
    
    
//    PFQuery *photosFromCurrentUserQuery = [PFQuery queryWithClassName:@"UserInfo"];
//    [photosFromCurrentUserQuery whereKeyExists:@"user"];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Reminders"];
    [query whereKey:@"fromUser" equalTo:[PFUser currentUser].username];
    [query includeKey:@"fromFriend"];
    
    [query orderByAscending:@"date"];
    
    
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
    
    UIImageView *picImage = (UIImageView *)[cell viewWithTag:1000];
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
        
    });
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%@", [self.objects objectAtIndex:indexPath.row]);
    selectedReminderObject = [self.objects objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"ReminderDisclosure" sender:selectedReminderObject];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ReminderDisclosure"]) {
        UINavigationController *nvc = (UINavigationController *)[segue destinationViewController];
        ReminderDisclosureViewController *controller = (ReminderDisclosureViewController *)nvc.topViewController;
        controller.delegate = self;
        controller.reminderObject = sender;
    }
}

@end
