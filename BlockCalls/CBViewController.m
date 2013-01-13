//
//  CBViewController.m
//  BlockCalls
//
//  Created by ly on 1/12/13.
//  Copyright (c) 2013 Lei Yan. All rights reserved.
//

#import "CBViewController.h"
#import "Header.h"


@interface CBViewController ()

@end

@implementation CBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.distanceFilter = 10000.0;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    [self.locationManager startUpdatingLocation];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.locationManager stopUpdatingLocation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)callForwarding:(id)sender
{
    NSString *callForwardingNum = @"**67*13999999999*11#";
    CTCallDial(callForwardingNum);
}

@end
