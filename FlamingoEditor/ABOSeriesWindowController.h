//  Copyright (c) 2014-2015 First Flamingo Enterprise B.V.
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
//  ABOSeriesWindowController.h
//  FlamingoEditor
//
//  Created by Berend Schotanus on 27-06-14.
//

#import <Cocoa/Cocoa.h>

@class ATLDataController, ATLSeries;

@interface ABOSeriesWindowController : NSWindowController

// Connecting to the environment
@property (nonatomic, weak) ATLDataController *dataController;

// Interface outlets
@property (weak) IBOutlet NSArrayController *seriesArrayController;
@property (weak) IBOutlet NSArrayController *upMissionRulesController;
@property (weak) IBOutlet NSArrayController *downMissionRulesController;
@property (weak) IBOutlet NSTextField *upOffsetCorrectionField;
@property (weak) IBOutlet NSTextField *downOffsetCorrectionField;

@property (weak) IBOutlet NSTableView *upRulesTableView;
@property (weak) IBOutlet NSTableView *upPathTableView;
@property (weak) IBOutlet NSTableView *downRulesTableView;
@property (weak) IBOutlet NSTableView *downPathTableView;

// Actions from menu buttons
- (IBAction)correctUpOffset:(id)sender;
- (IBAction)correctDownOffset:(id)sender;

// Import Series
- (IBAction)importGTFS:(id)sender;

// Export Series XML
- (IBAction)exportXMLFile:(id)sender;
- (NSString*)xmlString;

@end
