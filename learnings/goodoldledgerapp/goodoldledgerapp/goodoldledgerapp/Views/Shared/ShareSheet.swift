//
//  ShareSheet.swift
//  goodoldledgerapp
//

import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        controller.excludedActivityTypes = []
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

final class CSVActivityItem: NSObject, UIActivityItemSource {
    private let url: URL

    init(url: URL) {
        self.url = url
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        url
    }

    func activityViewController(
        _ activityViewController: UIActivityViewController,
        itemForActivityType activityType: UIActivity.ActivityType?
    ) -> Any? {
        url
    }

    func activityViewController(
        _ activityViewController: UIActivityViewController,
        dataTypeIdentifierForActivityType activityType: UIActivity.ActivityType?
    ) -> String {
        UTType.commaSeparatedText.identifier
    }

    func activityViewController(
        _ activityViewController: UIActivityViewController,
        subjectForActivityType activityType: UIActivity.ActivityType?
    ) -> String {
        "Good Old Ledger Export"
    }
}
