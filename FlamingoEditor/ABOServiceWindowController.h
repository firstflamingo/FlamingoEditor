//  Copyright (c) 2012-2015 First Flamingo Enterprise B.V.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//  ABOServiceWindowController.h
//  FlamingoEditor
//
//  Created by Berend Schotanus on 10-08-12.
//

#import <Cocoa/Cocoa.h>
#import "ABOTableCellView.h"

@class ABOAppDelegate, ATLDataController, ATLSeries, ATLSeriesRef, ATLService, ATLStation, ATLScheduledPoint;

@interface ABOServiceWindowController : NSWindowController
<NSTableViewDelegate, NSTableViewDataSource, ABOTableCellDelegate>

// Connecting to the environment
@property (nonatomic, readonly) ABOAppDelegate *appDelegate;
@property (weak) ATLDataController *dataController;
@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;

// Services table
@property (strong) IBOutlet NSArrayController *servicesArrayController;
@property (nonatomic, readonly) ATLService *selectedService;
- (IBAction)linkOperator:(id)sender;
- (IBAction)linkGrantor:(id)sender;
- (IBAction)connectServices:(id)sender;
- (IBAction)fillSchedule:(id)sender;
- (IBAction)clearSchedule:(id)sender;

// Route points table
@property (nonatomic, strong) NSArray *upServicePoints, *downServicePoints;
@property (nonatomic, strong) NSArray *previousConnections, *nextConnections;
@property (weak) IBOutlet NSTableView *upPointsTableView;
@property (weak) IBOutlet NSTableView *downPointsTableView;
- (IBAction)removeRoutePoint:(id)sender;

// Service rules table
@property (weak) IBOutlet NSTableView *upRulesTableView;
@property (weak) IBOutlet NSTableView *downRulesTableView;

// SeriesRef table
@property (strong) IBOutlet NSArrayController *seriesRefArrayController;
@property (nonatomic, readonly) ATLSeriesRef *selectedReference;
- (IBAction)linkSeriesRef:(id)sender;

// Export Series XML
- (IBAction)exportXMLFile:(id)sender;
- (NSString*)xmlString;

@end
