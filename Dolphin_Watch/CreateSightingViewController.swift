//
//  CreateSightingViewController.swift
//  Dolphin_Watch
//
//  Created by Nathaniel Okun on 6/5/15.
//  Copyright (c) 2015 Nathaniel Okun. All rights reserved.
//

import UIKit

class CreateSightingViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate {


    @IBOutlet weak var speciesTextField: UITextField!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var groupSizeLabel: UILabel!
    @IBOutlet weak var groupSizeStepper: UIStepper!
    @IBOutlet weak var animalPicture: UIImageView!
    
    var imagePicker: UIImagePickerController!
    var location: CLLocationCoordinate2D!
    let textViewPrompt = "e.g where the animal was heading, what it was doing etc."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSteppers()
        addTextViewBorder()
        notesTextView.delegate = self

        // Do any additional setup after loading the view.
    }
    

    
    func addTextViewBorder() {
        notesTextView.layer.borderColor = UIColor(red: 204.0/255, green: 204.0/255, blue: 204.0/255, alpha: 0.8).CGColor
        notesTextView.layer.borderWidth = 1.0
        notesTextView.layer.cornerRadius = 5.0
    }
    
    //Sets steppers fields
    func setUpSteppers() {
        groupSizeStepper.autorepeat = true
        groupSizeStepper.minimumValue = 0
        groupSizeStepper.value = 3
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Gets keyboard to dismiss when we click outside of text field
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    @IBAction func cameraRollButtonPressed(sender: AnyObject) {
        setImagePickerTypes(.PhotoLibrary)
        presentViewController(imagePicker, animated: true, completion: nil)
        
    }
    //Takes a picture when the camera button is pressed
    @IBAction func cameraButtonPressed(sender: AnyObject) {
        setImagePickerTypes(.Camera)
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    //Sets the delegate and source type for the image picker. Used when camera or camera roll button pressed.
    func setImagePickerTypes(sourceType: UIImagePickerControllerSourceType) {
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
    }
    
    //Picture chosen/taken
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        animalPicture.image = info[UIImagePickerControllerOriginalImage] as? UIImage
    }
    
    @IBAction func backButtonClicked(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    //Saves data that was entered
    @IBAction func doneButtonClicked(sender: AnyObject) {
        let groupSize = groupSizeLabel.text!.toInt()!   //Will always be a valid number
        var animalType = speciesTextField.text
        if animalType == "" {
            animalType = "Unspecified"
        }
        
        var notes = notesTextView.text
        if notes == textViewPrompt {
            notes = ""
        }
        
        var photoData = UIImageJPEGRepresentation(animalPicture.image!, 0.50)
        var imageFile = PFFile(data: photoData)
        
        
        ParseStore.sharedInstance.saveSighting(groupSize: groupSize, location: location, animalType: animalType, notes: notes, imageFile: imageFile)
        dismissViewControllerAnimated(true, completion: nil)
    }

    //Controls UIStepper
    @IBAction func groupSizeChanged(sender: UIStepper) {
        groupSizeLabel.text = Int(sender.value).description
    }
    
//TEXTVIEW DELEGATE METHODS
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        if notesTextView.text == textViewPrompt {
            notesTextView.text = ""
        }
        
        return true
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if notesTextView.text == "" {
            notesTextView.text = textViewPrompt
        }
    }
//END OF TEXTVIEW DELEGATE METHODS
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
