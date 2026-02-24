import SwiftUI

struct RootView: View {
    private enum Route {
        case search
        case splash
        case home
        case setting
    }

    let settings: AppSettings
    @State private var route: Route = .splash
    @State private var homeViewModel: HomeViewModel
    @State private var searchViewModel: SearchViewModel

    init(settings: AppSettings) {
        self.settings = settings
        self._homeViewModel = State(initialValue: HomeViewModel(service: HomeAPIMenuService(), settings: settings))
        self._searchViewModel = State(initialValue: SearchViewModel(service: SearchAPISchoolService(), settings: settings))
    }

    var body: some View {
        ZStack {
            if route == .search {
                SearchView(viewModel: searchViewModel) {
                    homeViewModel.resetForSchoolChange()
                    withAnimation(.easeInOut(duration: 0.35)) {
                        route = .home
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .leading)))
            }

            if route == .splash {
                SplashView(homeViewModel: homeViewModel) {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        route = settings.selectedSchool != nil ? .home : .search
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
                    homeViewModel.resetForSchoolChange()
                    withAnimation(.easeInOut(duration: 0.35)) {
                        route = .home
                    }
                }, onSearchSchool: {
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
    let settings = AppSettings()
    RootView(settings: settings)
        .environment(settings)
}
