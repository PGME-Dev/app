import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(
        _ request: UNNotificationRequest,
        withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
    ) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        guard let bestAttemptContent = bestAttemptContent else {
            contentHandler(request.content)
            return
        }

        // FCM sends the image URL in fcm_options/image or in the userInfo
        // Try multiple keys used by Firebase
        var imageUrlString: String?

        if let fcmOptions = bestAttemptContent.userInfo["fcm_options"] as? [String: Any],
           let imageUrl = fcmOptions["image"] as? String {
            imageUrlString = imageUrl
        } else if let imageUrl = bestAttemptContent.userInfo["image"] as? String {
            imageUrlString = imageUrl
        } else if let aps = bestAttemptContent.userInfo["aps"] as? [String: Any],
                  let imageUrl = aps["image"] as? String {
            imageUrlString = imageUrl
        }

        guard let urlString = imageUrlString,
              let url = URL(string: urlString) else {
            contentHandler(bestAttemptContent)
            return
        }

        // Download the image and attach it
        downloadImage(from: url) { attachment in
            if let attachment = attachment {
                bestAttemptContent.attachments = [attachment]
            }
            contentHandler(bestAttemptContent)
        }
    }

    override func serviceExtensionTimeWillExpire() {
        // Deliver whatever we have if we run out of time
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

    private func downloadImage(from url: URL, completion: @escaping (UNNotificationAttachment?) -> Void) {
        let task = URLSession.shared.downloadTask(with: url) { downloadedUrl, response, error in
            guard let downloadedUrl = downloadedUrl, error == nil else {
                completion(nil)
                return
            }

            // Determine file extension from URL or response
            let ext = self.fileExtension(from: url, response: response)
            let tmpUrl = URL(fileURLWithPath: NSTemporaryDirectory())
                .appendingPathComponent(UUID().uuidString + ext)

            do {
                try FileManager.default.moveItem(at: downloadedUrl, to: tmpUrl)
                let attachment = try UNNotificationAttachment(identifier: "image", url: tmpUrl, options: nil)
                completion(attachment)
            } catch {
                completion(nil)
            }
        }
        task.resume()
    }

    private func fileExtension(from url: URL, response: URLResponse?) -> String {
        // Try from URL path
        let pathExt = url.pathExtension.lowercased()
        if !pathExt.isEmpty && ["jpg", "jpeg", "png", "gif", "webp"].contains(pathExt) {
            return ".\(pathExt)"
        }
        // Try from MIME type
        if let mimeType = response?.mimeType?.lowercased() {
            if mimeType.contains("jpeg") || mimeType.contains("jpg") { return ".jpg" }
            if mimeType.contains("png") { return ".png" }
            if mimeType.contains("gif") { return ".gif" }
        }
        return ".jpg" // default
    }
}
