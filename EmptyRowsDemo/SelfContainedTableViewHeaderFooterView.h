//
//  SelfContainedTableViewHeaderFooterView.h
//  FlightBriefing
//
//  Created by Johan Nyman on 2014-10-30.
//  Copyright (c) 2014 JN Avionics. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelfContainedTableViewHeaderFooterModelSource <NSObject>
- (id) modelForHeaderInSection:(NSInteger) section;
- (id) modelForFooterInSection:(NSInteger) section;
@end

@interface SelfContainedTableViewHeaderFooterView : UITableViewHeaderFooterView


+ (SelfContainedTableViewHeaderFooterView*) headerForTableView:(UITableView*) tableView
                                                       section:(NSInteger) section
                                                    inNibNamed:(NSString *) nibName
                                               withModelSource:(id<SelfContainedTableViewHeaderFooterModelSource>) modelSource;

+ (SelfContainedTableViewHeaderFooterView*) footerForTableView:(UITableView*) tableView
                                                       section:(NSInteger) section
                                                    inNibNamed:(NSString *) nibName
                                               withModelSource:(id<SelfContainedTableViewHeaderFooterModelSource>) modelSource;


+ (CGFloat)headerHeightInNibNamed:(NSString *) nibName;
+ (CGFloat)footerHeightInNibNamed:(NSString *) nibName;

/* For more detailed setup */
- (void) configureHeaderInTableView:(UITableView *) tableView forSection:(NSInteger) section withModel:(id) model;
- (void) configureFooterInTableView:(UITableView *) tableView forSection:(NSInteger) section withModel:(id) model;


@end
