//
//  MobileRTCMeetingService+LiveTranscription.h
//  MobileRTC
//
//  Created by Zoom Communications on 2021/10/27.
//  Copyright © Zoom Communications, Inc. All rights reserved.
//

#import <MobileRTC/MobileRTC.h>
#import <MobileRTC/MobileRTCLiveTranscriptionLanguage.h>

@interface MobileRTCLiveTranscriptionMessageInfo : NSObject
/*!
@brief message id of transcription message
*/
@property (nonatomic, copy)NSString * _Nonnull messageID;
/*!
@brief speaker id of transcription message
*/
@property (nonatomic, assign)NSInteger speakerID;
/*!
@brief speak name  of transcription message
*/
@property (nonatomic, copy)NSString * _Nullable speakerName;
/*!
@brief message content  of transcription message
*/
@property (nonatomic, copy)NSString * _Nullable messageContent;
/*!
@brief time stamp  of transcription message
*/
@property (nonatomic, assign)NSInteger timeStamp;
/*!
@brief message tpye  of transcription message
*/
@property (nonatomic, assign)MobileRTCLiveTranscriptionOperationType messageType;

@end

/**
* The helper to handle the requested of start captions.
* When isRequestTranslationOn is YES, use {@link -[MobileRTCCaptionsControlOnHandler approveStartCaptionsRequest ]} to approve start captions request.
* When isRequestTranslationOn is NO,  use {@link -[MobileRTCCaptionsControlOnHandler approveStartCaptionsRequest:(NSInteger)languageId] } to approve start captions request.
*/

@interface MobileRTCCaptionsControlHandler : NSObject

/**
 * Decline the request  start captions.
 * @return If the function succeeds, the return value is MobileRTCSDKError_Success. Otherwise fails. For more details, see {@link MobileRTCSDKError}.
 */
-(MobileRTCSDKError)deny;

/**
 * @return The user ID of the user who send request to start captions.
 */
-(NSUInteger)getSenderUserId;

/**
 * @return YES means request to start captions with translation on. Otherwise NO.
 */
-(BOOL)isRequestTranslationOn;

@end

@interface MobileRTCCaptionsControlOnHandler : MobileRTCCaptionsControlHandler
/**
 * Approve the start captions request.
 * @return If the function succeeds, the return value is MobileRTCSDKError_Success. Otherwise fails. For more details, see {@link MobileRTCSDKError}.
 */
-(MobileRTCSDKError)approveStartCaptionsRequest;

@end


@interface MobileRTCCaptionsControlOffHandler : MobileRTCCaptionsControlHandler
/**
 * Approve the start captions request.
 * @param languageId The language to be set for all participants in meeting.
 * @return If the function succeeds, the return value is MobileRTCSDKError_Success. Otherwise fails. For more details, see {@link MobileRTCSDKError}.
 */
-(MobileRTCSDKError)approveStartCaptionsRequest:(NSInteger)languageId;
@end

@interface MobileRTCMeetingService (LiveTranscription)

/*!
 @brief Query if the current meeting is supported closed caption.
 @return YES means that the current meeting is supported close caption.
 */
- (BOOL)isMeetingSupportCC;

/*!
 @brief Query if the user can disable captions.
 @return YES means that the host can disable captions.
 */
- (BOOL)canDisableCaptions;

/*!
 @brief Enable or disable captions.
 @param bEnable YES means that captions are enabled.  NO means that captions are disabled.
 @return If the function succeeds, the return value is MobileRTCSDKError_Success.  Otherwise the function  returns a calling error. For more details, see \link MobileRTCSDKError \endlink enum.
 */
- (MobileRTCSDKError)enableCaptions:(BOOL)bEnable;

/*!
 @brief Query if the captions enabled.
 @return YES  means that captions are enabled.
*/
- (BOOL)isCaptionsEnabled;

/**
 @brief Determine whether users can request to start captions.
 @return True indicates users can request to start captions. Otherwise False.
  */
- (BOOL)isSupportRequestCaptions;

/**
 * @brief  Request the host to start captions. If the host approves your request, you receive the callback {@link -[MobileRTCMeetingServiceDelegate onStartCaptionsRequestApproved]},and you should start captions or translation there.
 * @param enableTranslation True indicates to enable translation at the same time.
 * @return If the function succeeds, the return value is SDKERR_SUCCESS. Otherwise fails. For more details, see {@link MobileRTCSDKError}.
 */
- (MobileRTCSDKError)requestToStartCaptions:(BOOL)enableTranslation;

/**
 @brief Determine if translation is available when users request to start captions.
 @return True indicates translation is available when users request to start captions. Otherwise False.
 */
- (BOOL)isSupportTranslationWhenRequestToStartCaptions;

/*!
 @brief Query if the user is can be assigned to send closed caption.
 @param userId the user id.
 @return TRUE means that the user can be assigned to send closed caption.
 */
- (BOOL)canBeAssignedToSendCC:(NSUInteger)userId;

/*!
 @brief Assign the user privilege to send closed caption.
 @param userId the user id.
 @return If the function succeeds, the return value is YES. Otherwise failed.
 */
- (BOOL)assignCCPrivilege:(NSUInteger)userId;

/*!
 @brief WithDraw the user privilege to send closed caption.
 @param userId the user id.
 @return If the function succeeds, the return value is YES. Otherwise failed.
 */
- (BOOL)withdrawCCPrivilege:(NSUInteger)userId;

/*!
 @brief Query if the current user can assign the privilege of send closed caption to others.
 @return YES means that the user can assign others privilege to send closed caption.
 */
- (BOOL)canAssignOthersToSendCC;

/*!
 @brief Hosts only API to set meeting language for the entire meeting
 */
- (BOOL)enableMeetingManualCaption:(BOOL)bEnable;
/*!
 @brief Determine whether it is enabled to manual input CC for meeting.
 */
- (BOOL)isMeetingManualCaptionEnabled;

/*!
 @brief Query if this meeting support the live transcription feature.
 @return YES means that the live transcription feature is supported.
 */
- (BOOL)isLiveTranscriptionFeatureEnabled;

/*!
 @brief Query the current live transcription status.
 @return  the live transcription status.  For more details, see MobileRTCLiveTranscriptionStatus.
 */
- (MobileRTCLiveTranscriptionStatus)getLiveTranscriptionStatus;

/*!
 @brief Query if meeting participants can start live transcription.
 @return YES means that the participant can start live transcription.
 */
- (BOOL)canStartLiveTranscription;

/*!
 @brief Start live transcription. If the meeting enable multi language transcription,all user can start live transcription otherwise only host can start.
 @return If the function succeeds, the return value is YES. Otherwise failed.
 */
- (BOOL)startLiveTranscription;

/*!
 @brief Stop live transcription. If the meeting enable multi language transcription,all user can stop live transcription,otherwise only host can stop.
 @return If the function succeeds, the return value is YES. Otherwise failed.
 */
- (BOOL)stopLiveTranscription;

/*!
 @brief The host enable/disable the request live transcription.
 @param enable YES means that enable the request live transcription; FALSE means that disable the request live transcription.
 @return If the function succeeds, the return value is YES. Otherwise failed.
 */
- (BOOL)enableRequestLiveTranscription:(BOOL)enable;

/*!
 @brief Query if it is enabled to request to start live transcription.
 @return YES means that it is enabled to request to start live transcription.
 */
- (BOOL)isRequestToStartLiveTranscriptionEnabled;

/*!
 @brief Request the host to start live transcription.
 @param requestAnonymous TRUE means that it is anonymous to request the host to start live transcription.
 @return If the function succeeds, the return value is YES. Otherwise failed.
 */
- (BOOL)requestToStartLiveTranscription:(BOOL)requestAnonymous;

/*!
 @brief Determine whether the multi language transcription feature is enabled.
 @return returns YES if multi-language transcription enabled. Otherwise failed.
 */
- (BOOL)isMultiLanguageTranscriptionEnabled;

/**
 @brief Determine whether the translated captions feature is enabled.
 @return YES means enabled, otherwise not.
 */
- (BOOL)isTextLiveTranslationEnabled;

/**
 @brief Enable or disable to receive original and translated content.If enable this feature,you need start live transcription.
 @return If the function succeeds, the return value is MobileRTCSDKError_Success. Otherwise the function fails and returns an error. To get extended error information, see [MobileRTCSDKError] enum.
 */
- (MobileRTCSDKError)enableReceiveSpokenlLanguageContent:(BOOL)enabled;

/**
 @brief  Determine whether receive original and translated is available.
 @return True indicates receive original and translated is available. Otherwise False.
 */

- (BOOL)isReceiveSpokenLanguageContentEnabled;

/*!
 @brief Get the list of all available spoken languages in meeting.
 @return If the function succeeds, the return value is the list of the available spoken languages in meeting. Otherwise failed, the return value is NULL.
 */
- (NSArray<MobileRTCLiveTranscriptionLanguage*>* _Nullable)getAvailableMeetingSpokenLanguages;

/*!
 @brief set spoken language of the current user.
 @param languageID the speak language id.
 @return If the function succeeds, the return value is MobileRTCSDKError_Success. Otherwise failed. To get extended error information, see \link SDKError \endlink enum.
 */
- (BOOL)setMeetingSpokenLanguage:(NSInteger)languageID DEPRECATED_MSG_ATTRIBUTE("Use setMeetingSpokenLanguage:isForAll: instead");;

/*!
 @brief Set the current user's spoken language
 @param languageID the speak language ID.
 @param isForAll True means set spoken language for all users. False means only set for myself.
 @return If the function succeeds, the return value is MobileRTCSDKError_Success. Otherwise failed. To get extended error information, see \link SDKError \endlink enum.
 */
- (MobileRTCSDKError)setMeetingSpokenLanguage:(NSInteger)languageID isForAll:(BOOL)isForAll;

/*!
 @brief Get the spoken language of the current user.
 */
- (MobileRTCLiveTranscriptionLanguage *_Nullable)getMeetingSpokenLanguage;

/*!
 @brief Get the list of all available translation languages in meeting.
 @return If the function succeeds, the return value is the list of all available translation languages in meeting. Otherwise failed, the return value is NULL.
 */
- (NSArray<MobileRTCLiveTranscriptionLanguage*>* _Nullable)getAvailableTranslationLanguages;

/*!
 @brief set the translation language of the current user.
 @param languageID the translation language id. If the language ID is set to -1, live translation will be disabled,then you can reveive closed caption when host set meeting manual caption is true.
 @return If the function succeeds, the return value is MobileRTCSDKError_Success. Otherwise failed. To get extended error information, see \link SDKError \endlink enum.
 */
- (BOOL)setTranslationLanguage:(NSInteger)languageID;

/*!
@brief Get the translation language of the current user.
 */
- (MobileRTCLiveTranscriptionLanguage *_Nullable)getTranslationLanguage;

@end

