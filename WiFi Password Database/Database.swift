//
//  Database.swift
//  WiFi Password Database
//
//  Created by Michael De Rubertis on 2017-04-03.
//  Copyright © 2017 ApexTech Solutions. All rights reserved.
//

import SQLite

class Database {
    static let instance = Database()
    private let db: Connection?
    
    private let users = Table("users")
    private let id = Expression<Int64>("id")
    private let name = Expression<String?>("name")
    private let email = Expression<String>("email")
    private let uid = Expression<String>("uid")

    private init() {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!
        
        do {
            db = try Connection("\(path)/Users.sqlite3")
        } catch {
            db = nil
            print ("Unable to open database")
        }
        
        createTable()
    }
    
    func createTable() {
        do {
            try db!.run(users.create(ifNotExists: true) { table in
                table.column(id, primaryKey: true)
                table.column(name)
                table.column(email, unique: true)
                table.column(uid)
            })
        } catch {
            print("Unable to create table")
        }
    }
    
    func addUser(uname: String, uemail: String, uuid: String) -> Int64? {
        do {
            let insert = users.insert(name <- uname, email <- uemail, uid <- uuid)
            let id = try db!.run(insert)
            
            return id
        } catch {
            print("Insert failed: \(error)")
            return -1
        }
    }
    
    func getUsers() -> [User] {
        var users = [User]()
        
        do {
            for user in try db!.prepare(self.users) {
                users.append(User(
                    id: user[id],
                    name: user[name]!,
                    email: user[email],
                    uid: user[uid]))
            }
        } catch {
            print("Select failed")
        }
        
        return users
    }
    
    func getUser(tid: Int64) -> NSDictionary {
        var userInfo: NSDictionary = [:]
        
        do {
            for user in try db!.prepare(self.users.filter(id == tid)) {
                userInfo = [
                    "name": user[name],
                    "email": user[email],
                    "uid": user[uid]
                ]
            }
        } catch {
            print("Select failed")
        }
        
        return userInfo
    }
    
    func deleteUser(tid: Int64) -> Bool {
        do {
            let user = users.filter(id == tid)
            try db!.run(user.delete())
            return true
        } catch {
            print("Delete failed")
        }
        return false
    }
    
    func updateUser(tid:Int64, newUser: User) -> Bool {
        let user = users.filter(id == tid)
        do {
            let update = user.update([
                name <- newUser.name,
                email <- newUser.email,
                uid <- newUser.uid
                ])
            if try db!.run(update) > 0 {
                return true
            }
        } catch {
            print("Update failed: \(error)")
        }
        
        return false
    }
}
