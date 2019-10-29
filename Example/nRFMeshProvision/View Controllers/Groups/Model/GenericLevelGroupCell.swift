//
//  GenericLevelGroupCell.swift
//  nRFMeshProvision_Example
//
//  Created by Aleksander Nowakowski on 28/08/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import nRFMeshProvision

class GenericLevelGroupCell: ModelGroupCell {
    
    // MARK: - Outlets and Actions
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var minusButton: UIButton!
    @IBAction func minusTapped(_ sender: UIButton) {
        sendGenericDeltaMessage(delta: -8192)
    }
    @IBOutlet weak var plusButton: UIButton!
    @IBAction func plusTapped(_ sender: UIButton) {
        sendGenericDeltaMessage(delta: +8192)
    }
    
    // MARK: - Implementation
    
    override func reload() {
        // On iOS 12.x tinted icons are initially black.
        // Forcing adjustment mode fixes the bug.
        icon.tintAdjustmentMode = .normal
        
        let numberOfDevices = models.count
        if numberOfDevices == 1 {
            title.text = "1 device"
        } else {
            title.text = "\(numberOfDevices) devices"
        }
        
        let localProvisioner = MeshNetworkManager.instance.meshNetwork?.localProvisioner
        let isEnabled = localProvisioner?.hasConfigurationCapabilities ?? false
        
        minusButton.isEnabled = isEnabled
        plusButton.isEnabled = isEnabled
    }
}

private extension GenericLevelGroupCell {
    
    func sendGenericDeltaMessage(delta: Int32) {
        let label = delta < 0 ? "Dimming..." : "Brightening..."
        delegate?.send(GenericDeltaSetUnacknowledged(delta: delta,
                                                     transitionTime: TransitionTime(1.0),
                                                     delay: 20), // 100 ms
                       description: label, using: applicationKey)
    }
    
}