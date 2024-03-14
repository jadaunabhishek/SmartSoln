import SwiftUI
import Firebase
import FirebaseStorage

struct PhotoDemo: View {
    @State private var image: Image?
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var downloadURL: URL?
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            if let image = image {
                image
                    .resizable()
                    .scaledToFit()
            } else {
                Button("Select Image") {
                    self.showingImagePicker = true
                }
                .padding()
            }

            Button("Retrieve Image") {
                downloadImage()
            }
            .disabled(image != nil)
            .padding()

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
            ImagePicker(image: self.$inputImage)
        }
    }

    func loadImage() {
        guard let inputImage = inputImage else { return }
        image = Image(uiImage: inputImage)
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

        let imageRef = storageRef.child("images/\(currentUser.uid)")

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

    func downloadImage() {
        guard let currentUser = Auth.auth().currentUser else {
            errorMessage = "User not authenticated."
            return
        }

        let storage = Storage.storage()
        let storageRef = storage.reference()
        let imageRef = storageRef.child("images/\(currentUser.uid)")

        imageRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
            guard let imageData = data, error == nil else {
                self.errorMessage = "Error downloading image: \(error?.localizedDescription ?? "Unknown error")"
                return
            }

            DispatchQueue.main.async {
                self.image = Image(uiImage: UIImage(data: imageData)!)
            }
        }
    }


}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }

            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct PhotoDemo_Previews: PreviewProvider {
    static var previews: some View {
        PhotoDemo()
    }
}
