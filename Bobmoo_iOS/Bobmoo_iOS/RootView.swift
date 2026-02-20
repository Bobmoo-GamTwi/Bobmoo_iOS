import SwiftUI

struct RootView: View {
    private enum Route {
        case splash
        case home
    }

    @State private var route: Route = .splash
    @State private var homeViewModel = HomeViewModel(service: HomeAPIMenuService())

    var body: some View {
        ZStack {
            if route == .splash {
                SplashView(homeViewModel: homeViewModel) {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        route = .home
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .leading)))
            }

            if route == .home {
                HomeView(viewModel: homeViewModel)
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
            }
        }
        .animation(.easeInOut(duration: 0.35), value: route)
    }
}

#Preview {
    RootView()
}
