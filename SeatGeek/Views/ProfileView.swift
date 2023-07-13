//
//  ProfileView.swift
//  SeatGeek
//
//  Created by Aayush Rattan on 2023-07-08.
//

import SwiftUI
import UIKit
import PhotosUI

struct ProfileView: View {
  @EnvironmentObject var authHelper:FirebaseAuthController
  @EnvironmentObject var dbHelper:FirestoreController
  @AppStorage("isLoggedIn") var isLoggedIn:Bool = false
  @AppStorage("loggedUser") var loggedUser:String = ""

  @State private var showingDeleteAlert = false
  @State private var deleteIndexSet:IndexSet?
  @State private var userName:String = "Lorem Ipsum"
  @State private var showingImagePicker:Bool = false
  @State private var inputImage: UIImage?
    
    private var imageURL:String {
        
        let formattedString = userName.replacingOccurrences(of: " ", with: "")
        
        return "https://api.multiavatar.com/\(formattedString).png?apikey=wYVkEXCNObPTpM"
    }
  var body: some View {
    NavigationStack {
      ZStack {
          Color("dark").ignoresSafeArea()
          VStack {
            HStack {
//              Image(systemName: "person.circle")
//                .resizable()
//                .frame(width: 90, height: 90)
//                .clipShape(Circle())
                
                
                        VStack {
                            
                            AsyncImage(url: URL(string: imageURL)) { phase in
                                switch phase {
                                case .empty:
                                    // Placeholder view or loading indicator
                                    Color.gray
                                case .success(let image):
                                    // Use the image view
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(maxWidth: 90, maxHeight: 90)
                                        .clipShape(Circle())
                                case .failure:
                                    // Error view
                                    Color.red
                                }
                            }

  
                                        
//                        AsyncImage(url: URL(string:imageURL))
//                                .frame(maxWidth: 90, maxHeight: 90)
//                                .clipShape(Circle())
//                                .imageScale(.small)
                                        
//                        if let inputImage = inputImage {
//                        Image(uiImage: inputImage)
//                                .resizable()
//                                .frame(width: 90, height: 90)
//                                .clipShape(Circle())
//                        } else {
//                            Image(systemName: "person.circle")
//                                .resizable()
//                                .frame(width: 90, height: 90)
//                                .clipShape(Circle())
//                        }
                    Button("Edit") {
                        showingImagePicker = true
                    }
                        .sheet(isPresented: $showingImagePicker) {
                            EditorImagePicker(image: $inputImage)
                        }
                                    }

              Spacer().frame(width: 30)
              VStack {
                Text(userName)
                  .font(.title)
                  .bold()
                  Text("You are attending \(self.dbHelper.favEventList.count) Event(s)")
                  .font(.subheadline)
              }.padding(.bottom, 22)
            }.padding(15)
            List {
              Section(header: Text("Friends List")) {

                  ForEach(self.dbHelper.friendList.indices, id: \.self) { index in
                      let user = self.dbHelper.friendList[index]
                      
                      NavigationLink(destination: FriendView(selectedUserIndex: index).environmentObject(self.dbHelper)) {
                          HStack {
                              Text("\(user.name)")
                                  .bold()
                          }
                      }
                  }

                .onDelete(perform: { indexSet in

                  deleteIndexSet = indexSet
                  showingDeleteAlert = true

                })  //onDelete

              }
            }.scrollContentBackground(.hidden)
              
            .alert(isPresented: $showingDeleteAlert) {
              Alert(
                title: Text("Delete Friend"),
                message: Text("Are you sure you want to delete this friend?"),
                primaryButton: .destructive(Text("Delete")) {
                  if let indexSet = deleteIndexSet {
                    for index in indexSet {
                      let friendToDelete = dbHelper.friendList[index]
                      dbHelper.deleteFriend(loggedUser: loggedUser, friendToDelete: friendToDelete)
                    }
                  }
                    
                    
                },
                secondaryButton: .cancel()
              )
            }

            Spacer()
          }
      }

      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: {
            isLoggedIn = false
            authHelper.signOut()
          }) {
            Text("Sign Out")
          }
        }
        ToolbarItem(placement: .navigationBarLeading) {
          NavigationLink(destination: SearchFriends()) {
            Image(systemName: "magnifyingglass")
            Text("Search Friends")
          }
        }
      }
      .onAppear {
        self.dbHelper.friendList.removeAll()
        self.dbHelper.getMyFriends(loggedUser: self.loggedUser)
        self.dbHelper.getSingleUser(email: self.loggedUser){user in
            
            if(user == nil){

                userName = "ERROR FETCH USERNAME"
            }else{

                userName = user!.name
            }


        }
      }
    }
  }
}

struct ProfileView_Previews: PreviewProvider {
  static var previews: some View {
    ProfileView()
  }
}

struct EditorImagePicker: UIViewControllerRepresentable{
    @Binding var image: UIImage?
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate{
        var parent: EditorImagePicker
        
        init(_ parent: EditorImagePicker){
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard let provider = results.first?.itemProvider else { return }
            
            if provider.canLoadObject(ofClass: UIImage.self){
                provider.loadObject(ofClass: UIImage.self){image, _ in
                    DispatchQueue.main.async {
                        self.parent.image = image as? UIImage
                    }
                }
            }
        }
        
    }
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        //configures ios to just be able to select images
        var config = PHPickerConfiguration()
        config.filter = .images
        
        //the view of picker
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        //leave empty for now
    }
}
