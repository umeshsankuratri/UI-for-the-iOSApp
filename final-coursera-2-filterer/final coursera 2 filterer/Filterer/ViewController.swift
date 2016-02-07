//
//  ViewController.swift
//  Filterer
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var filteredImage: UIImage?
    let image = UIImage(named: "scenery")!
    
    
    
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var filteredImageView: UIImageView!
    
    @IBOutlet var secondaryMenu: UIView!
    
    @IBOutlet var bottomMenu: UIView!
    
    // Edit button giving access to the slider
    @IBOutlet var editMenu: UIView!
    @IBOutlet var sliderButton: UISlider!
    
    @IBOutlet var filterButton: UIButton!
    
    @IBOutlet var compareButton: UIButton!
    
    @IBOutlet var editButton: UIButton!
    
    // Secondary menu buttons
    @IBOutlet var redButton: UIButton!              // Will increase the red
    
    @IBOutlet var greenButton: UIButton!            // Will increase the green
    
    @IBOutlet var blueButton: UIButton!            // Will increase the blue
    
    @IBOutlet var brightButton: UIButton!            // Will increase brightness
    
    @IBOutlet var greyButton: UIButton!            // Will convert to greyscale
    
    
    @IBOutlet var toggleButton: UIButton!           // Place a transparent button on top of the image to allow to toggle between original and filtered images
    
    @IBOutlet var infoImage: UILabel!               // Label used to diplay "Original" if the original image is being displayed
    
    class Filter {                                  // Define a filter with a Lower and Upper multiplier for each color of the pixel and a set of filters
    var filterType: String
    var redUp: Int
    var redLow : Int
    var greenUp : Int
    var greenLow : Int
    var blueUp : Int
    var blueLow : Int
    
    required init (filterType: String, redUp : Int, redLow : Int, greenUp : Int, greenLow : Int, blueUp : Int, blueLow : Int) {
    self.filterType = filterType
    self.redUp = redUp
    self.redLow = redLow
    self.greenUp = greenUp
    self.greenLow = greenLow
    self.blueUp = blueUp
    self.blueLow = blueLow
    }
    convenience init () {                                                                                   // Init non-defined parameters to 1
    self.init (filterType: "noFilter", redUp : 1, redLow : 1, greenUp : 1, greenLow : 1, blueUp : 1, blueLow : 1)
    }
    func increaseContrast (rgbaImage: RGBAImage) -> UIImage {                                          // Filter seen during the course
    
    // first calculate the total for each color
    var totalRed = 0
    var totalGreen = 0
    var totalBlue = 0
    
    
    for y in 0..<rgbaImage.height {
    for x in 0..<rgbaImage.width {
    let index = y * rgbaImage.width + x
    var pixel = rgbaImage.pixels[index]
    
    totalRed += Int(pixel.red)
    totalGreen += Int(pixel.green)
    totalBlue += Int(pixel.blue)
    }
    }
    
    // Compute average  for each color
    let pixelCount = rgbaImage.width * rgbaImage.height    // Total number of pixels in the image
    let avgRed = totalRed / pixelCount
    let avgBlue = totalBlue / pixelCount
    let avgGreen = totalGreen / pixelCount
    let sum = avgBlue + avgRed + avgGreen
    
    // Apply the filter for each pixel
    for y in 0..<rgbaImage.height {
    for x in 0..<rgbaImage.width {
    let index = y * rgbaImage.width + x
    var pixel = rgbaImage.pixels[index]
    
    // For each pixel, calculate the difference with the average
    let redDelta = Int(pixel.red) - avgRed
    let greenDelta = Int(pixel.green) - avgGreen
    let blueDelta = Int(pixel.blue) - avgBlue
    
    var modifierRed = redUp
    var modifierBlue = blueUp
    var modifierGreen = greenUp
    
    if (Int(pixel.red)+Int(pixel.green)+Int(pixel.blue) < sum){
    modifierRed = redLow
    modifierBlue = blueLow
    modifierGreen = greenLow
    }
    
    pixel.red = UInt8(max(min(255,avgRed + 5 * redDelta),0))
    pixel.green = UInt8(max(min(255,avgGreen + 5 * greenDelta),0))
    pixel.blue = UInt8(max(min(255,avgBlue + 5 * blueDelta),0))
    
    rgbaImage.pixels[index] = pixel
    
    }
    }
    let newImage = rgbaImage.toUIImage()!
    return newImage
    }
    
    
    func convertToGreyScale (rgbaImage : RGBAImage) -> UIImage {                   // Convert an image to grey scale (no parameters needed here)
    // Apply the filter for each pixel
    for y in 0..<rgbaImage.height {
    for x in 0..<rgbaImage.width {
    let index = y * rgbaImage.width + x
    var pixel = rgbaImage.pixels[index]
    // Calculate the average of the three channels for each pixel
    let red = Int(pixel.red)
    let green = Int(pixel.green)
    let blue = Int(pixel.blue)
    
    let avgCol = (red + green + blue)/3
    
    
    pixel.red = UInt8(max(min(255,avgCol),0))
    pixel.green = UInt8(max(min(255,avgCol),0))
    pixel.blue = UInt8(max(min(255,avgCol),0))
    
    rgbaImage.pixels[index] = pixel
    }
    }
    let newImage = rgbaImage.toUIImage()!
    return newImage
    
    }
    
    func increaseBright (rgbaImage : RGBAImage) -> UIImage {                                   // Increase brightness by % - Low values are not used
    // Apply the filter for each pixel
    for y in 0..<rgbaImage.height {
    for x in 0..<rgbaImage.width {
    let index = y * rgbaImage.width + x
    var pixel = rgbaImage.pixels[index]
    
    let red = Int(pixel.red)
    let green = Int(pixel.green)
    let blue = Int(pixel.blue)
    
    pixel.red = UInt8(max(min(255,red*(1+redUp/100)),0))
    pixel.green = UInt8(max(min(255,green*(1+greenUp/100)),0))
    pixel.blue = UInt8(max(min(255,blue*(1+blueUp/100)),0))
    
    rgbaImage.pixels[index] = pixel
    }
    }
    let newImage = rgbaImage.toUIImage()!
    return newImage
    }
    
    func noFilter (rgbaImage : RGBAImage) -> UIImage {                                   // No process
    let newImage = rgbaImage.toUIImage()!
    return newImage
    }
    
    }
    
    
    class imageProcessor {
    
    var filters : [Filter]
    
    required init (filters : [Filter]) {
    self.filters = filters
    }
    
    
    func applyFilter (rgbaImage : RGBAImage) -> UIImage {
    for filter in filters {
    switch filter.filterType {
case "increaseContrast":
    _ = filter.increaseContrast(rgbaImage)
case "convertToGreyScale":
    _ = filter.convertToGreyScale(rgbaImage)
case "increaseBright":
    _ = filter.increaseBright(rgbaImage)
default:
    _ = filter.noFilter(rgbaImage)
    
    }
    }
    let newImage = rgbaImage.toUIImage()!
    return newImage
    }
    
    func applyStdFilter (filterName : String, rgbaImage : RGBAImage) -> UIImage {
    switch filterName {
case "BrightnessX2":
    let filter = Filter(filterType: "increaseBright", redUp: 100, redLow: 0, greenUp: 100, greenLow: 0, blueUp: 100, blueLow: 0)
_ = filter.increaseBright(rgbaImage)
case "RedX2":
    let filter = Filter(filterType: "increaseBright", redUp: 100, redLow: 0, greenUp: 0, greenLow: 0, blueUp: 0, blueLow: 0)
_ = filter.increaseBright(rgbaImage)
case "GreenX2":
    let filter = Filter(filterType: "increaseBright", redUp: 0, redLow: 0, greenUp: 100, greenLow: 0, blueUp: 0, blueLow: 0)
_ = filter.increaseBright(rgbaImage)
case "BlueX2":
    let filter = Filter(filterType: "increaseBright", redUp: 0, redLow: 0, greenUp: 0, greenLow: 0, blueUp: 100, blueLow: 0)
_ = filter.increaseBright(rgbaImage)
case "ContrastX2":
    let filter = Filter(filterType: "increaseContrast", redUp: 100, redLow: 0, greenUp: 0, greenLow: 0, blueUp: 0, blueLow: 0)
_ = filter.increaseBright(rgbaImage)
case "GreyScale":
    let filter = Filter(filterType: "convertToGreyScale", redUp: 0, redLow: 0, greenUp: 0, greenLow: 0, blueUp: 0, blueLow: 0)
_ = filter.convertToGreyScale(rgbaImage)
default:
    let filter = Filter(filterType: "noFilter", redUp: 2, redLow: 2, greenUp: 2, greenLow: 2, blueUp: 2, blueLow: 2)
_ = filter.noFilter(rgbaImage)
    }
    let newImage = rgbaImage.toUIImage()!
    return newImage
    }
    }
    
    
    
    
    
    override func viewDidLoad() {
    super.viewDidLoad()
    secondaryMenu.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
    secondaryMenu.translatesAutoresizingMaskIntoConstraints = false
    editMenu.translatesAutoresizingMaskIntoConstraints = false
    
    // Disable buttons if no filter has been applied
    compareButton.enabled = false
    toggleButton.enabled = false
    editButton.enabled = false
    
    filteredImageView.alpha = 0
    imageView.alpha = 1
    
    }
    
    // MARK: Share
    @IBAction func onShare(sender: AnyObject) {
    let activityController = UIActivityViewController(activityItems: ["Check out our really cool app", filteredImageView.image!], applicationActivities: nil)
    presentViewController(activityController, animated: true, completion: nil)
    }
    
    // MARK: New Photo
    @IBAction func onNewPhoto(sender: AnyObject) {
    let actionSheet = UIAlertController(title: "New Photo", message: nil, preferredStyle: .ActionSheet)
    
    actionSheet.addAction(UIAlertAction(title: "Camera", style: .Default, handler: { action in
    self.showCamera()
    }))
    
    actionSheet.addAction(UIAlertAction(title: "Album", style: .Default, handler: { action in
    self.showAlbum()
    }))
    
    actionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
    
    self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func showCamera() {
    let cameraPicker = UIImagePickerController()
    cameraPicker.delegate = self
    cameraPicker.sourceType = .Camera
    
    presentViewController(cameraPicker, animated: true, completion: nil)
    }
    
    func showAlbum() {
    let cameraPicker = UIImagePickerController()
    cameraPicker.delegate = self
    cameraPicker.sourceType = .PhotoLibrary
    
    presentViewController(cameraPicker, animated: true, completion: nil)
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    dismissViewControllerAnimated(true, completion: nil)
    if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
    imageView.image = image
    }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Filter Menu
    @IBAction func onFilter(sender: UIButton) {
    if (sender.selected) {
    hideSecondaryMenu()
    sender.selected = false
} else {
    showSecondaryMenu()
    sender.selected = true
    }
    }
    
    func showSecondaryMenu() {
    view.addSubview(secondaryMenu)
    
    hideEditMenu()
    editButton.selected = false
    
    
    let bottomConstraint = secondaryMenu.bottomAnchor.constraintEqualToAnchor(bottomMenu.topAnchor)
    let leftConstraint = secondaryMenu.leftAnchor.constraintEqualToAnchor(view.leftAnchor)
    let rightConstraint = secondaryMenu.rightAnchor.constraintEqualToAnchor(view.rightAnchor)
    
    let heightConstraint = secondaryMenu.heightAnchor.constraintEqualToConstant(44)
    
    NSLayoutConstraint.activateConstraints([bottomConstraint, leftConstraint, rightConstraint, heightConstraint])
    
    view.layoutIfNeeded()
    
    self.secondaryMenu.alpha = 0
    UIView.animateWithDuration(0.4) {
    self.secondaryMenu.alpha = 1.0
    }
    }
    
    func hideSecondaryMenu() {
    UIView.animateWithDuration(0.4, animations: {
    self.secondaryMenu.alpha = 0
    }) { completed in
    if completed == true {
    self.secondaryMenu.removeFromSuperview()
    }
    }
    }
    
    @IBAction func onRed(sender: UIButton) {
    
    let setOfFilters : [Filter] = []
    let process = imageProcessor(filters: setOfFilters)
    
    let rgbaImage = RGBAImage(image:image)!
    
    let result = process.applyStdFilter("RedX2",rgbaImage: rgbaImage)
    
    // Allows to retrive the filter thqt has been applied and to only increase the target colour or brightness
    redButton.selected = true
    greenButton.selected = false
    blueButton.selected = false
    brightButton.selected = false
    greyButton.selected = false
    
    filteredImage = result
    showFilteredImage()
    compareButton.selected = false          // Forces the button to be deselected
    compareButton.enabled = true            // Enables the "Show Original" to be selected
    toggleButton.enabled = true             // Enables the toggle when touching the image
    editButton.enabled = true               // Enables the edit menu to change intensity
    
    }
    @IBAction func onBlue(sender: UIButton) {
    let setOfFilters : [Filter] = []
    let process = imageProcessor(filters: setOfFilters)
    
    let rgbaImage = RGBAImage(image:image)!
    
    let result = process.applyStdFilter("BlueX2",rgbaImage: rgbaImage)
    
    redButton.selected = false
    greenButton.selected = false
    blueButton.selected = true
    brightButton.selected = false
    greyButton.selected = false
    
    filteredImage = result
    showFilteredImage()
    compareButton.selected = false
    compareButton.enabled = true
    toggleButton.enabled = true
    editButton.enabled = true
    }
    
    @IBAction func onGreen(sender: UIButton) {
    let setOfFilters : [Filter] = []
    let process = imageProcessor(filters: setOfFilters)
    
    let rgbaImage = RGBAImage(image:image)!
    
    let result = process.applyStdFilter("GreenX2",rgbaImage: rgbaImage)
    
    redButton.selected = false
    greenButton.selected = true
    blueButton.selected = false
    brightButton.selected = false
    greyButton.selected = false
    
    
    filteredImage = result
    showFilteredImage()
    compareButton.selected = false
    compareButton.enabled = true
    toggleButton.enabled = true
    editButton.enabled = true
    }
    
    @IBAction func onBright(sender: UIButton) {
    let setOfFilters : [Filter] = []
    let process = imageProcessor(filters: setOfFilters)
    
    let rgbaImage = RGBAImage(image:image)!
    
    let result = process.applyStdFilter("BrightnessX2",rgbaImage: rgbaImage)
    
    redButton.selected = false
    greenButton.selected = false
    blueButton.selected = false
    brightButton.selected = true
    greyButton.selected = false
    
    
    filteredImage = result
    showFilteredImage()
    
    compareButton.selected = false
    compareButton.enabled = true
    toggleButton.enabled = true
    editButton.enabled = true
    }
    
    @IBAction func onGrey(sender: UIButton) {
    let setOfFilters : [Filter] = []
    let process = imageProcessor(filters: setOfFilters)
    
    let rgbaImage = RGBAImage(image:image)!
    
    let result = process.applyStdFilter("GreyScale",rgbaImage: rgbaImage)
    
    redButton.selected = false
    greenButton.selected = false
    blueButton.selected = false
    brightButton.selected = false
    greyButton.selected = true
    
    filteredImage = result
    showFilteredImage()
    
    compareButton.selected = false
    compareButton.enabled = true
    toggleButton.enabled = true
    editButton.enabled = false                  // Disable editing of grey filter (just to make thing easier)
    
    }
    
    @IBAction func onCompare(sender: UIButton) {
    if (sender.selected) {
    showFilteredImage()
    sender.selected = false
} else {
    showOriginalImage()
    sender.selected = true
    }
    }
    
    
    @IBAction func touchToggle(sender: UIButton) {
    if (compareButton.selected == false) {
    showOriginalImage()
    }
    }
    
    
    @IBAction func releaseToggle(sender: UIButton) {
    if (compareButton.selected == false) {
    showFilteredImage()
    }
    
    }
    
    @IBAction func onEdit(sender: UIButton) {
    if (sender.selected) {
    hideEditMenu()
    sender.selected = false
} else {
    showEditMenu()
    sender.selected = true
    }
    
    }
    
    func showEditMenu() {
    view.addSubview(editMenu)
    
    hideSecondaryMenu()
    filterButton.selected = false
    
    let bottomConstraint = editMenu.bottomAnchor.constraintEqualToAnchor(bottomMenu.topAnchor)
    let leftConstraint = editMenu.leftAnchor.constraintEqualToAnchor(view.leftAnchor)
    let rightConstraint = editMenu.rightAnchor.constraintEqualToAnchor(view.rightAnchor)
    
    let heightConstraint = editMenu.heightAnchor.constraintEqualToConstant(44)
    
    NSLayoutConstraint.activateConstraints([bottomConstraint, leftConstraint, rightConstraint, heightConstraint])
    
    view.layoutIfNeeded()
    
    self.editMenu.alpha = 0
    UIView.animateWithDuration(0.4) {
    self.editMenu.alpha = 1.0
    }
    }
    
    func hideEditMenu() {
    sliderButton.value = 0.5
    
    UIView.animateWithDuration(0.4, animations: {
    self.editMenu.alpha = 0
    }) { completed in
    if completed == true {
    self.editMenu.removeFromSuperview()
    }
    }
    }
    
    
    @IBAction func onSliderChange(sender: UISlider) {
    
    let intensity = Int(sliderButton.value * 500)
    
    // compute filter value depending on the active filter
    // No editing when converted to grey scale
    let red = (Int(redButton.selected)+Int(brightButton.selected)) * intensity
    let green = (Int(greenButton.selected)+Int(brightButton.selected)) * intensity
    let blue = (Int(blueButton.selected)+Int(brightButton.selected)) * intensity
    
    
    // Create the filter (type and values)
    let filter = Filter(filterType: "increaseBright", redUp: red, redLow: 0, greenUp: green, greenLow: 0, blueUp: blue, blueLow: 0)
    
    let setOfFilters : [Filter] = [filter]
    let process = imageProcessor(filters: setOfFilters)
    
    
    // Take back the original image and process it with new filter
    let rgbaImage = RGBAImage(image:image)!
    
    let result = process.applyFilter(rgbaImage)
    
    filteredImage = result
    filteredImageView.image = filteredImage
    compareButton.selected = false
    compareButton.enabled = true
    toggleButton.enabled = true
    
    }
    
    
    func showOriginalImage() {
    
    imageView.image = image
    UIView.animateWithDuration(0.5) {
    self.filteredImageView.alpha = 0.0
    }
    
    infoImage.text = "Original"
    }
    func showFilteredImage() {
    
    filteredImageView.image = filteredImage
    UIView.animateWithDuration(0.5) {
    self.filteredImageView.alpha = 1.0
    }
    infoImage.text = ""
    }
    
    
}

