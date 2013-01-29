//
//  CBPeoplePickerNavigationController.m
//  BlockCalls
//
//  Created by ly on 1/22/13.
//  Copyright (c) 2013 Lei Yan. All rights reserved.
//

#import "CBPeoplePickerNavigationController.h"

@interface CBPeoplePickerNavigationController ()

@end

@implementation CBPeoplePickerNavigationController

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
    // Do any additional setup after loading the view from its nib.
    self.peoplePickerDelegate = self;
    self.displayedProperties = @[[NSNumber numberWithInteger:kABPersonPhoneProperty]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - delegate
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    return YES;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    
    if (identifier != kABMultiValueInvalidIdentifier) {
        ABMultiValueRef multiValue = ABRecordCopyValue(person, property);
        CFIndex index = ABMultiValueGetIndexForIdentifier(multiValue, identifier);
        CFStringRef name = ABRecordCopyCompositeName(person);
        CFStringRef rawNumber = ABMultiValueCopyValueAtIndex(multiValue, index);
        NSString *formatedNumber = [self formatPhoneNumber:(__bridge NSString *)rawNumber];
        
        if (self.delegate!=nil
            && [self.delegate conformsToProtocol:@protocol(CBPeoplePickerNavigationControllerDelegate)])
        {
            [self.delegate peoplePickerNavigationController:self
                                       didSelectPhoneNumber:formatedNumber
                                                   withName:(__bridge NSString *)(name)];
        }
        
        CFRelease(multiValue);
        CFRelease(name);
        CFRelease(rawNumber);
    }
    
    return NO;
}

#pragma mark - Format phone number
- (NSString *)formatPhoneNumber:(NSString *)phoneNumber
{
    NSString *formatedNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    formatedNumber = [formatedNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    formatedNumber = [formatedNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    formatedNumber = [formatedNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    formatedNumber = [formatedNumber stringByReplacingOccurrencesOfString:@" " withString:@""];

    return formatedNumber;
}

@end
