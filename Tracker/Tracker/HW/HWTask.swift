import Foundation

struct dueDate{
    var date : String
    var timeStamp : Date
}

class HWTask {
    
    var taskName : String
    var date : dueDate
    var isDone : Bool
    
    init(name: String, timeDue: String,timeStamp: Date?, isDone: Bool = false){
        let timeDate = dueDate(date: timeDue,timeStamp: timeStamp!)
        self.taskName = name
        self.date = timeDate
        self.isDone = false
    }
}
