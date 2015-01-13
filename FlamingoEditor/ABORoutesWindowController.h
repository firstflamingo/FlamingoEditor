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
//  ABORoutesWindowController.h
//  FlamingoEditor
//
//  Created by Berend Schotanus on 01-03-12.
//

#import <Cocoa/Cocoa.h>

@class ABOAppDelegate, ATLDataController, ATLRoute, ATLSubRoute;

@interface ABORoutesWindowController : NSWindowController <NSTableViewDelegate, NSTableViewDataSource>

// Connecting to the environment
@property (nonatomic, readonly) ABOAppDelegate *appDelegate;
@property (weak) ATLDataController *dataController;
@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;

// Connecting the user interface:

// Menu
- (IBAction)connectRouteWithRouteItems:(id)sender;
- (IBAction)connectRoutesWithBuilder:(id)sender;
- (IBAction)connectSubroutesWithManager:(id)sender;
- (IBAction)connectSubroutesWithOperators:(id)sender;

// Routes box
@property (strong) IBOutlet NSArrayController *routesArrayController;
@property (nonatomic, readonly) NSArray *selectedRoutes;
@property (nonatomic, readonly) ATLRoute *selectedRoute;
- (IBAction)addRoute:(id)sender;
- (IBAction)removeBuilder:(id)sender;

// AddRoute panel
@property (strong) IBOutlet NSPanel *addRoutePanel;
@property (weak) IBOutlet NSComboBox *addRouteCountryBox;
@property (weak) IBOutlet NSTextField *addRouteCodeField;
@property (weak) IBOutlet NSTextField *addRouteFromField;
@property (weak) IBOutlet NSTextField *addRouteToField;
- (IBAction)confirmAddRoute:(id)sender;
- (IBAction)cancelAddRoute:(id)sender;

// Route Item column
@property (nonatomic, strong) NSArray *arrangedRoutePositions;

@property (weak) IBOutlet NSTableView *routeItemsTable;
@property (nonatomic, readonly) NSArray *selectedPositions;
- (IBAction)selectRoute:(id)sender;
- (IBAction)addRouteItems:(id)sender;
- (IBAction)removeSelectedRouteItems:(id)sender;
- (IBAction)addJunctions:(id)sender;
- (IBAction)updateItemPositioning:(id)sender;

// AddItem panel
@property (strong) IBOutlet NSPanel *addItemPanel;
@property (weak) IBOutlet NSMatrix *itemTypeChooser;
@property (weak) IBOutlet NSTextField *itemCodeField;
@property (weak) IBOutlet NSTextField *itemNameField;
@property (weak) IBOutlet NSTextField *itemPositionField;
@property (weak) IBOutlet NSSlider *itemPositionSlider;
- (IBAction)updateItemPosition:(id)sender;
- (IBAction)confirmAddItem:(id)sender;
- (IBAction)cancelAddItem:(id)sender;

// Subroutes box
@property (strong) IBOutlet NSArrayController *subroutesArrayController;
@property (nonatomic, readonly) NSArray *selectedSubroutes;
@property (nonatomic, readonly) ATLSubRoute *selectedSubroute;
@property (weak) IBOutlet NSDatePicker *subrouteFromPicker;
@property (weak) IBOutlet NSDatePicker *subrouteTillPicker;
- (IBAction)addSubroute:(id)sender;
- (IBAction)splitSubroute:(id)sender;
- (IBAction)removeInfraManager:(id)sender;

// Export Routes XML
- (IBAction)exportXMLFile:(id)sender;
- (NSString*)xmlString;

@end
