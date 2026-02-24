import SwiftUI

struct RootView: View {
    private enum Route {
        case search
        case splash
        case home
        case setting
    }

    @State private var route: Route = .splash
    @State private var homeViewModel = HomeViewModel(service: HomeAPIMenuService())
    @State private var searchViewModel = SearchViewModel(service: SearchAPISchoolService())

    var body: some View {
        ZStack {
            if route == .search {
                SearchView(viewModel: searchViewModel) {
                    homeViewModel = HomeViewModel(service: HomeAPIMenuService())
                    withAnimation(.easeInOut(duration: 0.35)) {
                        route = .home
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .leading)))
            }

            if route == .splash {
                SplashView(homeViewModel: homeViewModel) {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        route = AppConfig.selectedSchool != nil ? .home : .search
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .leading)))
            }

            if route == .home {
                HomeView(viewModel: homeViewModel, onSetting: {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        route = .setting
                    }
                })
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
            }

            if route == .setting {
                SettingView(onBack: {
                    homeViewModel = HomeViewModel(service: HomeAPIMenuService())
                    withAnimation(.easeInOut(duration: 0.35)) {
                        route = .home
                    }
                }, onSearchSchool: {
                    searchViewModel = SearchViewModel(service: SearchAPISchoolService())
                    withAnimation(.easeInOut(duration: 0.35)) {
                        route = .search
                    }
                })
                .transition(.opacity.combined(with: .move(edge: .trailing)))
            }
        }
        .animation(.easeInOut(duration: 0.35), value: route)
    }
}

#Preview {
    RootView()
}
