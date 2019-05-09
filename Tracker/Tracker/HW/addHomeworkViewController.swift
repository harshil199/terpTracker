import UIKit

class addHomeworkViewController: UIViewController {
    
    @IBOutlet weak var assignmentName: UITextField!
    
    @IBOutlet weak var newAssignment: UIButton!
    
    
    
    @IBAction func cancelAction(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)

    }
    @IBAction func newAssignmentAction(_ sender: Any) {
        let name = assignmentName.text!
        let date = dateTextField.text!
        
        if (name.isEmpty || date.isEmpty){
            displayAlertMessage(message: "Required Fields Empty")
            return;
        }
        if((newAssignment.titleLabel!.text!.isEqual("Edit Assignment"))){
            UserDefaults.standard.set(name, forKey: "editName")
            UserDefaults.standard.set(date, forKey: "editDate")
            UserDefaults.standard.synchronize()
        }else {
            UserDefaults.standard.set(name, forKey: "assignName")
            UserDefaults.standard.set(date, forKey: "dueDate")
            UserDefaults.standard.synchronize()
        }
       
        
       
        self.dismiss(animated: true)

        
        
        
    }
    func displayAlertMessage(message: String){
        let myAlert = UIAlertController(title: "Empty Fields", message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        myAlert.addAction(okAction);
        present(myAlert, animated: true)
    }
    @objc func donePicker(){
        //For date formate
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateTextField.text = dateFormatter.string(from: datePicker!.date)
        view.endEditing(true)
    }
    
    @objc func cancelPicker(){
        //cancel button dismiss datepicker dialog
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "< Back", style: .plain, target: self, action: #selector(backAction))

        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .dateAndTime
//        datePicker?.addTarget(self, action: #selector(dateChanged(datePicker:)), for: .valueChanged)
        if let name = UserDefaults.standard.value(forKey: "editName") as? String{
            if let date = UserDefaults.standard.value(forKey: "editDate") as? String{
                assignmentName.text = name
                dateTextField.text = date
                UserDefaults.standard.removeObject(forKey: "editName")
                UserDefaults.standard.removeObject(forKey: "editDate")
                UserDefaults.standard.synchronize()
                newAssignment.setTitle("Edit Assignment", for: .normal)
            }
        }
        
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        
        //done button & cancel button
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.bordered, target: self, action: #selector(donePicker))
         let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.bordered, target: self, action: #selector(cancelPicker))
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        
        // add toolbar to textField
        dateTextField.inputAccessoryView = toolbar
        // add datepicker to textField
        
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped(gestureRecognizer:)))
//
//        view.addGestureRecognizer(tapGesture)
        dateTextField.inputView = datePicker
        
        // Do any additional setup after loading the view.
    }
    @objc func backAction(){
        //print("Back Button Clicked")
        dismiss(animated: true, completion: nil)
    }
    
    @objc func dateChanged(datePicker: UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateTextField.text = dateFormatter.string(from: datePicker.date)
        view.endEditing(true)
    }
    
    
    @IBOutlet weak var dateTextField: UITextField!
    
    private var datePicker: UIDatePicker?
    
    /*
     // MARK: - Navigation
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
