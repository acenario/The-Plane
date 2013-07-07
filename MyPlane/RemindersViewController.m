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
        
    
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];    
    
    NSLog(@"Hello!");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (PFQuery *)queryForTable {
    PFUser *user = [PFUser currentUser];
    PFRelation *relation = [user relationforKey:@"Reminders"];
    
    PFQuery *query = [relation query];
    
    PFQuery *userQuery = [PFUser query];
    
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    [query orderByDescending:@"date"];
    
    [userQuery whereKey:@"username" matchesKey:@"fromUser" inQuery:query];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        
        NSMutableArray *newProfilePicArray = [NSMutableArray array];
        if (results.count > 0) {
            for (PFObject *eachObject in results) {
                [newProfilePicArray addObject:[eachObject objectForKey:@"profilePicture"]];
            }
            allImages = newProfilePicArray;
            //[self setUpImages:allImages];
        }
        
        //NSString *email = [results valueForKey:@"email"];

        // results will contain users with a hometown team with a winning record
    }];
    
    
    
    return query;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *identifier = @"Cell";
    PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSMutableArray *imageDataArray = [NSMutableArray array];
        for (int i = 0; i < allImages.count; i++) {
            PFFile *theImage = [allImages objectAtIndex:i];
            NSData *imageData = [theImage getData];
            UIImage *image = [UIImage imageWithData:imageData];
            [imageDataArray addObject:image];
        }
        
        
        // Dispatch to main thread to update the UI
        dispatch_async(dispatch_get_main_queue(), ^{
            
            for (int i = 0; i < [imageDataArray count]; i++) {
                UIImage *image = [imageDataArray objectAtIndex:i];
                cell.imageView.image = image;
            }
            cell.textLabel.text = [object objectForKey:@"title"];
            [self.tableView reloadData];
        });
    });

    
    //PFFile *thumbnail = [object objectForKey:@"thumbnail"];
    //cell.imageView.image = [UIImage imageNamed:@"placeholder.jpg"];
    //cell.imageView.file = thumbnail;
    
    //cell.imageView.file = profilePic;
    
    
    return cell;
}

- (void)setUpImages:(NSArray *)images
{
    // Contains a list of all the BUTTONS
    allImages = [images mutableCopy];
    
    // This method sets up the downloaded images and places them nicely in a grid
    }


@end
