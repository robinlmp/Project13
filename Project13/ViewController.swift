//
//  ViewController.swift
//  Project13
//
//  Created by Robin Phillips on 06/02/2022.
//

import UIKit
import CoreImage

class ViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var intensity: UISlider!
    @IBOutlet var radius: UISlider!
    @IBOutlet var changeFilterButton: UIButton!
    
    var currentImage: UIImage!
    var context: CIContext!
    var currentFilter: CIFilter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Instafilter"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(importPicture))
        
        context = CIContext()
        currentFilter = CIFilter(name: "CISepiaTone")
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        dismiss(animated: true)
        currentImage = image
        
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        
        applyProcessing()
    }
    
    func applyProcessing() {
        let inputKeys = currentFilter.inputKeys
        
        if inputKeys.contains(kCIInputIntensityKey) { currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey) }
        if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(radius.value * 200, forKey: kCIInputRadiusKey) }
        if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(intensity.value * 10, forKey: kCIInputScaleKey) }
        if inputKeys.contains(kCIInputCenterKey) { currentFilter.setValue(CIVector(x: currentImage.size.width / 2, y: currentImage.size.height / 2), forKey: kCIInputCenterKey) }
        
        if let cgimg = context.createCGImage(currentFilter.outputImage!, from: currentFilter.outputImage!.extent) {
            let processedImage = UIImage(cgImage: cgimg)
            self.imageView.image = processedImage
        }
    }
    
    func setFilter(action: UIAlertAction) {
        print("current filter", currentFilter)
        print("action title", action.title)
        print("reconstructed filter name", reconstructFilterName(name: action.title!) )
        
        // make sure we have a valid image before continuing!
        guard currentImage != nil else { return }
        
        // safely read the alert action's title
        guard let actionTitle = action.title else { return }
        
        guard let filterNameCI = reconstructFilterName(name: actionTitle) else { return }
        currentFilter = CIFilter(name: filterNameCI )
        
        
        changeFilterButton.titleLabel?.text = filterName(name: filterNameCI)
        
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        
        applyProcessing()
    }
    
    func reconstructFilterName(name: String) -> String? {
//        var tempName = ""
        if !name.hasPrefix("CI") {
//            let ci = "CI"
            return name.components(separatedBy: " ").compactMap { $0 }.reduce("CI") { $0 + $1}
        }
        return nil
    }
    
    func filterName(name: String) -> String {
        let tempName = name
        var tempNameNoPrefix = tempName.deletingPrefix("CI")
        
        let capitalIndeces = findCapitalIndeces(str: tempNameNoPrefix)
        
        if capitalIndeces.isEmpty {
            // do nothing
        } else {
            for i in 0 ..< capitalIndeces.count {
                let indexOfCap = capitalIndeces[i]

                tempNameNoPrefix.insert(" ", at: tempNameNoPrefix.index(tempNameNoPrefix.startIndex, offsetBy: indexOfCap))
            }
        }
        return tempNameNoPrefix
    }
    
    
    func findCapitalIndeces(str: String) -> [Int] {
        var indexOfCapital = [Int]()
        var indexCount = 0
        
        for character in str {
            
            if indexCount == 0 {
                indexCount += 1
                continue
            } else if character.isUppercase {
                indexOfCapital.append(indexCount)
            }
            indexCount += 1
        }
        
        indexOfCapital.reverse()
        return indexOfCapital
    }




    
    @objc func importPicture() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    @IBAction func changeFilter(_ sender: Any) {
        let ac = UIAlertController(title: "Choose filter", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: filterName(name: "CIBumpDistortion"), style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: filterName(name: "CIGaussianBlur"), style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: filterName(name: "CIPixellate"), style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: filterName(name: "CISepiaTone"), style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: filterName(name: "CITwirlDistortion"), style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: filterName(name: "CIUnsharpMask"), style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: filterName(name: "CIVignette"), style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    @IBAction func saveButton(_ sender: Any) {
        guard let image = imageView.image else {
            let ac = UIAlertController(title: "There's no image to save!", message: nil, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
            return
        }
        
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @IBAction func intensityChanged(_ sender: Any) {
        applyProcessing()
    }
    
    @IBAction func radiusChanged(_ sender: Any) {
        applyProcessing()
    }
    
    
}


extension String {
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
}
