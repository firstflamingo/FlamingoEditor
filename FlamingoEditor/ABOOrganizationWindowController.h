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
//  ABOOrganizationWindowController.h
//  FlamingoEditor
//
//  Created by Berend Schotanus on 03-03-12.
//

#import <Cocoa/Cocoa.h>

@class ABOAppDelegate, ATLDataController, ATLOrganization;

@interface ABOOrganizationWindowController : NSWindowController

// Connecting to the environment
@property (nonatomic, readonly) ABOAppDelegate *appDelegate;
@property (weak) ATLDataController *dataController;
@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;

// Organizations tableView
@property (strong) IBOutlet NSArrayController *organizationArrayController;
@property (nonatomic, readonly) NSArray *selectedOrganizations;
@property (nonatomic, readonly) ATLOrganization *selectedOrganization;

// Aliases tableView
@property (strong) IBOutlet NSArrayController *aliasesArrayController;
- (IBAction)deleteAlias:(id)sender;

// Export Organization XML
- (IBAction)exportXMLFile:(id)sender;
- (NSString*)xmlString;

@end
