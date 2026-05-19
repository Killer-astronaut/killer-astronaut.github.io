import Messages
import SwiftUI
import LoveBirdsKit

@objc(MessagesViewController)
final class MessagesViewController: MSMessagesAppViewController {
    private var hostingController: UIHostingController<MessagesRootView>?

    override func viewDidLoad() {
        super.viewDidLoad()
        installSwiftUI()
    }

    private func installSwiftUI() {
        let root = MessagesRootView(onSelectVibe: { [weak self] vibe in
            self?.compose(vibe: vibe)
        })
        let host = UIHostingController(rootView: root)
        addChild(host)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(host.view)
        NSLayoutConstraint.activate([
            host.view.topAnchor.constraint(equalTo: view.topAnchor),
            host.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            host.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        host.didMove(toParent: self)
        host.view.backgroundColor = .black
        self.hostingController = host
    }

    private func compose(vibe: HeartVibe) {
        guard let conversation = activeConversation else { return }
        let layout = MSMessageTemplateLayout()
        layout.image = renderedImage(for: vibe)
        layout.caption = vibe.label
        layout.subcaption = "via Love Birds"

        let message = MSMessage()
        message.layout = layout
        message.summaryText = "Love Birds: \(vibe.label)"
        message.url = URL(string: "lovebirds://send?vibe=\(vibe.rawValue)")

        conversation.insert(message) { error in
            if let error = error {
                AppLogger.ui.error("Insert message failed: \(error.localizedDescription)")
            }
        }
        dismiss()
    }

    private func renderedImage(for vibe: HeartVibe) -> UIImage {
        let size = CGSize(width: 320, height: 320)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            let cg = ctx.cgContext
            let colors = [UIColor(red: 1.0, green: 0.56, blue: 0.64, alpha: 1).cgColor,
                          UIColor(red: 1.0, green: 0.42, blue: 0.62, alpha: 1).cgColor]
            let gradient = CGGradient(colorsSpace: nil, colors: colors as CFArray, locations: [0, 1])!
            cg.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: size.width, y: size.height), options: [])

            let text = vibe.emoji as NSString
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 180)
            ]
            let textSize = text.size(withAttributes: attrs)
            let origin = CGPoint(x: (size.width - textSize.width) / 2, y: (size.height - textSize.height) / 2)
            text.draw(at: origin, withAttributes: attrs)
        }
    }
}
