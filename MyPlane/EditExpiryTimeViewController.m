//
//  EditExpiryTimeViewController.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 9/1/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#define kPickerAnimationDuration 0.40

#import "EditExpiryTimeViewController.h"

@interface EditExpiryTimeViewController ()

@property (nonatomic, strong) NSArray *times;
@property (nonatomic, strong) IBOutlet UIPickerView *pickerView;

@end

@implementation EditExpiryTimeViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.gracePeriod == 0) {
        self.timeLabel.text = @"No delay";
    } else if (self.gracePeriod < 60 * 60) {
        self.timeLabel.text = [NSString stringWithFormat:@"%d minutes", self.gracePeriod];
    } else if (self.gracePeriod == 60 * 60) {
        self.timeLabel.text = [NSString stringWithFormat:@"1 hour"];
    } else if (self.gracePeriod < 1440 * 60) {
        self.timeLabel.text = [NSString stringWithFormat:@"%d hours", self.gracePeriod / 60];
    } else {
        self.timeLabel.text = @"1 Day";
    }
    
    self.times = [[NSArray alloc] initWithObjects:@"No delay", @"5 minutes", @"10 minutes", @"15 minutes", @"30 minutes", @"1 hour", @"2 hours", @"6 hours", @"12 hours", @"1 day", nil];
    
    self.pickerView.delegate = self;
    int row = [self.times indexOfObject:self.timeLabel.text];
    [self.pickerView selectRow:row inComponent:0 animated:NO];
}

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component
{
    return 10;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row   forComponent:(NSInteger)component
{
    return [self.times objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.doneButton.enabled = YES;
    switch (row) {
        case 0:
            self.gracePeriod = 0;
            break;
            
        case 1:
            self.gracePeriod = 5 * 60;
            break;
            
        case 2:
            self.gracePeriod = 10 * 60;
            break;
            
        case 3:
            self.gracePeriod = 15 * 60;
            break;
            
        case 4:
            self.gracePeriod = 30 * 60;
            break;
            
        case 5:
            self.gracePeriod = 60 * 60;
            break;
            
        case 6:
            self.gracePeriod = 120 * 60;
            break;
            
        case 7:
            self.gracePeriod = 360 * 60;
            break;
            
        case 8:
            self.gracePeriod = 720 * 60;
            break;
            
        case 9:
            self.gracePeriod = 1440 * 60;
            break;
            
        default:
            self.gracePeriod = 0;
            break;
    }
    
    [self updateLabel];
}

//- (void)timePicker
//{
////	self.pickerView.date = [self.dateFormatter dateFromString:self.dateDetail.text];
////    self.pickerView.minimumDate = [NSDate date];
////
//    CGRect startFrame = self.pickerView.frame;
//    CGRect endFrame = self.pickerView.frame;
//    
//    // the start position is below the bottom of the visible frame
//    startFrame.origin.y = self.view.frame.size.height;
//    
//    // the end position is slid up by the height of the view
//    endFrame.origin.y = startFrame.origin.y - endFrame.size.height;
//    
//    self.pickerView.frame = startFrame;
//    
//    [self.view addSubview:self.pickerView];
//    
////    [UIView beginAnimations:nil context:NULL];
////    [UIView setAnimationDuration:kPickerAnimationDuration];
//    self.pickerView.frame = endFrame;
////    [UIView commitAnimations];
//    
//    // add the "Done" button to the nav bar
//    
//}

- (void)updateLabel
{
    if (self.gracePeriod == 0) {
        self.timeLabel.text = @"No delay";
    } else if (self.gracePeriod < 60 * 60) {
        self.timeLabel.text = [NSString stringWithFormat:@"%d minutes", self.gracePeriod];
    } else if (self.gracePeriod == 60 * 60) {
        self.timeLabel.text = [NSString stringWithFormat:@"1 hour"];
    } else if (self.gracePeriod < 1440 * 60) {
        self.timeLabel.text = [NSString stringWithFormat:@"%d hours", self.gracePeriod / 60];
    } else {
        self.timeLabel.text = @"1 Day";
    }
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(id)sender
{
    [self.delegate editExpiryTimeViewController:self withGracePeriod:self.gracePeriod];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
