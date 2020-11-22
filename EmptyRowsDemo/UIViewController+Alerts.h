//
//  UIViewController+Alerts.h
//  FlightBriefing
//
//  Created by Johan Nyman on 2017-01-06.
//  Copyright © 2017 JN Avionics. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Alerts)

- (void) showAlertWithTitle:(NSString *) title message:(NSString *) message buttonTitle:(NSString *) button;

- (void) showAlertWithTitle:(NSString *) title message:(NSString *) message actionButtons:(NSArray *) actions;

- (void) showAlertWithTitle:(NSString *) title message:(NSString *) message buttonTitle:(NSString *) button completion:(void(^)(void)) callback;

- (void) showAlertWithTitle:(NSString *) title message:(NSString *) message actionButtons:(NSArray *) buttons completion:(void(^)(void)) callback;

/* Find the topmost viewcontroller to display an alert */
+ (UIViewController*) currentViewController;

@end
