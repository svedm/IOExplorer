//
//  IORegistryPlane.swift
//  IOExplorer
//
//  Created by Svetoslav on 08.08.2023.
//

import Foundation

enum IORegistryPlane: Identifiable, CaseIterable {
    case service
    case power
    case deviceTree
    case audio
    case fireWire
    case usb

    var id: String {
        ioKitPlane
    }

    var ioKitPlane: String {
        switch self {
            case .service:
                return kIOServicePlane
            case .power:
                return kIOPowerPlane
            case .deviceTree:
                return kIODeviceTreePlane
            case .audio:
                return kIOAudioPlane
            case .fireWire:
                return kIOFireWirePlane
            case .usb:
                return kIOUSBPlane
        }
    }
}
