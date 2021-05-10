//
//  PreviewViewController.swift
//  QLPreviewExtension
//
//  Created by user on 2021/05/09.
//

import Cocoa
import Quartz
import ZIPFoundation
import SnapKit
import Ikemen

class PreviewViewController: NSViewController, QLPreviewingController {
    let iconView = NSImageView() ※ {
        $0.snp.makeConstraints { make in
            make.size.equalTo(192)
        }
    }
    let appNameField = NSTextField(labelWithString: "") ※ {
        $0.font = .boldSystemFont(ofSize: 20)
        $0.textColor = .labelColor
    }
    let appIDField = NSTextField(labelWithString: "")
    let appVersionField = NSTextField(labelWithString: "")
    let purcharserField = NSTextField(labelWithString: "Purchased Information Not Found (designed for sideload?)")
    let binaryInfoField = NSTextField(labelWithString: "")
    
    override func loadView() {
        let view = NSView()
        let headerStackView = NSStackView(views: [
            iconView,
            NSStackView(views: [
                appNameField,
                appVersionField,
                appIDField,
                purcharserField,
                binaryInfoField,
            ]) ※ {
                $0.orientation = .vertical
                $0.alignment = .leading
            }
        ]) ※ {
            $0.orientation = .horizontal
            $0.alignment = .top
            $0.spacing = 24
        }
        view.addSubview(headerStackView)
        headerStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(32)
        }
        self.view = view
    }

    /*
     * Implement this method and set QLSupportsSearchableItems to YES in the Info.plist of the extension if you support CoreSpotlight.
     *
    func preparePreviewOfSearchableItem(identifier: String, queryString: String?, completionHandler handler: @escaping (Error?) -> Void) {
        // Perform any setup necessary in order to prepare the view.
        
        // Call the completion handler so Quick Look knows that the preview is fully loaded.
        // Quick Look will display a loading spinner while the completion handler is not called.
        handler(nil)
    }
     */
    
    func preparePreviewOfFile(at url: URL, completionHandler handler: @escaping (Error?) -> Void) {
        
        // Add the supported content types to the QLSupportedContentTypes array in the Info.plist of the extension.
        
        // Perform any setup necessary in order to prepare the view.
        
        // Call the completion handler so Quick Look knows that the preview is fully loaded.
        // Quick Look will display a loading spinner while the completion handler is not called.
        
        let archive = Archive(url: url, accessMode: .read)!
        var appBundle: Entry? = nil
        for file in archive {
            let components = file.path.split(separator: "/")
            print(components)
            if components.count == 2, components[0] == "Payload", components[1].hasSuffix(".app") {
                appBundle = file
                break
            }
        }
        guard let appBundle = appBundle else {
            handler(nil)
            return
        }
        if let metadataPlistEntry = archive["iTunesMetadata.plist"] {
            let data = try! archive.extractAll(metadataPlistEntry)
            if let metadataPlist  = (try! PropertyListSerialization.propertyList(from: data, options: [], format: nil)) as? [String: Any] {
                print(metadataPlist)
                purcharserField.stringValue = "Purchased from iTunes/App Store"
                if let appleID = metadataPlist["apple-id"] as? String {
                    purcharserField.stringValue += " (Account: \(appleID))"
                }
            }
        }
        if let artwork = archive["iTunesArtwork"] {
            let data = try! archive.extractAll(artwork)
            iconView.image = NSImage(data: data)
            print(data)
        }
        var appBundlePath = appBundle.path
        if appBundlePath.hasSuffix("/") {
            appBundlePath.removeLast()
        }
        if let infoPlistEntry = archive[appBundlePath+"/Info.plist"] {
            print(infoPlistEntry)
            let data = try! archive.extractAll(infoPlistEntry)
            if let infoPlist = (try! PropertyListSerialization.propertyList(from: data, options: [], format: nil)) as? [String: Any] {
                print(infoPlist)
                if let displayName = infoPlist["CFBundleDisplayName"] as? String ?? infoPlist["CFBundleName"] as? String {
                    appNameField.stringValue = displayName
                }
                if let bundleID = infoPlist["CFBundleIdentifier"] as? String {
                    appIDField.stringValue = bundleID
                }
                if let appBuildNumber = infoPlist["CFBundleVersion"] as? String, let appVersion = infoPlist["CFBundleShortVersionString"] as? String {
                    appVersionField.stringValue = "Version \(appVersion) (\(appBuildNumber))"
                }
            }
        }
        view.layout()
        handler(nil)
    }
}

extension Archive {
    func extractAll(_ entry: Entry) throws -> Data {
        var data = Data(capacity: entry.uncompressedSize)
        try! extract(entry) { chunk in
            data.append(chunk)
        }
        return data
    }
}

