import SwiftUI

struct BobmooChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            BobmooText(label, style: .body_m_15)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .foregroundStyle(isSelected ? .bobmooWhite : .bobmooBlack)
                .background(isSelected ? .bobmooBlack : .bobmooWhite)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HStack {
        BobmooChip(label: "학생식당", isSelected: true) {
            print("Selected")
        }
        
        BobmooChip(label: "교직원식당", isSelected: false) {
            print("Unselected")
        }
    }
    .padding()
    .background(.bobmooGray4)
}
