import AVFoundation
import AVKit
import CommonCrypto
import Foundation
import class Foundation.Bundle
import MessageUI
import Photos
import SwiftOnoneSupport
import UIKit

public protocol Content {
    var contentType: ShareThatTo.ContentType { get }

    func videoContent() -> ShareThatTo.VideoContent?

    func cleanupContent(with usedStrategies: [ShareThatTo.ShareStretegyType])
}

extension Content {
    public func videoContent() -> ShareThatTo.VideoContent?
}

public enum ContentType: String {
    case unknown

    case video
}

public typealias LinkPreviewShareStrategyProtocol = (ShareThatTo.ShareStrategyProtocol & ShareThatTo.ShareStretegyTypeLinkPreviewProtocol)

public class PhotoPermissionHelper {
    public init(viewController: UIViewController, content: ShareThatTo.Content, shareOutlet: ShareThatTo.ShareOutletProtocol, delegate: ShareThatTo.PhotoPermissionHelperDelegate?)

    public func requestPermission()
}

public protocol PhotoPermissionHelperDelegate {
    func succeeded()

    func cancelled()

    func failed()
}

public class PhotoRequirement: ShareThatTo.RequiredPlistNonNil {
    public required init()
}

public protocol Presentable {
    func presentOn(viewController: UIViewController, view: UIView) -> Error?
}

public enum PresentationResult {
    case cancelled

    case shared(destination: String)

    case ignored
}

public enum PresentationStyle {
    case shareSheet

    case toast(message: String)
}

public typealias RawShareStrategyProtocol = (ShareThatTo.ShareStrategyProtocol & ShareThatTo.ShareStretegyTypeRawProtocol)

public typealias RenderingResult = Result<ShareThatTo.SuccessfulRenderingResult, Error>

public typealias RenderingResultCompletion = (ShareThatTo.RenderingResult) -> Void

public struct RequiredApplicationQuerySchemes: ShareThatTo.ShareOutletRequirementProtocol {
    public init(requiredSchemes: [String])

    public func met(plist: [String: Any?]) -> Bool
}

public struct RequiredCFBundleURLSchemes: ShareThatTo.ShareOutletRequirementProtocol {
    public init(requiredSchemes: [String])

    public func met(plist: [String: Any?]) -> Bool
}

public class RequiredConfigurationValue: ShareThatTo.ShareOutletRequirementProtocol {
    public func met(plist: [String: Any?]) -> Bool

    public init(requiredConfigurationValue: String)
}

public class RequiredPlistNonNil: ShareThatTo.ShareOutletRequirementProtocol {
    public init(requiredKey: String, defaultValue: String? = nil)

    public func met(plist: [String: Any?]) -> Bool
}

public struct RequiredPlistValue: ShareThatTo.ShareOutletRequirementProtocol {
    public init(requiredKey: String, requiredValue: String)

    public func met(plist: [String: Any?]) -> Bool
}

open class Requirements: ShareThatTo.ShareOutletRequirementProtocol {
    public init(requirements: [ShareThatTo.ShareOutletRequirementProtocol])

    public func met(plist: [String: Any?]) -> Bool
}

public protocol ShareOutletDelegate {
    func success(shareOutlet: ShareThatTo.ShareOutletProtocol, strategiesUsed: [ShareThatTo.ShareStretegyType])

    func failure(shareOutlet: ShareThatTo.ShareOutletProtocol, error: String)

    func cancelled(shareOutlet: ShareThatTo.ShareOutletProtocol)
}

public protocol ShareOutletProtocol {
    static var outletLifecycleDelegate: ShareThatTo.ShareThatToLifecycleDelegate? { get }

    var delegate: ShareThatTo.ShareOutletDelegate? { get set }

    var content: ShareThatTo.Content { get set }

    static var imageName: String { get }

    static var outletName: String { get }

    static var canonicalOutletName: String { get }

    static var requirements: ShareThatTo.ShareOutletRequirementProtocol? { get }

    static func buttonImage() -> UIImage?

    static func canPerform(withContentType contentType: ShareThatTo.ContentType) -> Bool

    init(content: ShareThatTo.Content)

    func share(with viewController: UIViewController)
}

public protocol ShareOutletRequirementProtocol {
    func met(plist: [String: Any?]) -> Bool
}

public typealias SharePresentationCompletion = (ShareThatTo.PresentationResult) -> Void

public enum ShareStrategy: Int {
    case none

    case raw

    case rendered

    case linkPreview
}

public protocol ShareStrategyProtocol {
    var shareStrategy: ShareThatTo.ShareStrategy { get }

    var shareStrategyType: ShareThatTo.ShareStretegyType { get }
}

public enum ShareStretegyType {
    case raw

    case linkPreview
}

public protocol ShareStretegyTypeLinkPreviewProtocol {
    var link: String { get }
}

public protocol ShareStretegyTypeRawProtocol {
    var data: Data { get }
}

public class ShareThatTo: ShareThatTo.ShareThatToLifecycleDelegate {
    public static let shared: ShareThatTo.ShareThatTo

    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool

    public func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool

    public func configure(userId: String?)

    public func configure(apiKey: String)

    public func register(outlet: ShareThatTo.ShareOutletProtocol.Type)
}

public protocol ShareThatToLifecycleDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool
}

public struct SuccessfulRenderingResult: Equatable {
    public let displayURL: URL

    public init(displayURL: URL)
}

public protocol TitleProvider {
    var title: String? { get }
}

public class UGC: ShareThatTo.Presentable, ShareThatTo.TitleProvider {
    public let renderSettings: ShareThatTo.UGCRenderSettings

    public var title: String?

    public weak var delegate: ShareThatTo.UGCResultDelegate?

    public convenience init(tag: String, title: String, _ options: ShareThatTo.UGCRenderOptions...)

    public convenience init(tag: String, _ options: ShareThatTo.UGCRenderOptions...)

    public func addScene(tag: String, _ sceneOptions: ShareThatTo.UGCSceneOption...) -> ShareThatTo.UGCScene

    public func present(on viewController: UIViewController, presentationStyle: ShareThatTo.PresentationStyle = .shareSheet, completion: ShareThatTo.SharePresentationCompletion? = nil)

    public func presentOn(viewController: UIViewController, view: UIView) -> Error?

    public func ready(completion: ShareThatTo.UGCResultCompletion? = nil)
}

extension UGC {
    public func startRendering()

    public func renderingComplete(completion: @escaping (ShareThatTo.RenderingResult) -> Void)
}

public enum UGCError: Error {
    case unknown

    case noDuration

    case exportFailedOrCancelled

    case exportFailedFatally

    case videoError(message: String)

    case imageError(message: String)
}

public class UGCImageFormat {
    public var attributes: [CALayer.MutableLayerAttribute]

    public init(_ attributes: CALayer.MutableLayerAttribute...)

    public func appendAttribute(_ newAttribute: CALayer.MutableLayerAttribute)
}

public typealias UGCPresentationCompletion = () -> Void

public enum UGCRenderOptions {
    case backgroundColor(CGColor)

    case preset(ShareThatTo.UGCRenderPreset)

    case size(CGSize)
}

public enum UGCRenderPreset {
    case verticalVideoPreset
}

public struct UGCRenderSettings {
    public var size: CGSize

    public init(_ options: [ShareThatTo.UGCRenderOptions] = [])
}

public typealias UGCResult = Result<ShareThatTo.SuccessfulRenderingResult, ShareThatTo.UGCError>

public typealias UGCResultCompletion = (ShareThatTo.UGCResult) -> Void

public protocol UGCResultDelegate: AnyObject {
    func didFinish(result: ShareThatTo.UGCResult)
}

public class UGCScene {
    public init(renderSettings: ShareThatTo.UGCRenderSettings, _ sceneOptions: ShareThatTo.UGCSceneOption...)

    public func imageLayer(format: ShareThatTo.UGCImageFormat, url: URL) -> ShareThatTo.UGCScene

    public func imageLayer(format: ShareThatTo.UGCImageFormat, image: UIImage) -> ShareThatTo.UGCScene

    public func videoLayer(format: ShareThatTo.UGCVideoFormat, url: URL) -> ShareThatTo.UGCScene

    public func textLayer(format: ShareThatTo.UGCTextFormat, text: String) -> ShareThatTo.UGCScene

    public func ready(completion: ShareThatTo.UGCResultCompletion? = nil)

    public func presentScene(on viewController: UIViewController, view: UIView, completion: ShareThatTo.UGCPresentationCompletion? = nil) -> Error?
}

extension UGCScene: Equatable {
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: ShareThatTo.UGCScene, rhs: ShareThatTo.UGCScene) -> Bool
}

public enum UGCSceneOption {
    case maxDuration(Double)
}

public struct UGCSceneOptions {}

public typealias UGCSuccessResult = ShareThatTo.SuccessfulRenderingResult

public class UGCTextFormat {
    public init(_ attributes: CALayer.MutableLayerAttribute...)

    public func appendAttribute(_ newAttribute: CALayer.MutableLayerAttribute)
}

public class UGCVideoFormat {
    public var attributes: [CALayer.MutableLayerAttribute]

    public init(_ attributes: CALayer.MutableLayerAttribute...)

    public func appendAttribute(_ newAttribute: CALayer.MutableLayerAttribute)
}

public class VideoContent: ShareThatTo.Content {
    public let contentType: ShareThatTo.ContentType

    public let title: String

    public let videoURL: URL

    public func rawStrategy(caller: ShareThatTo.ShareOutletProtocol?) -> ShareThatTo.RawShareStrategyProtocol

    public func linkPreviewStrategy(caller: ShareThatTo.ShareOutletProtocol) -> ShareThatTo.LinkPreviewShareStrategyProtocol?

    public func linkPreviewAvailable() -> Bool

    public func cleanupContent(with usedStrategies: [ShareThatTo.ShareStretegyType])
}

extension CALayer {
    public enum MutableLayerAttributeCodingKeys: CodingKey {
        case contents

        case contentsRect

        case contentsCenter

        case contentsGravity

        case opacity

        case isHidden

        case masksToBounds

        case mask

        case isDoubleSided

        case cornerRadius

        case maskedCorners

        case borderColor

        case borderWidth

        case backgroundColor

        case shadowOpacity

        case shadowRadius

        case shadowOffset

        case shadowColor

        case shadowPath

        case style

        case allowsEdgeAntialiasing

        case allowsGroupOpacity

        case filters

        case minificationFilterBias

        case magnificationFilter

        case edgeAntialiasingMask

        case isGeometryFlipped

        case drawsAsynchronously

        case shouldRasterize

        case rasterizationScale

        case contentsFormat

        case frame

        case bounds

        case position

        case zPosition

        case anchorPointZ

        case anchorPoint

        case contentsScale

        case transform

        case sublayerTransform

        case sublayers

        case actions

        case name

        case cornerCurve

        case isWrapped

        case alignmentMode

        case truncationMode

        case string

        case font

        case fontSize

        case foregroundColor

        case allowsFontSubpixelQuantization
    }

    public enum MutableLayerAttribute {
        case contents(Any)

        case contentsRect(CGRect)

        case contentsCenter(CGRect)

        case contentsGravity(CALayerContentsGravity)

        case opacity(Float)

        case isHidden(Bool)

        case masksToBounds(Bool)

        case mask(CALayer)

        case isDoubleSided(Bool)

        case cornerRadius(CGFloat)

        case maskedCorners(CACornerMask)

        case borderColor(CGColor)

        case borderWidth(CGFloat)

        case backgroundColor(CGColor)

        case shadowOpacity(Float)

        case shadowRadius(CGFloat)

        case shadowOffset(CGSize)

        case shadowColor(CGColor)

        case shadowPath(CGPath)

        case style([AnyHashable: Any])

        case allowsEdgeAntialiasing(Bool)

        case allowsGroupOpacity(Bool)

        case filters([Any])

        case minificationFilterBias(Float)

        case magnificationFilter(CALayerContentsFilter)

        case isOpaque(Bool)

        case edgeAntialiasingMask(CAEdgeAntialiasingMask)

        case isGeometryFlipped(Bool)

        case drawsAsynchronously(Bool)

        case shouldRasterize(Bool)

        case rasterizationScale(CGFloat)

        case contentsFormat(CALayerContentsFormat)

        case frame(CGRect)

        case bounds(CGRect)

        case position(CGPoint)

        case zPosition(CGFloat)

        case anchorPointZ(CGFloat)

        case anchorPoint(CGPoint)

        case contentsScale(CGFloat)

        case transform(CATransform3D)

        case sublayerTransform(CATransform3D)

        case sublayers([CALayer])

        case actions([String: CAAction])

        case name(String)

        case cornerCurve(CALayerCornerCurve)

        case isWrapped(Bool)

        case alignmentMode(CATextLayerAlignmentMode)

        case truncationMode(CATextLayerTruncationMode)

        case string(Any)

        case font(CFTypeRef)

        case fontSize(CGFloat)

        case foregroundColor(CGColor)

        case allowsFontSubpixelQuantization(Bool)
    }

    public func applyAttributes(layerAttributes: [CALayer.MutableLayerAttribute])

    public func applyAttribute(layerAttribute: CALayer.MutableLayerAttribute)
}
