//
//  UNUserNotificationCenter+Delegates.h
//  push
//
//  Created by Eric Fisher on 5/11/18.
//  Copyright © 2018 PhoneGap. All rights reserved.
//

@import UserNotifications;

@interface UNUserNotificationCenter (Delegates) <UNUserNotificationCenterDelegate>

/*!
 *  @brief Add up to two delegates to observe UNUserNotificationCenter events. One for push notifications, and one for local notifications.
 *
 *  This property is added to enable support for this plugin to work in parallel with katzer/cordova-plugin-local-notifications. When receiving events related
 *  to a push notification, the UNUserNotificationCenter will call this plugin's UNUserNotificationCenterDelegate methods. When receiving events related
 *  to a local notification, the UNUserNotificationCenter will call katzer/cordova-plugin-local-notifications's UNUserNotificationCenterDelegate methods.
 *
 *  @warning This has only been tested with katzer/cordova-plugin-local-notifications@0.9.0-beta.2.
 *
 */
@property (nonatomic, retain) NSHashTable<id<UNUserNotificationCenterDelegate>> *delegates;

/*!
 *  @brief Always set self as the delegate, but add up to two other objects, one for this plugin and one for katzer/cordova-plugin-local-notifications.
 *
 *  This method will set this object as its own delegate. Subsequently it will notify the appropriate delegate in the delegates property when it receives its
 *  own delegate events. The setDelegate method supports only two delegates, so this can only be used with exactly one other plugin that implements the
 *  UNUserNotificationCenter delegate methods.
 *
 *  @warning This has only been tested with katzer/cordova-plugin-local-notifications@0.9.0-beta.2.
 *
 */
- (void)swizzledSetDelegate:(id<UNUserNotificationCenterDelegate>)delegate;


/*!
 *  @brief Returns the appropriate delegate based on whether or not the trigger is a UNPushNotificationTrigger.
 *
 *  @return This plugin's UNUserNotificationCenterDelegate if the trigger is a UNPushNotificationTrigger. Otherwise it will return
 *  katzer/cordova-plugin-local-notifications's UNUserNotificationCenterDelegate.
 *
 *  @warning This has only been tested with katzer/cordova-plugin-local-notifications@0.9.0-beta.2.
 *
 */
- (id<UNUserNotificationCenterDelegate>)getDelegateForNotificationTrigger:(UNNotificationTrigger *)trigger;

@end
