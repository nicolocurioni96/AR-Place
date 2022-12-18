//
//  ContentView.swift
//  AR Place
//
//  Created by Nicolò Curioni on 16/12/22.
//

import SwiftUI
import RealityKit
import ARKit
import FocusEntity

struct ContentView: View {
    
    @State private var isPlacementEnabled = false
    @State private var selectedModel: Model?
    @State private var modelConfirmedForPlacement: Model?
    
    private var models: [Model] {
        let fileManager = FileManager.default
        
        guard let path = Bundle.main.resourcePath,
              let files = try?
                fileManager.contentsOfDirectory(atPath: path)
        else {
            return []
        }
        
        var availableModels: [Model] = []
        
        for fileName in files where fileName.hasSuffix("usdz") {
            let modelName = fileName.replacingOccurrences(of: ".usdz", with: "")
            let model = Model(modelName: modelName)
            
            availableModels.append(model)
        }
        
        return availableModels
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ARViewContainer(
                modelConfirmedForPlacement: $modelConfirmedForPlacement)
            
            if self.isPlacementEnabled {
                PlacementButtonsView(
                    isPlacementEnabled: self.$isPlacementEnabled,
                    selectedModel:  self.$selectedModel,
                    modelConfirmedForPlacement: self.$modelConfirmedForPlacement)
                
            } else {
                ModelPickerView(
                    isPlacementEnabled: self.$isPlacementEnabled,
                    selectedModel: self.$selectedModel,
                    models: self.models)
            }
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    @Binding var modelConfirmedForPlacement: Model?
    
    func makeUIView(context: Context) -> ARView {
        let arView = CustomARView(frame: .zero)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        if let model = self.modelConfirmedForPlacement {
            if let modelEntity = model.modelEntity {
                let anchorEntity = AnchorEntity(plane: .any)
                
                anchorEntity.addChild(modelEntity.clone(recursive: true))
                uiView.scene.addAnchor(anchorEntity)
                
            } else {
                print("🔴 ERROR - Unable to load the modelEntity - \(String(describing: model.modelName))")
            }
            
            DispatchQueue.main.async {
                self.modelConfirmedForPlacement = nil
            }
        }
    }
}

class CustomARView: ARView {
    
    let focusSquare = FESquare()
    
    required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        
        focusSquare.viewDelegate = self
        focusSquare.delegate = self
        focusSquare.setAutoUpdate(to: true)
        
        self.setupARView()
    }
    
    @objc required dynamic init?(coder decoder: NSCoder) {
        fatalError("init(frame:) has not been implemented")
    }
    
    func setupARView() {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
        }
        
        self.session.run(config)
    }
}

extension CustomARView: FEDelegate {
    func toTrackingState() {
        print("🧐 STATUS - Tracking")
    }
    
    func toInitializingState() {
        print("🟠 STATUS - Initalizing")
    }
}


struct ModelPickerView: View {
    @Binding var isPlacementEnabled: Bool
    @Binding var selectedModel: Model?
    
    var models: [Model]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(0..<self.models.count) { index in
                    Button(action: {
                        self.isPlacementEnabled = true
                        self.selectedModel = self.models[index]
                        print("⚠️ DEBUG - Selected Model - \(self.models[index].modelName)")
                    }, label: {
                        Image(uiImage: self.models[index].image ?? UIImage())
                            .resizable()
                            .frame(height: 80)
                            .aspectRatio(1 / 1, contentMode: .fit)
                            .background(Color.white.opacity(0.5))
                            .cornerRadius(13)
                    }).buttonStyle(PlainButtonStyle())
                    
                }
            }
        }
        .padding(20)
        .background(Color.gray.opacity(0.2))
    }
}

struct PlacementButtonsView: View {
    @Binding var isPlacementEnabled: Bool
    @Binding var selectedModel: Model?
    @Binding var modelConfirmedForPlacement: Model?
    
    var body: some View {
        HStack {
            Button {
                self.resetPlacementParameters()
                
                print("⚠️ DEBUG - Cancel Model Placement")
            } label: {
                Image(systemName: "xmark")
                    .frame(width: 60, height: 60)
                    .font(.title)
                    .background(Color.white.opacity(0.75))
                    .cornerRadius(30)
                    .padding(20)
            }
            
            Button {
                self.modelConfirmedForPlacement = self.selectedModel
                self.resetPlacementParameters()
                
                print("⚠️ DEBUG - Confirmed Model Placement")
            } label: {
                Image(systemName: "checkmark")
                    .frame(width: 60, height: 60)
                    .font(.title)
                    .background(Color.white.opacity(0.75))
                    .cornerRadius(30)
                    .padding(20)
            }
        }
    }
    
    func resetPlacementParameters() {
        self.isPlacementEnabled = false
        self.selectedModel = nil
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
