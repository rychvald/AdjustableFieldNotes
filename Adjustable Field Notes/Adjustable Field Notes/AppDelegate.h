//
//  AppDelegate.h
//  Adjustable Field Notes
//
//  Created by Marcel Stolz on 17.03.14.
//  Copyright (c) 2014 ___FULLUSERNAME___.
//

#import <UIKit/UIKit.h>
@class RecordingsHandler;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) RecordingsHandler *recordingsHandler;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
