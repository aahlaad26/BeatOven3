import Foundation
struct GroupColab:Identifiable,Hashable,Codable{
    let id: String
    var name: String
    var profileImsgeURL:String?
    var arrayOfPeople:[String]
    
}
extension GroupColab{
    static var MOCK_GROUPS : [GroupColab] = [
        .init(id: NSUUID().uuidString, name: "Nobodies", profileImsgeURL: "fists", arrayOfPeople:["spiderman","avenger","batman"]),
        .init(id: NSUUID().uuidString, name: "Avengers", profileImsgeURL: "spiderman", arrayOfPeople:["spiderman","revenger","superman"]),
        .init(id: NSUUID().uuidString, name: "Anybodies", profileImsgeURL: "batman", arrayOfPeople:["spiderman","Ironman","batman"]),
        .init(id: NSUUID().uuidString, name: "Somebodies", profileImsgeURL: "Rohan", arrayOfPeople:["Robin","Nightwing","batman"])
    
    
    ]
}
