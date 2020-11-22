//
//  SelfContainedTableViewHeaderFooterView.m
//  FlightBriefing
//
//  Created by Johan Nyman on 2014-10-30.
//  Copyright (c) 2014 JN Avionics. All rights reserved.
//

#import "SelfContainedTableViewHeaderFooterView.h"

#import "SelfContainedTableViewCell.h" //For the owner object

#import "DecoupledView.h" //SelfContainedTableViewHeaderFooterView is not subclassed, DecoupledView is. It is then put in the headerFooterView's contentView.


@implementation SelfContainedTableViewHeaderFooterView

+(NSString*)reuseIdentifier { return NSStringFromClass(self); }
-(NSString*)reuseIdentifier { return NSStringFromClass(self.class); }


/* Class method for creating a header.
 * The nib argument specifies in which file the contentview is designed.
 * Specifiy nil as modelSource for a static view.
 */
+(SelfContainedTableViewHeaderFooterView*) headerForTableView:(UITableView *)tableView
                                                      section:(NSInteger)section
                                                   inNibNamed:(NSString *) nibName
                                              withModelSource:(id<SelfContainedTableViewHeaderFooterModelSource>)modelSource

{
 
    
    //Get a header instance (either dequeue from tableView or allocate a new one).
    NSString * reUseID = [NSString stringWithFormat:@"%@_header", [self reuseIdentifier]];
    SelfContainedTableViewHeaderFooterView * header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:reUseID];
    if (header == nil)
    {
        //Create header
        header = [SelfContainedTableViewHeaderFooterView new];
        //Get the view
        SelfContainedTableViewComponentsOwner *owner = [SelfContainedTableViewComponentsOwner ownerWithNibName:nibName];
        UIView * contentView = owner.headerContentView;
        
        //add as subview
        [header.contentView addSubview:contentView];

        /******FIXING SIZING**********/
        //Use constraints from XIB:
        contentView.translatesAutoresizingMaskIntoConstraints = NO;
        
        //Set to same size as header
        [contentView.leadingAnchor constraintEqualToAnchor:header.leadingAnchor].active = YES;
        [contentView.trailingAnchor constraintEqualToAnchor:header.trailingAnchor].active = YES;
        [contentView.topAnchor constraintEqualToAnchor:header.topAnchor].active = YES;
        [contentView.bottomAnchor constraintEqualToAnchor:header.bottomAnchor].active = YES;
        
        
    }
    
    //Configure header.
    if (modelSource != nil)
    {
        id model = [modelSource modelForHeaderInSection:section];
        [header configureWithModel:model];
        
        //Remove default label
        header.textLabel.hidden = YES;
    }
    
    return header;
}

/* Class method for creating a footer.
 * The nib argument specifies in which file the contentview is designed.
 * Specifiy nil as modelSource for a static view.
 */

+(SelfContainedTableViewHeaderFooterView*) footerForTableView:(UITableView *)tableView
                                                      section:(NSInteger)section
                                                   inNibNamed:(NSString *) nibName
                                              withModelSource:(id<SelfContainedTableViewHeaderFooterModelSource>)modelSource

{
    
    
    //Get a footer instance (either dequeue from tableView or allocate a new one).
    NSString * reUseID = [NSString stringWithFormat:@"%@_footer", [self reuseIdentifier]];
    SelfContainedTableViewHeaderFooterView * footer = [tableView dequeueReusableHeaderFooterViewWithIdentifier:reUseID];
    if (footer == nil)
    {
        //Create footer
        footer = [SelfContainedTableViewHeaderFooterView new];
        //Get the view
        SelfContainedTableViewComponentsOwner *owner = [SelfContainedTableViewComponentsOwner ownerWithNibName:nibName];
        UIView * contentView = owner.footerContentView;

        //add as subview
        [footer.contentView addSubview:contentView];
        
        /******FIXING SIZING**********/
        //Use constraints from XIB:
        contentView.translatesAutoresizingMaskIntoConstraints = NO;
        
        //Set to same size as header
        [contentView.leadingAnchor constraintEqualToAnchor:footer.leadingAnchor].active = YES;
        [contentView.trailingAnchor constraintEqualToAnchor:footer.trailingAnchor].active = YES;
        [contentView.topAnchor constraintEqualToAnchor:footer.topAnchor].active = YES;
        [contentView.bottomAnchor constraintEqualToAnchor:footer.bottomAnchor].active = YES;
        

    }
    
    //Configure footer.
    if (modelSource != nil)
    {
        id model = [modelSource modelForFooterInSection:section];
        [footer configureWithModel:model];
        
        //Remove default label
        footer.textLabel.hidden = YES;
    }
    
    return footer;
}

+ (CGFloat)headerHeightInNibNamed:(NSString *) nibName
{
    //Load the graphic and return its height
    SelfContainedTableViewComponentsOwner *owner = [SelfContainedTableViewComponentsOwner ownerWithNibName:nibName];
    return owner.headerContentView.bounds.size.height;

}
+ (CGFloat)footerHeightInNibNamed:(NSString *) nibName
{
    //Load the graphic and return its height
    SelfContainedTableViewComponentsOwner *owner = [SelfContainedTableViewComponentsOwner ownerWithNibName:nibName];
    return owner.footerContentView.bounds.size.height;
    
}

//Called by self during setup
-(void)configureWithModel:(id) model
{
    //Get the view to configure
    NSArray * views = self.contentView.subviews;
    //NSLog(@"Views: %@", views);
    
    UIView * content = [views objectAtIndex:0];
    //Verify it is a decoupled view
    if ([content isKindOfClass:[DecoupledView class]]) {
        //Cast view
        DecoupledView * dView = (DecoupledView *) content;
        //configure
        [dView updateViewWithModel:model];
    } else {
        //Warn if view is static but still provided with model.
        NSLog(@"%@ does not have a DecoupledView as content view.", [self class]);
    }
    
}

//Optionally called by other classes for more detailed setup.
- (void) configureHeaderInTableView:(UITableView *) tableView forSection:(NSInteger) section withModel:(id) model
{
    /* Subclass template. */
    NSLog(@"configureHeaderInTableView:forSection:withModel: not implemented by %@", [self reuseIdentifier] );
    
}
- (void) configureFooterInTableView:(UITableView *) tableView forSection:(NSInteger) section withModel:(id) model;
{
    /* Subclass template. */
    NSLog(@"configureFooterInTableView:forSection:withModel: not implemented by %@", [self reuseIdentifier] );
    
}


@end
