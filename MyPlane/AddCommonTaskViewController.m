//
//  AddCommonTaskViewController.m
//  MyPlane
//
//  Created by Arjun Bhatnagar on 8/15/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "AddCommonTaskViewController.h"

@interface AddCommonTaskViewController ()

@end

@implementation AddCommonTaskViewController {
    BOOL editing;
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
    
    if ((self.task)) {
        editing = NO;
    } else {
        editing = YES;
        self.textField.text = self.task.text;
        self.doneButton.enabled = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)done
{
    if (editing) {

        self.task.text = self.textField.text;
        self.task.lastUsed = [NSDate date];
        
        [self.task saveInBackground];
    } else {
        
        CommonTasks *task = [CommonTasks object];
        task.text = self.textField.text;
        task.user = self.currentUser;
        task.username = self.currentUser.user;
        task.lastUsed = [NSDate date];
        
        [task saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [self.currentUser addObject:[CommonTasks objectWithoutDataWithObjectId:task.objectId] forKey:@"commonTasks"];
            [self.currentUser saveInBackground];
        }];
    }
}

- (void)textValidate {
    if ([self.textField.text length] > 0) {
        self.doneButton.enabled = YES;
    } else {
        self.doneButton.enabled = YES;
    }
}

@end
