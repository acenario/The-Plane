//
//  ReminderInclosureViewController.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/15/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "ReminderInclosureViewController.h"

@interface ReminderInclosureViewController ()

@end

@implementation ReminderInclosureViewController

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (PFQuery *)queryForTable
{
    PFQuery *query = [Comments query];
    [query whereKey:@"reminder" equalTo:self.reminderObject];
    [query includeKey:@"user"];
    
    [query orderByDescending:@"createdDate"];
    
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    return query;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ([self.objects count]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
        static NSString *CellIdentifier = @"Cell";
        PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:1301];
    UILabel *commentLabel = (UILabel *)[cell viewWithTag:1302];
    PFImageView *userImage = (PFImageView *)[cell viewWithTag:1311];
    
        Comments *comment = (Comments *)object;

        UserInfo *userObject = (UserInfo *)comment.user;
    nameLabel.text = userObject.firstName;
    commentLabel.text = comment.text;
    userImage.file = userObject.profilePicture;
    
    [userImage loadInBackground];
        return cell;
//    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ReminderObject"]) {
        ReminderObjectViewController *controller = [segue destinationViewController];
        controller.delegate = self;
        controller.reminderObject = self.reminderObject;
        controller.taskText = [self.reminderObject objectForKey:@"title"];
        controller.descriptionText = [self.reminderObject objectForKey:@"description"];
        UserInfo *object = [self.reminderObject objectForKey:@"fromFriend"];
        controller.userName = [NSString stringWithFormat:@"%@ %@", object.firstName, object.lastName ];
        controller.userUsername = object.user;
        controller.userUserImage = object.profilePicture;
    }
}

-(void)reminderObjectViewControllerDidAddComment:(ReminderObjectViewController *)controller
{
    [self.tableView reloadData];
    [self loadObjects];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
