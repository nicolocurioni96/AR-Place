//
//  Model.swift
//  AR Place
//
//  Created by Nicolò Curioni on 16/12/22.
//

import UIKit
import RealityKit
import Combine

class Model {
    var modelName: String?
    var image: UIImage?
    var modelEntity: ModelEntity?
    
    private var cancellable: AnyCancellable? = nil
    
    init(modelName: String) {
        self.modelName = modelName
        self.image = UIImage(named: modelName)
        
        let fileName = modelName + ".usdz"
        
        self.cancellable = ModelEntity.loadModelAsync(named: fileName)
            .sink(receiveCompletion: { loadCompletion in
                // Here, we have to handle the errors
                print("ERROR: Unable to load modelEntity for model with name: \(modelName)")
                
            }, receiveValue: { modelEntity in
                // Here we can get our modelEntity
                self.modelEntity = modelEntity
                
                print("⚪️ DEBUG: Succesfully loaded modelEntity for model with name: \(modelName)")
            })
    }
}
