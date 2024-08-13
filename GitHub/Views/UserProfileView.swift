//
//  UserProfileView.swift
//  GitHub
//
//  Created by Akil Rafeek on 16/06/2024.
//

import SwiftUI

struct UserProfileView: View {
    @ObservedObject var viewModel: UserProfileViewModel
    @State private var note: String = ""
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var keyboard = KeyboardResponder()
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                RemoteImageView(urlString: viewModel.avatarUrl)
                    .frame(width: 200, height: 200)
                    .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                    .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                Spacer()
            }.padding()
            
            HStack {
                Spacer()
                Text("Followers: \(viewModel.followers)")
                Spacer()
                Text("Following: \(viewModel.following)")
                Spacer()
            }.padding()
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Name: \(viewModel.name)")
                    Text("Company: \(viewModel.company)")
                    Text("Blog: \(viewModel.blog)")
                }
                Spacer()
            }.padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(colorScheme == .dark ? Color.white : Color.black, lineWidth: 1)
                ).padding()
            
            Spacer()
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Notes:").padding([.leading], 15)
                    TextEditor(text: $note)
                        .frame(height: 150)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(colorScheme == .dark ? Color.white : Color.black, lineWidth: 1)
                        )
                        .padding()
                }
            }
            
            HStack(alignment: .center) {
                Spacer()
                Button("Save") {
                    viewModel.saveNote(note)
                }.padding()
                Spacer()
            }
            
        }
        .padding(.bottom, keyboard.currentHeight)
        .animation(.easeOut(duration: 0.16))
        .onAppear {
            viewModel.loadUserProfile()
            note = viewModel.note ?? ""
        }
        .onChange(of: viewModel.note) { newNote in
            note = newNote ?? ""
        }
        .overlay(
            ZStack {
                if viewModel.showSnackbar {
                    VStack {
                        Spacer()
                        Snackbar(message: viewModel.snackbarMessage, isSuccess: viewModel.isSuccessMessage)
                            .padding(.bottom, keyboard.currentHeight)
                    }
                    .padding(.bottom)
                    .transition(.move(edge: .bottom))
                    .animation(.easeInOut, value: viewModel.showSnackbar)
                }
            }, alignment: .bottom
        )
        .contentShape(Rectangle())
        .onTapGesture {
            dismissKeyboard()
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
        imageView.clipsToBounds = true
        return imageView
    }
    
    func updateUIView(_ uiView: UIImageView, context: Context) {
        guard let url = URL(string: urlString) else { return }
        
        ImageLoader.shared.loadImage(from: url) { image in
            uiView.image = image
        }
    }
}

struct Snackbar: View {
    var message: String
    var isSuccess: Bool
    
    var body: some View {
        Text(message)
            .padding(8)
            .background(isSuccess ? Color(UIColor.systemGreen) : Color(UIColor.systemRed))
            .foregroundColor(.white)
            .cornerRadius(8)
            .transition(.move(edge: .bottom))
    }
}

extension View {
    //function to dismiss keyboard
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
