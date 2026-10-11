import Contacts
import Flutter
import MessageUI
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let channel = FlutterMethodChannel(
      name: "patron/contacts",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "status":
        result(Self.accessName(CNContactStore.authorizationStatus(for: .contacts)))
      case "request":
        Self.requestAccess(result: result)
      case "openSettings":
        if let url = URL(string: UIApplication.openSettingsURLString) {
          UIApplication.shared.open(url)
        }
        result(nil)
      case "load":
        DispatchQueue.global(qos: .userInitiated).async {
          do {
            let people = try Self.loadContacts()
            DispatchQueue.main.async { result(people) }
          } catch {
            DispatchQueue.main.async {
              result(
                FlutterError(
                  code: "contacts",
                  message: error.localizedDescription,
                  details: nil
                )
              )
            }
          }
        }
      case "shareImage":
        self.shareImage(arguments: call.arguments, result: result)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func shareImage(arguments: Any?, result: @escaping FlutterResult) {
    guard
      let args = arguments as? [String: Any],
      let channel = args["channel"] as? String,
      let address = args["address"] as? String,
      let subject = args["subject"] as? String,
      let image = imageData(args["image"]),
      !image.isEmpty
    else {
      result(false)
      return
    }
    DispatchQueue.main.async {
      result(
        self.presentProductionImage(
          channel: channel,
          address: address,
          subject: subject,
          image: image
        )
      )
    }
  }

  private func imageData(_ value: Any?) -> Data? {
    if let typed = value as? FlutterStandardTypedData {
      return typed.data
    }
    if let data = value as? Data {
      return data
    }
    return nil
  }

  private func presentProductionImage(
    channel: String,
    address: String,
    subject: String,
    image: Data
  ) -> Bool {
    guard let presenter = topViewController() else { return false }
    if channel == "sms", presentMessage(image: image, address: address, from: presenter) {
      return true
    }
    if channel == "email",
      MFMailComposeViewController.canSendMail(),
      presentMail(image: image, address: address, subject: subject, from: presenter)
    {
      return true
    }
    return presentImageShareSheet(data: image, from: presenter)
  }

  private func presentMessage(
    image: Data,
    address: String,
    from presenter: UIViewController
  ) -> Bool {
    // Presenting the composer when Messages cannot send aborts the app.
    guard MFMessageComposeViewController.canSendText() else { return false }
    guard presenter.view.window != nil, presenter.presentedViewController == nil else {
      return false
    }
    let controller = MFMessageComposeViewController()
    controller.messageComposeDelegate = self
    controller.recipients = [address]
    if MFMessageComposeViewController.canSendAttachments() {
      attachProductionImage(image, to: controller)
    }
    presenter.present(controller, animated: true)
    return true
  }

  private func attachProductionImage(
    _ image: Data,
    to controller: MFMessageComposeViewController
  ) {
    let directory = FileManager.default.temporaryDirectory
    let pngURL = directory.appendingPathComponent("sapumal-production.png")
    if (try? image.write(to: pngURL, options: .atomic)) != nil,
      controller.addAttachmentURL(pngURL, withAlternateFilename: "production.png")
    {
      return
    }
    if controller.addAttachmentData(
      image,
      typeIdentifier: "public.png",
      filename: "production.png"
    ) {
      return
    }
    guard let picture = UIImage(data: image),
      let jpeg = picture.jpegData(compressionQuality: 0.92)
    else {
      return
    }
    let jpegURL = directory.appendingPathComponent("sapumal-production.jpg")
    if (try? jpeg.write(to: jpegURL, options: .atomic)) != nil {
      controller.addAttachmentURL(jpegURL, withAlternateFilename: "production.jpg")
    } else {
      controller.addAttachmentData(
        jpeg,
        typeIdentifier: "public.jpeg",
        filename: "production.jpg"
      )
    }
  }

  private func presentMail(
    image: Data,
    address: String,
    subject: String,
    from presenter: UIViewController
  ) -> Bool {
    let controller = MFMailComposeViewController()
    controller.mailComposeDelegate = self
    controller.setToRecipients([address])
    controller.setSubject(subject)
    controller.addAttachmentData(image, mimeType: "image/png", fileName: "production.png")
    presenter.present(controller, animated: true)
    return true
  }

  private func presentImageShareSheet(data: Data, from presenter: UIViewController) -> Bool {
    guard let image = UIImage(data: data) else { return false }
    let controller = UIActivityViewController(activityItems: [image], applicationActivities: nil)
    if let popover = controller.popoverPresentationController {
      popover.sourceView = presenter.view
      popover.sourceRect = CGRect(
        x: presenter.view.bounds.midX,
        y: presenter.view.bounds.midY,
        width: 1,
        height: 1
      )
      popover.permittedArrowDirections = []
    }
    presenter.present(controller, animated: true)
    return true
  }

  private func topViewController() -> UIViewController? {
    guard let window = foregroundWindow() else { return nil }
    var controller = window.rootViewController
    while let presented = controller?.presentedViewController {
      controller = presented
    }
    return controller
  }

  private func foregroundWindow() -> UIWindow? {
    let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
    guard let scene = scenes.first(where: { $0.activationState == .foregroundActive }) ?? scenes.first else {
      return nil
    }
    if #available(iOS 15.0, *), let keyWindow = scene.keyWindow {
      return keyWindow
    }
    if let delegate = scene.delegate as? UIWindowSceneDelegate, let window = delegate.window {
      return window
    }
    return scene.windows.first
  }

  func messageComposeViewController(
    _ controller: MFMessageComposeViewController,
    didFinishWith result: MessageComposeResult
  ) {
    controller.dismiss(animated: true)
  }

  func mailComposeController(
    _ controller: MFMailComposeViewController,
    didFinishWith result: MFMailComposeResult,
    error: Error?
  ) {
    controller.dismiss(animated: true)
  }

  private static func requestAccess(result: @escaping FlutterResult) {
    let status = CNContactStore.authorizationStatus(for: .contacts)
    if isGranted(status) || isBlocked(status) {
      result(accessName(status))
      return
    }
    CNContactStore().requestAccess(for: .contacts) { _, _ in
      DispatchQueue.main.async {
        result(accessName(CNContactStore.authorizationStatus(for: .contacts)))
      }
    }
  }

  private static func isGranted(_ status: CNAuthorizationStatus) -> Bool {
    if status == .authorized { return true }
    if #available(iOS 18.0, *), status == .limited { return true }
    return false
  }

  private static func isBlocked(_ status: CNAuthorizationStatus) -> Bool {
    status == .denied || status == .restricted
  }

  private static func accessName(_ status: CNAuthorizationStatus) -> String {
    if isGranted(status) { return "granted" }
    if isBlocked(status) { return "permanentlyDenied" }
    return "denied"
  }

  private static func loadContacts() throws -> [[String: Any]] {
    let store = CNContactStore()
    let keys: [CNKeyDescriptor] = [
      CNContactIdentifierKey as CNKeyDescriptor,
      CNContactGivenNameKey as CNKeyDescriptor,
      CNContactFamilyNameKey as CNKeyDescriptor,
      CNContactPhoneNumbersKey as CNKeyDescriptor,
      CNContactEmailAddressesKey as CNKeyDescriptor,
    ]
    let request = CNContactFetchRequest(keysToFetch: keys)
    var people: [[String: Any]] = []
    try store.enumerateContacts(with: request) { contact, _ in
      let name = "\(contact.givenName) \(contact.familyName)"
        .trimmingCharacters(in: .whitespacesAndNewlines)
      people.append([
        "id": contact.identifier,
        "name": name,
        "phones": contact.phoneNumbers.map { $0.value.stringValue },
        "emails": contact.emailAddresses.map { $0.value as String },
      ])
    }
    return people
  }
}
