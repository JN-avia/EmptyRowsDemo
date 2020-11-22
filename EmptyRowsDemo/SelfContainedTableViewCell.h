//
//  SelfContainedTableViewCell.h
//  FlightBriefing
//
//  Created by Johan Nyman on 2014-10-29.
//  Copyright (c) 2014 JN Avionics. All rights reserved.
//


#import <UIKit/UIKit.h>

@class SelfContainedTableViewHeaderFooterView;

@protocol SelfContainedTableViewCellModelSource <NSObject>
- (id) modelForIndexPath:(NSIndexPath*) indexPath inTableView:(UITableView *) tableView;
@end


@interface SelfContainedTableViewCell : UITableViewCell

@property (nonatomic, weak) id <NSObject> delegate;


+ (CGFloat)cellHeightForTableView:(UITableView*) tableView
                      atIndexPath:(NSIndexPath*) indexPath;

+ (SelfContainedTableViewCell*) cellForTableView:(UITableView*) tableView
                                     atIndexPath:(NSIndexPath*) indexPath
                                 withModelSource:(id<SelfContainedTableViewCellModelSource>) modelSource
                                     andDelegate:(id<NSObject>) delegate;

/* Called by self during setup */
-(void) configureWithModel:(id) model;

/* for delegation */
- (void) callDelegateWithSelector:(SEL) theSelector andObjects:(NSArray *) args;

@end


@interface SelfContainedTableViewComponentsOwner : NSObject
@property (nonatomic, weak) IBOutlet SelfContainedTableViewCell *cell;
@property (nonatomic, weak) IBOutlet UIView *headerContentView;
@property (nonatomic, weak) IBOutlet UIView *footerContentView;

+(id)ownerWithNibName:(NSString*) nibName;
@end
