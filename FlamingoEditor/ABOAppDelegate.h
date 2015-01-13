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
//  ABOAppDelegate.h
//  FlamingoEditor
//
//  Created by Berend Schotanus on 01-03-12.
//

#import <Cocoa/Cocoa.h>
#import <CoreLocation/CoreLocation.h>

#import "ATLEntry.h"

@class ABORoutesWindowController, ABOLocationWindowController, ABOOrganizationWindowController, ABOServiceWindowController;
@class ABOSeriesWindowController;
@class ATLDataController, ABO_OSM_Converter;

@interface ABOAppDelegate : NSObject <NSApplicationDelegate>

// Connect to data source
@property (nonatomic, strong) ATLDataController *dataController;
@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;

// Managing windows
@property (nonatomic, strong) ABORoutesWindowController *routesWindowController;
- (IBAction)showRoutesWindow:(id)sender;
@property (nonatomic, strong) ABOLocationWindowController *locationWindowController;
- (IBAction)showLocationWindow:(id)sender;
@property (nonatomic, strong) ABOOrganizationWindowController *organisationWindowController;
- (IBAction)showOrganizationWindow:(id)sender;
@property (nonatomic, strong) ABOServiceWindowController *serviceWindowController;
- (IBAction)showServiceWindow:(id)sender;
@property (nonatomic, strong) ABOSeriesWindowController *seriesWindowController;
- (IBAction)showSeriesWindow:(id)sender;

// File management
@property (nonatomic, readonly) NSURL *applicationFilesDirectory;
@property (nonatomic, readonly) NSURL *imagesDirectory;
@property (nonatomic, readonly) NSURL *dataURL;
- (IBAction)saveDocument:(id)sender;
- (IBAction)importXMLFile:(id)sender;

// Connecting to treinenaapje
- (IBAction)clearCache:(id)sender;
- (IBAction)checkAccount:(id)sender;
- (IBAction)deleteAccount:(id)sender;

// Editing the map
- (IBAction)connectOrphanedItems:(id)sender;
- (IBAction)removeOrphanedPositions:(id)sender;
- (IBAction)removeClosedStations:(id)sender;
- (IBAction)kopieerPlaatjes:(id)sender;
- (IBAction)repositionRouteItems:(id)sender;

// Removing GTFS info
- (IBAction)removeAllMissionRules:(id)sender;

@end
