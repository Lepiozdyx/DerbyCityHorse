import SwiftUI

struct MainApp: View {
    @AppStorage("hasSeenTutor") private var hasSeenTutor = false

    var body: some View {
        if hasSeenTutor {
            ContentView()
        } else {
            Tutor()
        }
    }
}
