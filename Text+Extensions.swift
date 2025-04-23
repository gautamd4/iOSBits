
import SwiftUI

enum RichTextComponent: Identifiable {
    case text(String, style: RichTextStyle = .default)
    case link(String, style: RichTextStyle = .link, action: () -> Void)

    var id: UUID { UUID() } // or hashable text if you prefer
}

struct RichTextStyle {
    var font: Font?
    var foregroundColor: Color?
    var weight: Font.Weight?
    var italic: Bool = false
    var underline: Bool = false

    static let `default` = RichTextStyle()
    static let link = RichTextStyle(
        foregroundColor: .blue,
        underline: true,
        weight: .regular
    )
}

struct RichParagraph: View {
    var components: [RichTextComponent]
    var lineSpacing: CGFloat = 4
    var alignment: TextAlignment = .leading

    var body: some View {
        // Flow in horizontal stack with wrapping
        // Option 1: Wrap in a VStack if using full-line units
        // Option 2: Use a text flow layout (for now, we’ll build composable sentence)
        TextFlowView(components: components)
            .multilineTextAlignment(alignment)
            .lineSpacing(lineSpacing)
    }
}

struct TextFlowView: View {
    var components: [RichTextComponent]

    var body: some View {
        // Compose inline using HStack + Wrap if needed
        // In practice, a VStack with Text+Button sequences
        TextFlowLayout(components: components)
    }
}

struct TextFlowLayout: View {
    var components: [RichTextComponent]

    var body: some View {
        // Multiline wrapping simulation by breaking into inline HStacks inside VStack
        VStack(alignment: .leading) {
            HStack(spacing: 0) {
                ForEach(components) { component in
                    switch component {
                    case .text(let str, let style):
                        styledText(str, style: style)

                    case .link(let str, let style, let action):
                        Button(action: action) {
                            styledText(str, style: style)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    func styledText(_ str: String, style: RichTextStyle) -> Text {
        var text = Text(str)
        if let font = style.font { text = text.font(font) }
        if let color = style.foregroundColor { text = text.foregroundColor(color) }
        if let weight = style.weight { text = text.fontWeight(weight) }
        if style.italic { text = text.italic() }
        if style.underline { text = text.underline() }
        return text
    }
}

/// One `RichTextBlock` is like a line or paragraph.
struct RichTextBlock: Identifiable {
    let id = UUID()
    var components: [RichTextComponent]
}

struct RichParagraphView: View {
    var blocks: [RichTextBlock]
    var lineSpacing: CGFloat = 6
    var alignment: TextAlignment = .leading

    var body: some View {
        VStack(alignment: .leading, spacing: lineSpacing) {
            ForEach(blocks) { block in
                TextFlowLayout(components: block.components)
            }
        }
        .multilineTextAlignment(alignment)
    }
}



#Preview {
  RichParagraph(
    components: [
        .text("By tapping ", style: .default),
        .link("Agree", style: .link, action: { print("Tapped Agree") }),
        .text(", you accept the ", style: .default),
        .link("Terms of Service", style: .link, action: { print("Tapped Terms") }),
        .text(".", style: .default)
    ],
    lineSpacing: 6,
    alignment: .leading
)

    RichParagraphView(blocks: [
    RichTextBlock(components: [
        .text("By continuing, you accept the "),
        .link("Terms of Service", action: { print("Tapped Terms") }),
        .text(" and "),
        .link("Privacy Policy", action: { print("Tapped Privacy") }),
        .text(".")
    ]),
    RichTextBlock(components: [
        .text("You can also "),
        .link("contact support", style: .link, action: { print("Tapped support") }),
        .text(" for assistance.")
    ])
])
}
