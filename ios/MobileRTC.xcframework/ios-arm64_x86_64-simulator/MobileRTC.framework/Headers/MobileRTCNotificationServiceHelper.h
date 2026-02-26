//
//  MobileRTCZpnsHelper.h
//  MobileRTC
//
//  Created by Zoom on 2022/11/16.
//  Copyright © Zoom Communications, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MobileRTC/MobileRTCConstants.h>
#import <MobileRTC/MobileRTCInMeetingDeviceInfo.h>
#import <MobileRTC/MobileRTCPresenceHelper.h>

/*!
enum MobileRTCTransferMeetingMode
@brief Type of transfer meeting mode.
Here are more detailed structural descriptions.
*/
typedef NS_ENUM(NSInteger, MobileRTCTransferMeetingMode) {
    MobileRTCTransferMeetingMode_None = 0,  ///<For initialization.
    MobileRTCTransferMeetingMode_Transfer,  ///<Try to transfer meeting to current device.
    MobileRTCTransferMeetingMode_Companoin, ///<Try to join meeting with companion mode.If the meeting is successfully joined, both video and audio will be unavailable.
};


@interface MobileRTCTransferMeetingHandler : NSObject

/*
@brief Get the mode of transfer meeting.
@return The mode of the transfer meeting. For more details, see \link MobileRTCTransferMeetingMode \endlink enum.
*/
@property(nonatomic, assign, readonly) MobileRTCTransferMeetingMode mode;
/*
#brief Determine if transfer meeting or join meeting in companion mode success.
#return True indicates transfer meeting or join meeting in companion mode success.
 */
@property(nonatomic, assign, readonly) BOOL isSuccess;
/**
@brief Try to leave companion mode and rejoining the meeting in normal mode.
@return If the function succeeds, the return value is MobileRTCSDKError_Success. Otherwise failed. To get extended error information, see \link MobileRTCSDKError \endlink enum.
 */
- (MobileRTCSDKError)leaveCompanionToJoinMeeting;

@end

@protocol MobileRTCNotificationServiceHelperDelegate <NSObject>
@optional

/*!
 @brief Callback event that the device for users to attend the meeting has changed.
 @warning If the user uses -[MobileRTCAuthService registerNotificationService:] interface to connect to the service,they can't get in this callback webinar meeting list.
 @param deviceList A list of meeting info with active meetings.
 */
- (void)onMeetingDeviceListChanged:(NSArray<MobileRTCInMeetingDeviceInfo*>*_Nullable)deviceList;

/*!
 @brief Transfer meeting status changed callback.
 @param bSuccess The result of transfer meeting.
 */
- (void)onTransferMeetingStatus:(BOOL)bSuccess DEPRECATED_MSG_ATTRIBUTE("Please use onTransferMeetinghandler instead");
/*!
 @brief Transfer meeting status changed callback.
 @param handler The result of transfer meeting.
 */
- (void)onTransferMeetingResult:(MobileRTCTransferMeetingHandler *_Nullable)handler;

@end

@interface MobileRTCNotificationServiceHelper : NSObject
/*!
 Set the delegate of access token service.
 */
@property (assign, nonatomic) id<MobileRTCNotificationServiceHelperDelegate> _Nullable delegate;

/*!
 @brief Determine whether the transfer meeting feature is enabled.
 */
- (BOOL)isTransferMeetingEnabled;

/*!
 @brief Determine whether the presence feature is enabled.
 */
- (BOOL)isPresenceFeatureEnabled;
/*!
 @brief Try to transfer meeting to current device.
 @param index Specifies the index, see [MobileRTCInMeetingDeviceInfo].
 @return If the function succeeds, the return value is MobileRTCSDKError_Success.
 Otherwise failed. To get extended error information, see [MobileRTCSDKError] enum.
 */
- (MobileRTCSDKError)transferMeeting:(NSInteger)index  DEPRECATED_MSG_ATTRIBUTE("Please use -[MobileRTCNotificationServiceHelper transferMeeting:mode:] instead");

/*!
 @brief Try to transfer meeting to current device.
 @param meetingId Specifies the index, see [MobileRTCInMeetingDeviceInfo].
 @return If the function succeeds, the return value is MobileRTCSDKError_Success.
 Otherwise failed. To get extended error information, see [MobileRTCSDKError] enum.
 */
- (MobileRTCSDKError)transferMeeting:(NSString * _Nullable)meetingId mode:(MobileRTCTransferMeetingMode)mode;

/*!
 @brief Get presence interface helper.
 @return If the function succeeds, the return value is a instance of MobileRTCPresenceHelper, Otherwise, the function returns NULL.
 */
- (MobileRTCPresenceHelper *_Nullable)getPresenceHelper;

@end

