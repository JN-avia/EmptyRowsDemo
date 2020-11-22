//
//  UIViewController+Alerts.m
//  FlightBriefing
//
//  Created by Johan Nyman on 2017-01-06.
//  Copyright © 2017 JN Avionics. All rights reserved.
//

#import "UIViewController+Alerts.h"

@implementation UIViewController (Alerts)

- (void) showAlertWithTitle:(NSString *) title message:(NSString *) message buttonTitle:(NSString *) button
{
    [self showAlertWithTitle:title message:message buttonTitle:button completion:nil];
}

- (void) showAlertWithTitle:(NSString *) title message:(NSString *) message actionButtons:(NSArray *) actions
{
    [self showAlertWithTitle:title message:message actionButtons:actions completion:nil];
}


- (void) showAlertWithTitle:(NSString *) title message:(NSString *) message buttonTitle:(NSString *) button completion:(void(^)(void)) callback
{
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:button style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    NSArray * actions = [NSArray arrayWithObject:defaultAction];
    
    [self showAlertWithTitle:title message:message actionButtons:actions completion:callback];
}

- (void) showAlertWithTitle:(NSString *) title message:(NSString *) message actionButtons:(NSArray *) buttons completion:(void(^)(void)) callback
{
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:title
                                                                    message:message
                                                             preferredStyle:UIAlertControllerStyleAlert];
    
    for (UIAlertAction * action in buttons) {
        [alert addAction:action];
    }
    
    [self presentViewController:alert animated:YES completion:callback];
    
}

+(UIViewController*) currentViewController {
    
    // Find best view controller
    UIViewController* viewController =
    [UIApplication sharedApplication].delegate.window.rootViewController;
    return [UIViewController findTopViewController:viewController];
    
}

/* Recursive internal method to the above */
+(UIViewController*) findTopViewController:(UIViewController*)vc {
    
    if (vc.presentedViewController) {
        
        // Return presented view controller
        return [UIViewController findTopViewController:vc.presentedViewController];
        
    } else if ([vc isKindOfClass:[UISplitViewController class]]) {
        
        // Return right hand side
        UISplitViewController* svc = (UISplitViewController*) vc;
        if (svc.viewControllers.count > 0)
            return [UIViewController findTopViewController:svc.viewControllers.lastObject];
        else
            return vc;
        
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        
        // Return top view
        UINavigationController* nc = (UINavigationController*) vc;
        if (nc.viewControllers.count > 0)
            return [UIViewController findTopViewController:nc.topViewController];
        else
            return vc;
        
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        
        // Return visible view
        UITabBarController* tbc = (UITabBarController*) vc;
        if (tbc.viewControllers.count > 0)
            return [UIViewController findTopViewController:tbc.selectedViewController];
        else
            return vc;
        
    } else {

        //Any other view controller type, return last child view controller
        NSLog(@"Returning %@ for presentation of alert.", [vc class]);
        return vc;
        
    }
    
}



@end
