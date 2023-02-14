//
//  ShareViewController.swift
//  ServersShareExtension
//
//  Created by Yifeng Qiu on 2023-01-28.
//

import UIKit
import Social
import UniformTypeIdentifiers

class ShareViewController: SLComposeServiceViewController {
    private let client = HTTPClient()
    private var sharedURL : String?
    private var provider : NSItemProvider?
    
    override func isContentValid() -> Bool {
        // this function is called whenever user edits the contentText
        // Do validation of contentText and/or NSExtensionContext attachments here
        print("DEBUG: checking whether content is valid. ")
        if self.contentText.isValidURL{
            print("DEBUG: the contentText is a valid URL and is \(self.contentText!)")
            self.sharedURL = self.contentText
        } else{
            for case let item as NSExtensionItem in self.extensionContext?.inputItems ?? []{
                let attachments = item.attachments ?? []
                for provider in attachments{
                    if provider.hasItemConformingToTypeIdentifier(UTType.url.identifier){
                        self.provider = provider
                    }
                }
            }
            
        }
        return ((self.sharedURL != nil) || (self.provider != nil))
    }
    
    override func didSelectPost() {
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
        
        if let sharedURL = self.sharedURL {
            print("DEBUG: sharedURL is \(sharedURL)")
            Task{
                _ = await client.postToMyServer(["url" : sharedURL])
            }
        }
        else{
            if let provider = self.provider{
                Task{
                    let data = try await provider.loadItem(forTypeIdentifier: UTType.url.identifier)
                    guard let sharedURL = data as? URL, sharedURL.absoluteString != "" else {return}
                    _ = await client.postToMyServer(["url": sharedURL.absoluteString])
                    
                }
            }
        }
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }
    
}

