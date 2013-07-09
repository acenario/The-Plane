//
//  AddReminderViewController.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/8/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "AddReminderViewController.h"

@end

@interface AddReminderViewController ()

@end

@implementation AddReminderViewController

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

- (void)done:(id)sender
{
    PFObject *reminder = [PFObject objectWithClassName:@"Reminders"];
    [reminder setObject:[NSDate date] forKey:@"date"];
    [reminder setObject:self.taskTextField.text forKey:@"title"];
    [reminder setObject:@"abhijay" forKey:@"user"];
    [reminder setObject:[PFUser currentUser].username forKey:@"fromUser"];
    [reminder saveInBackground];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
