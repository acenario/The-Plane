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
    
    if ([[notification name] isEqualToString:@"mpCenterTabbarItemTapped"])
        NSLog (@"Successfully received the add notification for Reminders!");
}


- (PFQuery *)queryForTable {
    
    
    PFQuery *photosFromCurrentUserQuery = [PFQuery queryWithClassName:@"UserInfo"];
    [photosFromCurrentUserQuery whereKeyExists:@"user"];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Reminders"];
    [query whereKey:@"user" equalTo:[PFUser currentUser].username];
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
    detailText.text = [object objectForKey:@"fromUser"];
    
    
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





@end
