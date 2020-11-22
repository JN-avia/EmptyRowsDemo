//
//  FlightPlanningSystemProxy.m
//  FlightBriefing
//
//  Created by Johan Nyman on 2014-11-11.
//  Copyright (c) 2014 JN Avionics. All rights reserved.
//

#import "FlightPlanningSystemProxy.h"
#import "SelectFlightViewController.h" //For callbacks
#import "Flight.h" //For notifications
#import "AppDelegate.h" //For connectivity check
#import "DataStore.h"


@interface FlightPlanningSystemProxy ()
{
}

//Timer that invalidates connection after 29 minutes.
@property (strong) NSTimer * timer;

@end

@implementation FlightPlanningSystemProxy

- (instancetype)init
{
    self = [super init];
    
    return self;
}

- (void) connectToFPS
{
    
    //Create connection
    
    
    //Callback to controller (On main thread)
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.controller connectionEstablished];
    });
    
    
    //Get list of flights
    
    //make the call asynchronous;
    
    
    [self listContentsAtPath:nil
             showHiddenFiles:NO
                     success:^(NSArray *contents) {
        
        //We have a connection, so reset timeout timer
        [self resetTimer];
        
        //Asynchrounous again...
        [self flightListItemsFromRemoteFiles:contents
                                  completion:^(NSArray * parsedFiles) {
            
            //Callback to controller should not be performed until above operation has completed!
            [self.controller connectionEstablishedWithFlightInfoItems:parsedFiles];
        }];
        
    } failure:^(NSError *error) {
        
        NSLog(@"%@",error.localizedDescription);
        
    }];
    
}
/* modified from FTPKit */
- (void)listContentsAtPath:(NSString *)path showHiddenFiles:(BOOL)showHiddenFiles success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure
{
    dispatch_async(dispatch_queue_create("com.ftpkit.FTPKitQueue", DISPATCH_QUEUE_SERIAL), ^{
        NSArray *contents = [self inventRemoteHandles];
        if (contents && success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                success(contents);
            });
        } else if (! contents && failure) {
            NSLog(@"Error listing contents");
        }
    });
}

- (NSArray *) inventRemoteHandles
{
    NSArray * array = [NSArray arrayWithObjects:@"1",@"2", nil];
    return  array;
}

- (BOOL) flightInfoFromHandle:(NSString*) handle toModel:(FlightInfo *) info
{
    //Create fake flightInfo
    
    info.flightNbr = [NSString stringWithFormat:@"Flight %@",handle];
    info.lastEdit = [NSDate date];
    info.uniqueID = [NSString stringWithFormat:@"id%@",handle];
    
    return YES;
}


//Parse handles, download XML files, and return an array of flightListItems
//This method does not return until all download is finished, but makes asynchrounous calls for the actual downloads
- (void) flightListItemsFromRemoteFiles:(NSArray *) ftpHandles
                             completion:(void (^)(NSArray * parsedFiles)) completionBlock
{
    
    //Convert list items to internal model
    NSMutableArray * infos = [NSMutableArray arrayWithCapacity:ftpHandles.count];
    
    
    
    __block NSUInteger number = 0;
    __block NSUInteger total = ftpHandles.count;
    

    
    for (NSString *handle in ftpHandles) {
        
        //Download file
        
        //Create model
        FlightInfo * info = [DataStore createEntityInMemoryStore:[FlightInfo entityName]]; //This object will not be saved or fetched.
        info.isOnlineValue = YES;
        
        //Parse flight plan (info) object
        if ([self flightInfoFromHandle:handle toModel:info]) {
            
            //and add to array
            [infos addObject:info];
            
        } else {
            
            total--; //failed to parse, don't add;
        }
        
        //return the completionblock when we're done:
        if (number == total) completionBlock(infos);
        
    }
    
}



- (void) downloadFlightForInfo:(FlightInfo *)info
{
    
    //We have a connection, so reset timeout timer
    [self resetTimer];
    
  
    //Start download:

    dispatch_async(dispatch_queue_create("Download_queue" , DISPATCH_QUEUE_SERIAL), ^{
        //Wait a while
        sleep(2);
   
        [self downloadFinishedFor:info];
    });


    
}



- (void) downloadFinishedFor:(FlightInfo *) currentDownload
{
    NSLog(@"Finished download: %@",currentDownload.uniqueID);
    
    
    
   
        //Tell user
        dispatch_async(dispatch_get_main_queue(), ^{
            
        //And all is now downloaded...
        //Parse on a background thread
        //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [self startConversionForInfo:currentDownload];
        //});
        });

    }
    




//Called when all downloading is done.
- (void) startConversionForInfo:(FlightInfo *) info
{
    
    
    
    //Create a new model object
    Flight * flight = [DataStore createEntity:[Flight entityName]];
    
    //Create a new FlightInfo in the "real" store and copy attributes
    FlightInfo * diskInfo = [DataStore createEntity:[FlightInfo entityName]];
    diskInfo.flightNbr = [info.flightNbr copy];
    diskInfo.lastEdit = [info.lastEdit copy];
    diskInfo.uniqueID = [info.uniqueID copy];
    diskInfo.isOnlineValue = NO;
    
    //Connect flight with info
    diskInfo.flight = flight;
    
        //Tell the controller a new flight is downloaded and available
        dispatch_async(dispatch_get_main_queue(), ^{
                   [self.controller downloadCompletedOfModel:flight];
               });

}



#pragma mark - Time Out connection


#if DEBUG
#define TIMEINTERVALSECONDSTOPPSINVALIDATION 60
#else
/* Invalidate onlinesection and FPS connection after 29 minutes */
#define TIMEINTERVALSECONDSTOPPSINVALIDATION 29*60
#endif

- (void) resetTimer
{
    //stop existing one
    if (self.timer != nil) {
        [self.timer invalidate];
        self.timer = nil;
    }
    
    //Start a new timer
    self.timer = [NSTimer scheduledTimerWithTimeInterval:TIMEINTERVALSECONDSTOPPSINVALIDATION
                                                  target:self
                                                selector:@selector(invalidateConnection)
                                                userInfo:nil
                                                 repeats:NO];
    
    
}

/* The connection is invalidated by the server after 30 minutes (PPS), do the same here: */
- (void) invalidateConnection
{
    [self.controller connectionLost:NO];
}

@end
