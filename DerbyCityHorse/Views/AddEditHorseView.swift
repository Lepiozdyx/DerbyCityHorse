//
//  AddEditHorseView.swift
//  DerbyCityHorse
//
//  Created by test on 14.02.2026.
//

import SwiftUI
import PhotosUI

struct AddEditHorseView: View {
    private enum Field: Hashable {
        case name
        case breed
    }

    @Environment(\.dismiss) var dismiss
    @ObservedObject private var dataManager = DataManager.shared
    
    let horse: Horse?
    
    @State private var name: String = ""
    @State private var breed: String = ""
    @State private var dateOfBirth: Date = Date()
    @State private var selectedPhoto: UIImage?
    @State private var showingImagePicker = false
    @State private var showingDatePicker = false
    @FocusState private var focusedField: Field?
    
    init(horse: Horse?) {
        self.horse = horse
    }
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Header
                CustomHeaderView(title: horse == nil ? "Add Horse" : "Edit Horse", onBack: {
                    dismiss()
                })
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Photo Section
                        ZStack(alignment: .topTrailing) {
                            Button(action: {
                                playButtonSound()
                                showingImagePicker = true
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color(red: 0.945, green: 0.0, blue: 0.173), lineWidth: 1)
                                        .frame(width: 150, height: 150)
                                    
                                    if let photo = selectedPhoto {
                                        Image(uiImage: photo)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 150, height: 150)
                                            .clipped()
                                            .cornerRadius(16)
                                    } else {
                                        VStack(spacing: 8) {
                                            Image(systemName: "camera.fill")
                                                .font(.system(size: 50))
                                                .foregroundColor(Color(red: 0.945, green: 0.0, blue: 0.173))
                                            Text("Tap to add photo")
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundColor(Color(red: 0.133, green: 0.133, blue: 0.133))
                                        }
                                    }
                                }
                            }
                            
                            // Кнопка удаления фото (только когда есть фото)
                            if selectedPhoto != nil {
                                Button(action: {
                                    playButtonSound()
                                    selectedPhoto = nil
                                }) {
                                    ZStack {
                                        Circle()
                                            .fill(Color(red: 0.945, green: 0.0, blue: 0.173)) // #F1002C
                                            .frame(width: 20, height: 20)
                                        
                                        Image(systemName: "xmark")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                }
                                .offset(x: 5, y: -5)
                            }
                        }
                        .padding(.top, 20)
                        
                        // Name Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Name:")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.black)
                            
                            TextField("Horse name", text: $name)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.asciiCapable)
                                .submitLabel(.done)
                                .focused($focusedField, equals: .name)
                                .onSubmit {
                                    focusedField = nil
                                }
                                .textInputAutocapitalization(.never)
                                .padding(.horizontal, 4)
                        }
                        .padding(.horizontal, 20)
                        
                        // Breed Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Breed:")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.black)
                            
                            TextField("Breed", text: $breed)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.asciiCapable)
                                .submitLabel(.done)
                                .focused($focusedField, equals: .breed)
                                .onSubmit {
                                    focusedField = nil
                                }
                                .textInputAutocapitalization(.never)
                                .padding(.horizontal, 4)
                        }
                        .padding(.horizontal, 20)
                        
                        // Date of Birth Field
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Date of Birth:")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color(red: 0.133, green: 0.133, blue: 0.133)) // #222222
                                .padding(.bottom, 8)
                            
                            Button(action: {
                                playButtonSound()
                                showingDatePicker = true
                            }) {
                                HStack {
                                    Text(formatDate(dateOfBirth))
                                        .font(.system(size: 14, weight: .regular))
                                        .foregroundColor(Color(red: 0.133, green: 0.133, blue: 0.133)) // #222222
                                    
                                    Spacer()
                                    
                                    Image("t-1")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 20, height: 20)
                                }
                                .padding(.horizontal, 12)
                                .frame(width: 358, height: 30)
                                .background(Color(red: 0.922, green: 0.922, blue: 0.922)) // #EBEBEB
                                .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        
                        // Save Button
                        Button(action: {
                            playButtonSound()
                            saveHorse()
                        }) {
                            Text("Save")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(name.isEmpty || breed.isEmpty ? Color.gray : Color.red)
                                .cornerRadius(50)
                        }
                        .disabled(name.isEmpty || breed.isEmpty)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $selectedPhoto)
            }
            .overlay(Group {
                if showingDatePicker {
                    DatePickerBottomSheet(selectedDate: $dateOfBirth, isPresented: $showingDatePicker)
                }
            })
            .onAppear {
                if let horse = horse {
                    name = horse.name
                    breed = horse.breed
                    dateOfBirth = horse.dateOfBirth
                    if let photoData = horse.photoData {
                        selectedPhoto = UIImage(data: photoData)
                    }
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        focusedField = nil
                    }
                }
            }
        }
    }
    
    private func saveHorse() {
        let photoData = selectedPhoto?.jpegData(compressionQuality: 0.8)
        
        if let existingHorse = horse {
            var updatedHorse = existingHorse
            updatedHorse.name = name
            updatedHorse.breed = breed
            updatedHorse.dateOfBirth = dateOfBirth
            updatedHorse.photoData = photoData
            dataManager.updateHorse(updatedHorse)
        } else {
            let newHorse = Horse(
                name: name,
                breed: breed,
                dateOfBirth: dateOfBirth,
                photoData: photoData
            )
            dataManager.addHorse(newHorse)
        }
        
        dismiss()
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: date)
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
