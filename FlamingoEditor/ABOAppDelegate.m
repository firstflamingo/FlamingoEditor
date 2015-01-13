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
//  ABOAppDelegate.m
//  FlamingoEditor
//
//  Created by Berend Schotanus on 01-03-12.
//

#import "ABOAppDelegate.h"
#import "ATLDataController.h"
#import "ABORoutesWindowController.h"
#import "ABOLocationWindowController.h"
#import "ABOOrganizationWindowController.h"
#import "ABOServiceWindowController.h"
#import "ABOSeriesWindowController.h"
#import "ABOAccount.h"

#import "ATLStation.h"
#import "ATLFileImporter.h"

#import "NSManagedObjectContext+FFEUtilities.h"

@interface ABOAppDelegate () <FFEDataControllerDelegate>

@end

@implementation ABOAppDelegate {
    NSError *_downloadError;
}

#pragma mark - Application lifecycle

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    srand((int)time(NULL)); // randomize random generator
    [self performSelector:@selector(showAllWindows) withObject:nil afterDelay:1.0];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    
    // Save changes in the application's managed object context before the application terminates.
    
    if (!_dataController) {
        return NSTerminateNow;
    }
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
        
        // Customize this code block to include application-specific recovery steps.              
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }
        
        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];
        
        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertFirstButtonReturn) {
            return NSTerminateCancel;
        }
    }
    return NSTerminateNow;
}

#pragma mark - Connect to data source

- (ATLDataController *)dataController
{
    if (!_dataController) {
        self.dataController = [[ATLDataController alloc] initWithStoreURL:self.dataURL];
        self.dataController.delegate = self;
        self.dataController.userClass = [ABOAccount class];
        self.dataController.imagesDirectory = self.imagesDirectory;
    }
    return _dataController;
}

- (NSManagedObjectContext *)managedObjectContext
{
    return self.dataController.managedObjectContext;
}

#pragma mark - Managing windows

- (void)showAllWindows
{
    [self showRoutesWindow:nil];
    [self showLocationWindow:nil];
    [self showOrganizationWindow:nil];
    [self showServiceWindow:nil];
    [self showSeriesWindow:nil];
}

- (ABORoutesWindowController *)routesWindowController
{
    if (!_routesWindowController) {
        self.routesWindowController = [[ABORoutesWindowController alloc] initWithWindowNibName:@"RoutesWindow"];
        _routesWindowController.dataController = self.dataController;
    }
    return _routesWindowController;
}

- (void)showRoutesWindow:(id)sender
{
    [self.routesWindowController showWindow:sender];
}

- (ABOLocationWindowController *)locationWindowController
{
    if (!_locationWindowController) {
        self.locationWindowController = [[ABOLocationWindowController alloc] initWithWindowNibName:@"LocationWindow"];
        _locationWindowController.dataController = self.dataController;
    }
    return _locationWindowController;
}

- (void)showLocationWindow:(id)sender
{
    [self.locationWindowController showWindow:sender];
}

- (ABOOrganizationWindowController *)organisationWindowController
{
    if (!_organisationWindowController) {
        self.organisationWindowController = [[ABOOrganizationWindowController alloc] initWithWindowNibName:@"OrganizationWindow"];
        _organisationWindowController.dataController = self.dataController;
    }
    return _organisationWindowController;
}

- (void)showOrganizationWindow:(id)sender
{
    [self.organisationWindowController showWindow:sender];
}

- (ABOServiceWindowController *)serviceWindowController
{
    if (!_serviceWindowController) {
        self.serviceWindowController = [[ABOServiceWindowController alloc] initWithWindowNibName:@"ServiceWindow"];
        _serviceWindowController.dataController = self.dataController;
    }
    return _serviceWindowController;
}

- (void)showServiceWindow:(id)sender
{
    [self.serviceWindowController showWindow:sender];
}

- (ABOSeriesWindowController *)seriesWindowController
{
    if (!_seriesWindowController) {
        self.seriesWindowController = [[ABOSeriesWindowController alloc] initWithWindowNibName:@"SeriesWindow"];
        _seriesWindowController.dataController = self.dataController;
    }
    return _seriesWindowController;
}

- (void)showSeriesWindow:(id)sender
{
    [self.seriesWindowController showWindow:sender];
}

#pragma mark - File management

- (NSURL *)applicationFilesDirectory {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *library = [[fileManager URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *directory = [library URLByAppendingPathComponent:@"FlamingoEditor"];
    if (![fileManager fileExistsAtPath:[directory path]]) {
        [fileManager createDirectoryAtPath:[directory path] withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    return directory;
}

- (NSURL *)imagesDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *directory = [self.applicationFilesDirectory URLByAppendingPathComponent:@"images"];
    if (![fileManager fileExistsAtPath:[directory path]]) {
        [fileManager createDirectoryAtPath:[directory path] withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    return directory;
}

- (NSURL *)dataURL
{
#ifdef TESTING_ENVIRONMENT
    NSLog(@"Local sync atlas");
    return [self.applicationFilesDirectory URLByAppendingPathComponent:@"local_sync_d2015_1.atlas"];
#else
    NSLog(@"Server sync atlas");
    return [self.applicationFilesDirectory URLByAppendingPathComponent:@"server_sync_d2015_1.atlas"];
#endif
}

- (void)saveDocument:(id)sender
{
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
        NSLog(@"Error while saving: %@ - %@", error, [error localizedDescription]);
    } else {
        NSLog(@"Document saved");
    }
}

- (void)importXMLFile:(id)sender
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection:NO];
    [panel setAllowedFileTypes:@[@"xml"]];
    [panel beginWithCompletionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            ATLFileImporter *importer = [ATLFileImporter new];
            [importer importContentsOfURL:panel.URL intoManagedObjectContext:self.dataController.managedObjectContext];
        }
    }];
}

#pragma mark - ATLImageSource method

- (NSImage *)imageNamed:(NSString *)name
{
    NSURL *imageURL = [self.imagesDirectory URLByAppendingPathComponent:name];
    if ([[NSFileManager defaultManager] fileExistsAtPath:imageURL.path]) {
        return [[NSImage alloc] initWithContentsOfURL:imageURL];
    }
    return nil;
}

#pragma mark - Editing the map

- (void)connectOrphanedItems:(id)sender
{
    for (ATLLocation *item in [self.dataController routeItemsWithConnections:0]) {
        NSLog(@"item : %@", [(NSManagedObject*)item valueForKey:@"name"]);
        [self.dataController searchAndAddRoutesForItem:item];
    }
}

- (void)removeOrphanedPositions:(id)sender
{
    NSArray *positions = [self.dataController orphanedPositions];
    for (NSManagedObject *position in positions) {
        NSLog(@"found route: %@ item: %@", [position valueForKey:@"route"], [position valueForKey:@"item"]);
        [self.managedObjectContext deleteObject:position];
    }
}

- (void)removeClosedStations:(id)sender
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ATLStation"];
	[request setPredicate:[NSPredicate predicateWithFormat:@"closed < %@", [NSDate date]]];
	NSArray *stations = [self.managedObjectContext executeFetchRequest:request error:NULL];
    for (NSManagedObject *station in stations) {
        NSLog(@"Remove station: %@", [station valueForKey:@"name"]);
//        [self.managedObjectContext deleteObject:station];
    }
}

- (void)kopieerPlaatjes:(id)sender
{
    for (NSManagedObject *station in [self.managedObjectContext allObjectsOfClass:[ATLStation class]]) {
        NSString *fileName = [station valueForKey:@"imageName"];
        if (!fileName) {
            NSLog(@"missing: Station %@", [station valueForKey:@"name"]);
        }
    }
}

- (void)repositionRouteItems:(id)sender
{
    [self.dataController repositionRouteItems];
}

- (void)removeAllMissionRules:(id)sender
{
    [self.dataController removeAllMissionRules];
}

#pragma mark - Connecting to treinenaapje

- (void)clearCache:(id)sender
{
    [self.dataController.remoteSession resetWithCompletionHandler:^{}];
}

- (void)checkAccount:(id)sender
{
    [self.dataController checkAccount];
}

- (void)deleteAccount:(id)sender
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Delete current account?"];
    [alert addButtonWithTitle:@"OK"];
    [alert addButtonWithTitle:@"Cancel"];
    NSInteger answer = [alert runModal];
    if (answer == NSAlertFirstButtonReturn) {
        [self.dataController resetAccount];
    }
}

- (void)showAlertWithTitle:(NSString*)title explanation:(NSString*)explanation
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:title];
    [alert setInformativeText:explanation];
    [alert addButtonWithTitle:@"OK"];
    [alert runModal];
}

#pragma mark FFEDataControllerDelegate methods

- (void)downloadsStartedByDataController:(FFEDataController *)controller
{
    _downloadError = nil;
}

- (void)downloadsEndedByDataController:(FFEDataController *)controller
{
}

- (void)dataController:(FFEDataController *)controller downloadFailedWithError:(NSError *)error
{
    _downloadError = error;
    [self showAlertWithTitle:@"Treinenaapje" explanation:error.localizedDescription];
}

@end
