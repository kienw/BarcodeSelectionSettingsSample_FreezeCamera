/*
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import UIKit
import ScanditBarcodeCapture

struct Result {
    let data: String
    let symbology: Symbology
    let count: Int
}

class ScanViewController: UIViewController {

    private var context: DataCaptureContext {
        return SettingsManager.current.context
    }

    private var camera: Camera? {
        return SettingsManager.current.camera
    }

    private var captureView: DataCaptureView!
    
    private var barcodeTracking: BarcodeTracking!
    private var barcodeSelection: BarcodeSelection!
    private var barcodeTrackingOverlay: BarcodeTrackingBasicOverlay!
    private var barcodeSelectionOverlay: BarcodeSelectionBasicOverlay!

    @IBOutlet weak var freezeButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRecognition()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        barcodeTracking.isEnabled = true
        // Switch camera on to start streaming frames. The camera is started asynchronously and will take some time to
        // completely turn on.
        camera?.switch(toDesiredState: .on)
        
        // Use barcode tracking overlay as the default overlay.
        captureView.addOverlay(barcodeTrackingOverlay)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Switch camera off to stop streaming frames.
        barcodeSelection.isEnabled = false
        barcodeTracking.isEnabled = false
        camera?.switch(toDesiredState: .off)
    }

    deinit {
        // It is good practice to properly disable the mode.
        barcodeSelection.isEnabled = false
        barcodeSelection.removeListener(self)
        
        barcodeTracking.isEnabled = false
        barcodeTracking.removeListener(self)
    }
    
    @IBAction func freezeButtonTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        if sender.isSelected {
            // Barcode selection mode
            
            barcodeSelection.addListener(self)
            barcodeSelection.isEnabled = true
            
            captureView.removeOverlay(barcodeTrackingOverlay)
            captureView.addOverlay(barcodeSelectionOverlay)
            
            // Select the unselected barcodes and freeze the camera
            barcodeSelection.freezeCamera()
            barcodeSelection.selectUnselectedBarcodes()
        } else {
            // Barcode tracking mode
            
            barcodeTracking.isEnabled = true
            barcodeSelection.reset()
            barcodeSelection.removeListener(self)
            
            captureView.removeOverlay(barcodeSelectionOverlay)
            captureView.addOverlay(barcodeTrackingOverlay)
        }
    }
    
    private func setupRecognition() {
        let barcodeTrackingSettings = BarcodeTrackingSettings(scenario: .a)
        barcodeTrackingSettings.set(symbology: .qr, enabled: true)
        
        barcodeTracking = BarcodeTracking(context: context, settings: barcodeTrackingSettings)
        barcodeTracking.addListener(self)
        
        let barcodeSelectionSettings = BarcodeSelectionSettings()
        barcodeSelectionSettings.set(symbology: .qr, enabled: true)
        if barcodeSelectionSettings.selectionType is BarcodeSelectionTapSelection {
            let tapSelection: BarcodeSelectionTapSelection = barcodeSelectionSettings.selectionType as! BarcodeSelectionTapSelection
            tapSelection.shouldFreezeOnDoubleTap = false
        }
        
        barcodeSelection = BarcodeSelection(context: context, settings: barcodeSelectionSettings)
        
        barcodeTrackingOverlay = BarcodeTrackingBasicOverlay(barcodeTracking: barcodeTracking)
        barcodeTrackingOverlay.delegate = self
        
        barcodeSelectionOverlay = BarcodeSelectionBasicOverlay(barcodeSelection: barcodeSelection, style: .frame)
        barcodeSelectionOverlay.shouldShowHints = false

        // To visualize the on-going barcode selection process on screen, setup a data capture view that renders the
        // camera preview. The view must be connected to the data capture context.
        captureView = DataCaptureView(context: context, frame: view.bounds)
        captureView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        // Disable the zoom gesture.
        captureView.zoomGesture = nil
        view.addSubview(captureView)
        view.sendSubviewToBack(captureView)
    }
}

extension ScanViewController: BarcodeSelectionListener {
    func barcodeSelection(_ barcodeSelection: BarcodeSelection,
                          didUpdateSelection session: BarcodeSelectionSession,
                          frameData: FrameData?) {
    }
    
    func barcodeSelection(_ barcodeSelection: BarcodeSelection, didUpdate session: BarcodeSelectionSession, frameData: FrameData?) {
//        if frameData != nil {
//            barcodeSelection.freezeCamera()
//            barcodeSelection.selectUnselectedBarcodes()
//        }
    }
    
    func didStartObserving(_ barcodeSelection: BarcodeSelection) {
//        barcodeSelection.freezeCamera()
//        barcodeSelection.selectUnselectedBarcodes()
    }
}

extension ScanViewController: BarcodeTrackingListener {
    func barcodeTracking(_ barcodeTracking: BarcodeTracking, didUpdate session: BarcodeTrackingSession, frameData: FrameData) {
    }
}

extension ScanViewController: BarcodeTrackingBasicOverlayDelegate {
    func barcodeTrackingBasicOverlay(_ overlay: BarcodeTrackingBasicOverlay, brushFor trackedBarcode: TrackedBarcode) -> Brush? {
        return Brush(fill: .green, stroke: .green, strokeWidth: 1.0)
    }
    
    func barcodeTrackingBasicOverlay(_ overlay: BarcodeTrackingBasicOverlay, didTap trackedBarcode: TrackedBarcode) {
    }
}
