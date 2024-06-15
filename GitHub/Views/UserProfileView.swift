//
//  UserProfileView.swift
//  GitHub
//
//  Created by Rizwan Rafeek on 16/06/2024.
//

import SwiftUI

struct UserProfileView: View {
    
//    var username: String?
//    var userId: String?
    @StateObject var viewModel: UserProfileViewModel
    @Environment(\.colorScheme) var colorScheme
    
    init(username: String, userId: Int16) {
        _viewModel = StateObject(wrappedValue: UserProfileViewModel(username: username, userId: userId))
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                RemoteImageView(urlString: viewModel.userProfile?.value(forKey: "avatarUrl") as? String ?? "")
                    .frame(width: 200, height: 200)
                    .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                Spacer()
            }.padding()
            
            HStack {
                Spacer()
                Text("Followers: \(viewModel.userProfile?.value(forKey: "followers") as? Int ?? 0)")
                Spacer()
                Text("Following: \(viewModel.userProfile?.value(forKey: "following") as? Int ?? 0)")
                Spacer()
            }.padding()
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Name: \(viewModel.userProfile?.value(forKey: "login") as? String ?? "-")")
                    Text("Company: \(viewModel.userProfile?.value(forKey: "company") as? String ?? "-")")
                    Text("Blog: \(viewModel.userProfile?.value(forKey: "blog") as? String ?? "-")")
                }
                Spacer()
            }.padding()
                .border(colorScheme == .dark ? Color.white : Color.black, width: 1).padding()
            
            Spacer()
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Notes:").padding()
                    TextEditor(text: $viewModel.inputNote)
                        .border(colorScheme == .dark ? Color.white : Color.black, width: 1)
                        .padding()
                }
            }
            
            HStack(alignment: .center) {
                Spacer()
                Button("Save") {
                    viewModel.saveNoteToLocal()
                }.padding()
                Spacer()
            }
            
        }
        .onAppear {
            viewModel.fetchUserProfile()
//            viewModel.loadNoteFromLocal()
        }
    }
}

//#Preview {
//    UserProfileView()
//}

struct RemoteImageView: UIViewRepresentable {
    let urlString: String
    
    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        return imageView
    }
    
    func updateUIView(_ uiView: UIImageView, context: Context) {
        ImageLoader.loadImage(from: urlString, into: uiView)
    }
}
