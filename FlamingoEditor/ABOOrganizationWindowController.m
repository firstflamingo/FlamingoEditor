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
//  ABOOrganizationWindowController.m
//  FlamingoEditor
//
//  Created by Berend Schotanus on 03-03-12.
//

#import "ABOOrganizationWindowController.h"
#import "ABOAppDelegate.h"
#import "ATLDataController.h"
#import "ATLOrganization.h"

#import "NSManagedObjectContext+FFEUtilities.h"

@implementation ABOOrganizationWindowController

#pragma mark - Connecting to the environment

- (ABOAppDelegate *)appDelegate
{
    return (ABOAppDelegate*)[[NSApplication sharedApplication] delegate];
}

- (NSManagedObjectContext *)managedObjectContext
{
    return self.dataController.managedObjectContext;
}

#pragma mark - Organization tableView

- (NSArray*)selectedOrganizations
{
    return [self.organizationArrayController selectedObjects];
}

- (ATLOrganization*)selectedOrganization
{
    NSArray *theOrganizations = self.selectedOrganizations;
    if ([theOrganizations count] == 1) {
        return theOrganizations[0];
    }
    return nil;
}

#pragma mark - Aliases tableView

- (IBAction)deleteAlias:(id)sender {
    NSArray *selectedObjects = [self.aliasesArrayController selectedObjects];
    for (NSManagedObject *alias in selectedObjects) {
        [self.managedObjectContext deleteObject:alias];
    }
}

#pragma mark Export Organization XML

- (void)exportXMLFile:(id)sender
{
    NSSavePanel *panel = [NSSavePanel savePanel];
    [panel setAllowedFileTypes:[NSArray arrayWithObject:@"xml"]];
    [panel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            [[self xmlString] writeToURL:[panel URL]
                              atomically:NO
                                encoding:NSUTF8StringEncoding
                                   error:NULL];
            
        }
    }];
}

- (NSString *)xmlString
{
    NSMutableString *output = [NSMutableString stringWithCapacity:1000];
    [output appendString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"];
    [output appendString:@"<organizations version=\"1.0\">\n"];
    for (ATLOrganization *organization in self.organizationArrayController.arrangedObjects) {
        [output appendString:organization.xmlString];
    }
    [output appendString:@"</organizations>\n"];
    return output;
}


@end
