//
//  RemindersViewController.m
//  MyPlane
//
//  Created by Arjun Bhatnagar on 7/7/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "RemindersViewController.h"


@interface RemindersViewController ()

@end


@implementation RemindersViewController



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = YES;
        self.objectsPerPage = 25;
        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveAddNotification:)
                                                 name:@"mpCenterTabbarItemTapped"
                                               object:nil];
    
    BOOL firstTime = [[NSUserDefaults standardUserDefaults] boolForKey:@"FirstTime"];
    if (firstTime) {
        [self performSegueWithIdentifier:@"firstTimeSettings" sender:nil];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"FirstTime"];
    }
    
    
    //[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    //self.tableView.backgroundColor = [UIColor alizarinColor];

    //self.tableView.separatorColor = [UIColor blackColor];
    
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)receiveAddNotification:(NSNotification *) notification
{
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.
    
    if ([[notification name] isEqualToString:@"mpCenterTabbarItemTapped"]) {
        NSLog (@"Successfully received the add notification for Reminders!");
        [self performSegueWithIdentifier:@"AddReminder" sender:nil];
    }
}


- (PFQuery *)queryForTable {
    
    
    //PFQuery *photosFromCurrentUserQuery = [PFQuery queryWithClassName:@"UserInfo"];
    //[photosFromCurrentUserQuery whereKeyExists:@"user"];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Reminders"];
    [query whereKey:@"user" equalTo:[PFUser currentUser].username];
    [query includeKey:@"fromFriend"];
    
    
    
    
                      
    
    [query orderByAscending:@"date"];
    
    
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    
    
    
    
    

    
    
    return query;
}

-(UITableViewCell *)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UIColor *color = [UIColor greenSeaColor];
    UIColor *selectedColor = [UIColor redColor];
    
    UIView *bgView = [[UIView alloc]init];
    bgView.backgroundColor = selectedColor;
    
    cell.backgroundColor = color;

    [cell setSelectedBackgroundView:bgView];
    
    
    cell.textLabel.backgroundColor = [UIColor clearColor];
    if ([cell respondsToSelector:@selector(detailTextLabel)])
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    
    //Guess some good text colors
    cell.textLabel.textColor = selectedColor;
    cell.textLabel.highlightedTextColor = color;
    if ([cell respondsToSelector:@selector(detailTextLabel)]) {
        cell.detailTextLabel.textColor = selectedColor;
        cell.detailTextLabel.highlightedTextColor = color;
    }
    
    return cell;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *identifier = @"Cell";
    PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];

    }
    

    
    
    PFImageView *picImage = (PFImageView *)[cell viewWithTag:1000];
    UILabel *reminderText = (UILabel *)[cell viewWithTag:1001];
    UILabel *detailText = (UILabel *)[cell viewWithTag:1002];
    
    reminderText.text = [object objectForKey:@"title"];
    detailText.text = [object objectForKey:@"fromUser"];
    
    
    //cell.imageView.image = [UIImage imageNamed:@"buttonAdd"];
    
    PFObject *fromFriend = [object objectForKey:@"fromFriend"];
    
    
    //picImage.image = [UIImage imageNamed:@"buttonAdd"]; // placeholder image
    picImage.file = (PFFile *)[fromFriend objectForKey:@"profilePicture"]; // remote image
    
    
    
    [picImage loadInBackground];


    
   /*
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
    */
    
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AddReminder"]) {
        AddReminderViewController *controller = [segue destinationViewController];
        controller.delegate = self;
    }
    
    if ([segue.identifier isEqualToString:@"firstTimeSettings"]) {
        UINavigationController *navController = (UINavigationController *)[segue destinationViewController];
        firstTimeSettingsViewController *controller = (firstTimeSettingsViewController *)navController.topViewController;
        controller.delegate = self;
        
        
    }
}




@end
