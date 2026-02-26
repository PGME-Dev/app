//
//  MobileRTCMeetingService+Video.h
//  MobileRTC
//
//  Created by Zoom Communications on 2018/6/6.
//  Copyright © Zoom Communications, Inc. All rights reserved.
//

#import <MobileRTC/MobileRTC.h>
#import <AVFoundation/AVFoundation.h>

/**
 @brief  * Video Preference Setting
 * When setting custom modes, the developer provides the maximum and minimum frame rates.
 * If the current bandwidth cannot maintain the minimum frame rate, the video system will drop to the next lower resolution.
 * The default maximum and minimum frame rates for other modes are 0.
 */

@interface MobileRTCVideoPreferenceSetting : NSObject
/**
 @brief Preferred video mode. 
 @note 0: Balance mode; 1: Smoothness mode; 2: Sharpness mode; 3: Custom mode
 */
@property (nonatomic, assign) MobileRTCVideoPreferenceMode mode;

/**
 @brief Minimum frame rate, default is 0, minimumFrameRate should be less than maximumFrameRate
 @note range: from 0 to 30. Out of range for frame rate will use default frame rate of Zoom.
 */
@property (nonatomic, assign) NSUInteger minimumFrameRate;

/**
 @brief Maximum frame rate, default is 0, , maximumFrameRate should be less or equal than 30
 @note range: from 0 to 30. Out of range for frame rate will use default frame rate of Zoom.
 */
@property (nonatomic, assign) NSUInteger maximumFrameRate;

@end

@interface MobileRTCCameraDevice : NSObject
@property (nonatomic, readonly, nullable, copy) NSString* deviceId;         /// camera device ID.
@property (nonatomic, readonly, nullable, copy) NSString* deviceName;       /// camera name.
@property (nonatomic, readonly, assign)         BOOL isSelectDevice;        /// is current use.
@property (nonatomic, readonly, assign)         AVCaptureDevicePosition position;   /// camera position.
@property (nonatomic, readonly, nullable, copy) AVCaptureDeviceType deviceType; /// camera device type.
@property (nonatomic, readonly, assign)         CGFloat maxZoomFactor;  // camera maximum zoom factor. Maximum supported is 10.
@property (nonatomic, readonly, assign)         CGFloat videoZoomFactorUpscaleThreshold;/// the maximum optical zoom factor.

@end


@interface MobileRTCMeetingService (Video)

/*!
 @brief Query if the user is sending video.  
 @return YES means sending, otherwise not.
 */
- (BOOL)isSendingMyVideo;

/*!
 @brief Query if user can unmute his video himself.
 @return YES means able, otherwise not.
 */
- (BOOL)canUnmuteMyVideo;

/*!
 @brief Set to mute video of the current user.
 @param mute YES means to mute video of the current user, otherwise not.
 @return The result of operation.
 */
- (MobileRTCSDKError)muteMyVideo:(BOOL)mute;

/*!
 @brief Rotate my video.
 @return the result of it.
 */
- (BOOL)rotateMyVideo:(UIDeviceOrientation)rotation;

/*!
 @brief Query if user's video is spotlighted. Once the user's video is spotlighted, it will show only the specified video in the meeting instead of active user's.  
 @param userId The ID of user in meeting.
 @return YES means spotlighted, otherwise not.
 */
- (BOOL)isUserSpotlighted:(NSUInteger)userId;

/*!
 @brief Set whether to spotlight user's video.
 @param on YES means to spotlight user's video; NO means that spotlight user's video will be canceled.
 @param userId The ID of user whose video will be spotlighted in the meeting.
 @return YES means that the method is called successfully, otherwise not.
 @warning Only meeting host/cohost can run the function, and user spotlighted should not be the host himself.
 */
- (BOOL)spotlightVideo:(BOOL)on withUser:(NSUInteger)userId;

/*!
 @brief Un-spotlight all the user.
 @return Yes means follow, otherwise not.
 @warning Only meeting host/cohost can run the function, and user spotlighted should not be the host himself.
 */
- (BOOL)unSpotlightAllVideos;

/*!
 @brief get spotlight user list.
 @return userId array.
 */
- (NSArray <NSNumber *>* _Nullable)getSpotLightedVideoUserList;

/*!
 @brief Query if the user's video is pinned. 
 @param userId The ID of user whose video will be pinned in the meeting.
 @return YES means that the user's video is pinned, otherwise not.
 @warning The function is only for Zoom UI.
 */
- (BOOL)isUserPinned:(NSUInteger)userId;

/*!
 @brief Set whether to pin user's video or not. 
 @param on YES means to pin user's video, otherwise not. 
 @param userId The ID of user whose video will be pinned.
 @return YES means that the method is called successfully, otherwise not.
 @warning The function is only for Zoom UI.
 */
- (BOOL)pinVideo:(BOOL)on withUser:(NSUInteger)userId;

/*!
 @brief Query if user's video is being sent.
 @param userID The ID of user whose video will be sent in meeting
 @return YES means that the video is being sent, otherwise not.
 */
- (BOOL)isUserVideoSending:(NSUInteger)userID;

/*!
 @brief Set to stop user's video.
 @param userID The ID of other users except the host in the meeting. 
 @return YES means that the method is called successfully, otherwise not.
 @warning Only host can run the function in the meeting.
 */
- (BOOL)stopUserVideo:(NSUInteger)userID;

/*!
 @brief Host can use this function to demand user to start video.
 @param userID The ID of user who needs to turn on video in meeting.
 @return YES means that the method is called successfully, otherwise not.
 @warning Only host can run the function in the meeting.
 */
- (BOOL)askUserStartVideo:(NSUInteger)userID;

/*!
 @brief Get the size of user's video.
 @param userID The ID of user in the meeting. userID should be 0 when not in meeting.
 @return The size of user's video.
 */
- (CGSize)getUserVideoSize:(NSUInteger)userID;

#pragma mark Camera Related
/*!
 @brief Query if user is using back camera.
 @return YES means using Back camera, otherwise not.
 */
- (BOOL)isBackCamera;

/*!
 @brief Set to Switch the camera of the current user in local device.
 @return The result of operation. 
 */
- (MobileRTCCameraError)switchMyCamera;

/*!
 @brief Get the camera device list.
 @return The list of cameras.
 @warning Only iOS 17.0 or above and iPad device can get the external camera devices.
 */
- (NSArray <MobileRTCCameraDevice *>* _Nullable)getCameraDeviceList;

/*!
 @brief Switch camera by camera ID.
 @param cameraId The target camera ID.
 @return Yes means it successfully switched camera, otherwise not.
 */
- (BOOL)switchCamera:(NSString * _Nullable)cameraId;

/*!
 @brief Get the current camera device in use.
 @return return the current camra device in use.
 */
- (MobileRTCCameraDevice * _Nullable)getSelectedCamera;

/*!
 @brief Zoom the camera in or out.
 @return Yes means zooming succeeded, otherwise if failed.
 @warning Please refer to the MobileRTCCameraDevice class. The value of maxZoomFactor means the camera's maximum zoom factor. The value of videoZoomFactorUpscaleThreshold means the maximum scale of optical zoom factor.
 */
- (BOOL)zoomCamera:(CGFloat)velocity;

/**
 @brief Set the video quality preference that automatically adjust user's video to prioritize frame rate v.s. resolution based on the current bandwidth available.
 @param preferenceSetting  Specifies the video quality preference. For more information, see [MobileRTCVideoPreferenceSetting].
 @return If the function succeeds, it will return Errors_Success.
 @warning This only supports for the raw data render model.
 */
- (MobileRTCSDKError)setVideoQualityPreference:(MobileRTCVideoPreferenceSetting * _Nullable)preferenceSetting;

/*!
 @brief Qurry if the account support follow host video order feature or not.
 @return Yes means support, otherwise not.
 */
- (BOOL)isSupportFollowHostVideoOrder;

/*!
 @brief Qurry if follow host video order or not currently.
 @return Yes means follow, otherwise not.
 */
- (BOOL)isFollowHostVideoOrderOn;

/*!
 @brief get follow host video order array currently.
 @return userId array.
 */
- (NSArray <NSNumber *>* _Nullable)getVideoOrderList;

/*!
 @brief Stop the incoming video.
 @param enable YES indicates to enable to stop incoming video.
 @return If the function succeeds, the return value is MobileRTCSDKError_Success.
 Otherwise the function fails and returns an error. To get extended error information, see [MobileRTCSDKError] enum.
 */
- (MobileRTCSDKError)stopIncomingVideo:(BOOL)enable;

/*!
 @brief Determine if the incoming video is stopped.
 @return YES indicates to the incoming video is stopped.
 */
- (BOOL)isIncomingVideoStoped;

/*!
 @brief Determine if the incoming video is supported.
 @return YES indicates to the incoming video is supported.
 */
- (BOOL)isStopIncomingVideoSupported;

/*!
 @brief Enable my video auto-framing.
 @param mode the auto-framing mode.
 @param setting the auto-framing parameter.
 @return If the function succeeds, the return value is MobileRTCSDKError_Success.
 */
- (MobileRTCSDKError)enableVideoAutoFraming:(MobileRTCAutoFramingParameter * _Nullable)setting forMode:(MobileRTCAutoFramingMode)mode;

/*!
 @brief Stop video auto-framing.
 @return If the function succeeds, the return value is MobileRTCSDKError_Success.
 */
- (MobileRTCSDKError)disableVideoAutoFraming;

/*!
 @brief Determine whether auto-framing is enabled.
 @return YES indicates enabled. NO not.
 */
- (BOOL)isVideoAutoFramingEnabled;

/*!
 @brief Get current mode of auto-framing.
 @return the current auto-framing mode.
 */
- (MobileRTCAutoFramingMode)getVideoAutoFramingMode;

/*!
 @brief Set the mode of auto-framing when auto-framing is enabled.
 @param mode the auto-framing mode.
 @return If the function succeeds, the return value is MobileRTCSDKError_Success.
 */
- (MobileRTCSDKError)setVideoAutoFramingMode:(MobileRTCAutoFramingMode)mode;

/*!
 @brief Set the mode of auto-framing when auto-framing is enabled.
 @param ratio the zoom in ratio of auto-framing, valid range of ratio:
        a. mode is "MobileRTCAutoFramingMode_CenterCoordinates", 1~10.
        b. mode is "MobileRTCAutoFramingMode_FaceRecognition", 0.1~10
 @return If the function succeeds, the return value is MobileRTCSDKError_Success.
 */
- (MobileRTCSDKError)setVideoAutoFramingRatio:(CGFloat)ratio;

/*!
 @brief Set the fail strategy of face recognition when auto-framing is enabled(mode is "MobileRTCAutoFramingMode_FaceRecognition").
 @param  strategy the fail strategy of face recognition.
 @return  If the function succeeds, the return value is MobileRTCSDKError_Success.
 */
- (MobileRTCSDKError)setFaceRecognitionFailStrategy:(MobileRTCFaceRecognitionFailStrategy)strategy;

/*!
 @brief Get the setting of auto-framing.
 @param mode the auto-framing mode.
 @return the auto-framing parameter of the specify mode or nil.
 */
- (MobileRTCAutoFramingParameter * _Nullable)getVideoAutoFramingSetting:(MobileRTCAutoFramingMode)mode;

/*!
 @brief Determine if alpha channel mode can be enabled.
 @return YES means it can be enabled. Otherwise NO.  Only for host call.
 @warning Only host can enable alpha channel.
 */
- (BOOL)canEnableAlphaChannelMode;

/*!
 @brief Enable or disable alpha channel mode.
 @param enable YES indicates to enable alpha channel mode., Otherwise, disable it.
 @return If the function succeeds, the return value is MobileRTCSDKError_Success. Otherwise failed.
 @warning Only host can enable alpha channel.
 @warning  This function will enable the meeting alpha channel, even if the current iOS device not support alpha channel.
 @warning for iOS device should be iPhone 8/ 8 plus X or above or be iPad Pro 9.7 above, OS should be iOS 11 or above
 */
- (MobileRTCSDKError)enableAlphaChannelMode:(BOOL)enable;

/*!
 @brief Determine if alpha channel mode is enabled.
 @return YES indicates is in alpha channel mode. Otherwise NO.
 */
- (BOOL)isAlphaChannelModeEnabled;

@end
