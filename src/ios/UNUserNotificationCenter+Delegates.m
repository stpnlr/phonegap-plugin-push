//
//  UNUserNotificationCenter+Delegates.m
//  push
//
//  Created by Eric Fisher on 5/11/18.
//  Copyright © 2018 PhoneGap. All rights reserved.
//

#import "UNUserNotificationCenter+Delegates.h"
#import "AppDelegate.h"
@import ObjectiveC;

static char delegatesKey;

@implementation UNUserNotificationCenter (Delegates)

#pragma mark - Swizzle

+ (void)load
{
    // Exchange the setDelegate method
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(setDelegate:);
        SEL swizzledSelector = @selector(swizzledSetDelegate:);
        
        Method original = class_getInstanceMethod(class, originalSelector);
        Method swizzled = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL didAddMethod =
        class_addMethod(class,
                        originalSelector,
                        method_getImplementation(swizzled),
                        method_getTypeEncoding(swizzled));
        
        if (didAddMethod) {
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(original),
                                method_getTypeEncoding(original));
        } else {
            method_exchangeImplementations(original, swizzled);
        }
    });
}

- (void)swizzledSetDelegate:(id<UNUserNotificationCenterDelegate>)delegate
{
    if (self.delegate && self.delegate != self)
    {
        [self.delegates addObject:self.delegate];
    }
    
    // Only supports two delegates: one for this plugin and one for katzer/cordova-plugin-local-notifications
    if (self.delegates.count < 2)
    {
        [self.delegates addObject:delegate];
    }
    
    if (self.delegate != self)
    {
        // Because the methods are exchanged, this will call the original method
        [self swizzledSetDelegate:self];
    }
}


#pragma mark - Accessors

- (NSHashTable<id<UNUserNotificationCenterDelegate>> *)delegates
{
    NSHashTable<id<UNUserNotificationCenterDelegate>> *delegates = objc_getAssociatedObject(self, &delegatesKey);
    if (delegates == nil)
    {
        // Only supports two delegates: one for this plugin and one for katzer/cordova-plugin-local-notifications
        self.delegates = [NSHashTable weakObjectsHashTable];
    }
    
    return objc_getAssociatedObject(self, &delegatesKey);
}

- (void)setDelegates:(NSHashTable<id<UNUserNotificationCenterDelegate>> *)delegates
{
    objc_setAssociatedObject(self, &delegatesKey, delegates, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


#pragma mark - Public methods

- (id<UNUserNotificationCenterDelegate>)getDelegateForNotificationTrigger:(UNNotificationTrigger *)trigger
{
    BOOL isPushNotification = [trigger isKindOfClass:UNPushNotificationTrigger.class];
    
    NSPredicate *localPredicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        // katzer/cordova-plugin-local-notifications uses its own object as the UNUserNotificationCenterDelegate object
        return ![evaluatedObject isKindOfClass:AppDelegate.class];
    }];
    NSPredicate *pushPredicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        // This plugin uses the AppDelegate class as the UNUserNotificationCenterDelegate object
        return [evaluatedObject isKindOfClass:AppDelegate.class];
    }];
    
    // These will contain only one object
    NSSet<id<UNUserNotificationCenterDelegate>> *localDelegates = [self.delegates.setRepresentation filteredSetUsingPredicate:localPredicate];
    NSSet<id<UNUserNotificationCenterDelegate>> *pushDelegates = [self.delegates.setRepresentation filteredSetUsingPredicate:pushPredicate];
    
    return isPushNotification ? [pushDelegates anyObject] : [localDelegates anyObject];
}


#pragma mark - <UNUserNotificationCenterDelegate>

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler
{
    id<UNUserNotificationCenterDelegate> delegate = [self getDelegateForNotificationTrigger:notification.request.trigger];
    [delegate userNotificationCenter:center willPresentNotification:notification withCompletionHandler:completionHandler];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void(^)(void))completionHandler
{
    id<UNUserNotificationCenterDelegate> delegate = [self getDelegateForNotificationTrigger:response.notification.request.trigger];
    [delegate userNotificationCenter:center didReceiveNotificationResponse:response withCompletionHandler:completionHandler];
}


@end
