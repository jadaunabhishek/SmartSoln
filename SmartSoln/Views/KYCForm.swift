import SwiftUI
import FirebaseDatabaseInternal
import Firebase
import FirebaseStorage

struct KYCForm: View {
    
    @State private var name: String = ""
    @State private var fatherName: String = ""
    @State private var gender: String = "Select"
    @State private var age: String = ""
    @State private var address: String = ""
    @State private var aadharNumber: String = ""
    @State private var dateOfBirth: Date = Date()
    
    @State private var showCameraPicker = false
    
    @State private var image: UIImage? // Changed type to UIImage
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var downloadURL: URL?
    @State private var errorMessage: String?
    
    let genders = ["Select", "Male", "Female", "Other"]
    
    var body: some View {
        NavigationView{
            Form {
                Section(header: Text("Personal Details")) {
                    TextField("Name", text: $name)
                    TextField("Father's Name", text: $fatherName)
                    
                    Picker("Gender", selection: $gender) {
                        ForEach(genders, id: \.self) { gender in
                            Text(gender)
                        }
                    }
                    
                    TextField("Age", text: $age)
                    
                    TextField("Address", text: $address)
                    
                    TextField("Aadhar Number", text: $aadharNumber)
                   
                }
                
                Section(header: Text("Upload Aadhar Card")) {
                    Button(action: {
                        self.showingImagePicker = true
                    }, label: {
                        Text("Tap to upload")
                    })
                }
                
                Section(header: Text("Live video KYC")) {
                    Button(action: {
                        self.showCameraPicker = true
                    }, label: {
                        Text("Tap to proceed")
                    })
                }
                
                Button(action: {
                    saveProfileData()
                }, label: {
                    Text("Save")
                })
            }
        }
        .sheet(isPresented: $showCameraPicker, onDismiss: loadUserImage) {
            CameraPickerView(image: self.$image) // Pass UIImage binding
        }
        
        .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
            ImagePicker(image: self.$inputImage)
        }
    }
    
    
    func saveProfileData() {
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }

        let userProfile = UserProfile(
            name: name,
            fatherName: fatherName,
            gender: gender,
            age: age,
            address: address,
            aadharNumber: aadharNumber
            )

        let databaseRef = Database.database().reference()
        let userPath = "customer/profile/\(userID)"

        databaseRef.child(userPath).setValue(userProfile.dictionaryRepresentation()) { (error, _) in
            if let error = error {
                print("Error saving profile data: \(error)")
            } else {
                print("Profile data saved successfully")
            }
        }
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        image = inputImage // Assign inputImage to image
        uploadImage()
    }
    
    func uploadImage() {
        guard let imageData = inputImage?.jpegData(compressionQuality: 0.5) else {
            errorMessage = "Could not convert image to data."
            return
        }

        let storage = Storage.storage()
        let storageRef = storage.reference()
        
        guard let currentUser = Auth.auth().currentUser else {
            errorMessage = "User not authenticated."
            return
        }

        let imageRef = storageRef.child("images/aadharcard/\(currentUser.uid)")

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        imageRef.putData(imageData, metadata: metadata) { (metadata, error) in
            guard let _ = metadata else {
                self.errorMessage = "Error uploading image: \(error?.localizedDescription ?? "Unknown error")"
                return
            }

            imageRef.downloadURL { (url, error) in
                if let error = error {
                    self.errorMessage = "Error getting download URL: \(error.localizedDescription)"
                } else {
                    self.downloadURL = url
                    print("Download URL: \(url?.absoluteString ?? "")")
                }
            }
        }
    }
    
    func loadUserImage() {
        guard let inputImage = inputImage else { return }
        image = inputImage // Assign inputImage to image
        uploadImage()
    }
    
    func uploadUserImage() {
        guard let imageData = inputImage?.jpegData(compressionQuality: 0.5) else {
            errorMessage = "Could not convert image to data."
            return
        }

        let storage = Storage.storage()
        let storageRef = storage.reference()
        
        guard let currentUser = Auth.auth().currentUser else {
            errorMessage = "User not authenticated."
            return
        }

        let imageRef = storageRef.child("images/userphoto/\(currentUser.uid)")

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        imageRef.putData(imageData, metadata: metadata) { (metadata, error) in
            guard let _ = metadata else {
                self.errorMessage = "Error uploading image: \(error?.localizedDescription ?? "Unknown error")"
                return
            }

            imageRef.downloadURL { (url, error) in
                if let error = error {
                    self.errorMessage = "Error getting download URL: \(error.localizedDescription)"
                } else {
                    self.downloadURL = url
                    print("Download URL: \(url?.absoluteString ?? "")")
                }
            }
        }
    }
}


struct CameraPickerView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraPickerView

        init(_ parent: CameraPickerView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<CameraPickerView>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<CameraPickerView>) {

    }
}




struct UserProfile {
    var name: String
    var fatherName: String
    var gender: String
    var age: String
    var address: String
    var aadharNumber: String
    
    // Add this method to convert the user profile to a dictionary
        func dictionaryRepresentation() -> [String: Any] {
            return [
                "name": name,
                "fatherName": fatherName,
                "gender": gender,
                "age": age,
                "address": address,
                "aadharNumber": aadharNumber
            ]
        }
}

#Preview {
    KYCForm()
}
