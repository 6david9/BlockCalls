//
//  CBPeoplePickerNavigationController.h
//  BlockCalls
//
//  Created by ly on 1/22/13.
//  Copyright (c) 2013 Lei Yan. All rights reserved.
//

#import <AddressBookUI/AddressBookUI.h>

@interface CBPeoplePickerNavigationController : ABPeoplePickerNavigationController
 <ABPeoplePickerNavigationControllerDelegate>

@property (weak, nonatomic) id delegate;

@end

@protocol CBPeoplePickerNavigationControllerDelegate <NSObject>

- (void)peoplePickerNavigationController:(CBPeoplePickerNavigationController *)controller
                    didSelectPhoneNumber:(NSString *)number
                                withName:(NSString *)name;

@end
