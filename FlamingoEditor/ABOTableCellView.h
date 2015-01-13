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
//  ABOTableCellView.h
//  FlamingoEditor
//
//  Created by Berend Schotanus on 09-08-12.
//

#import <Cocoa/Cocoa.h>

@protocol ABOTableCellDelegate;


@interface ABOTableCellView : NSTableCellView

@property (nonatomic, assign) int pointIndex;
@property (nonatomic, assign) BOOL upDirection;
@property (weak) id <ABOTableCellDelegate> delegate;
@property (weak) IBOutlet NSTextField *kmTextField;
@property (weak) IBOutlet NSTextField *timeField;
@property (weak) IBOutlet NSTextField *codeField;
- (IBAction)updateTime:(id)sender;
- (void)updateArrival:(int16_t)arrival departure:(int16_t)departure;

@end

@protocol ABOTableCellDelegate <NSObject>

- (void)updateUpArrival:(int16_t)arrival departure:(int16_t)departure forPointIndex:(int)pointIndex;
- (void)updateDownArrival:(int16_t)arrival departure:(int16_t)departure forPointIndex:(int)pointIndex;

@end