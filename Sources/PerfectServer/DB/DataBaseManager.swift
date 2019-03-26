//
//  DataBaseManager.swift
//  PerfectServer
//
//  Created by zhangerbing on 2019/3/26.
//

import Foundation
import PerfectMySQL

// MARK: - 数据库信息
let mysql_host = "127.0.0.1"
let mysql_user = "root"
let mysql_password = "12345"
let mysql_database = "ServerTest"

// MARK: - 表信息
let table_account = "account_level"

open class DataBaseManager {
    fileprivate var mysql: MySQL
    internal init() {
        mysql = MySQL()
        guard connectedDataBase() else {
            return
        }
    }
    
    // MARK: - 开启连接
    private func connectedDataBase() -> Bool {
        let connected = mysql.connect(host: mysql_host, user: mysql_user, password: mysql_password, db: mysql_database, port: 3306)
        guard connected else {
            print("数据库连接失败" + mysql.errorMessage())
            return false
        }
        
        print("数据库连接成功")
        return true
    }
    
    /// 执行SQL语句
    /// - parameter sql: sql语句
    /// - returns: true 执行成功 false 执行失败
    @discardableResult // 忽略未使用返回值的警告
    func mysqlStatement(_ sql: String) -> (success: Bool, mysqlResult: MySQL.Results?, errorMsg: String) {
        guard mysql.selectDatabase(named: mysql_database) else {
            let msg = "未找到\(mysql_database)数据库"
            print(msg)
            return (false, nil, msg)
        }
        
        let successQuery = mysql.query(statement: sql)
        
        guard successQuery else {
            let msg = "SQL失败:\(sql)"
            print(msg)
            return (false, nil, msg)
        }
        
        let msg = "SQL成功:\(sql)"
        print(msg)
        return (true, mysql.storeResults(), msg)
    }
    
    /// 增
    /// - parameters:
    ///   - tableName: 表
    ///   - key: 键
    ///   - value: 值
    func insertDataBaseSQL(tableName: String, key: String, value: String) -> (success: Bool, mysqlResult: MySQL.Results?, errorMsg: String) {
        let SQL = "INSERT INTO \(tableName) (\(key)) VALUES (\(value))"
        return mysqlStatement(SQL)
    }
    
    /// 删
    /// - parameters:
    ///   - tableName: 表
    ///   - key: 键
    ///   - value: 值
    func deleteDataBaseSQL(tableName: String, key: String, value: String) -> (success: Bool, mysqlResult: MySQL.Results?, errorMsg: String) {
        let SQL = "DELETE FROM \(tableName) WHERE \(key)='\(value)'"
        return mysqlStatement(SQL)
    }
    
    /// 改
    /// - parameters:
    ///   - tableName: 表
    ///   - keyValue: 键值对( 键='值', 键='值', 键='值' )
    ///   - key: 键
    ///   - value: 值
    func updateDataBaseSQL(tableName: String, keyvalues: String, key: String, value: String) -> (success: Bool, mysqlResult: MySQL.Results?, errorMsg: String) {
        let SQL = "UPDATE \(tableName) SET \(keyvalues) WHERE \(key)='\(value)'"
        return mysqlStatement(SQL)
    }
    
    /// 查所有
    /// - parameters:
    ///   - tableName: 表
    func selectAllDataBaseSQL(tableName: String) -> (success: Bool, mysqlResult: MySQL.Results?, errorMsg: String) {
        let SQL = "SELECT * FROM \(tableName)"
        return mysqlStatement(SQL)
    }
    
    /// 查
    /// - parameters:
    ///   - tableName: 表
    ///   - key: 键
    ///   - value: 值
    func selectDataBaseSQL(tableName: String, key: String, value: String) -> (success: Bool, mysqlResult: MySQL.Results?, errorMsg: String) {
        let SQL = "SELECT * FROM \(tableName) WHERE \(key)='\(value)'"
        return mysqlStatement(SQL)
    }
    
    /// 获取表中所有数据
    func getAllDataBaseDataResult() -> [Dictionary<String, String>] {
        let result = selectAllDataBaseSQL(tableName: table_account)
        var resultArray = [Dictionary<String, String>]()
        var dict = [String: String]()
        result.mysqlResult?.forEachRow(callback: { (row) in
            dict["level_id"] = row[0]
            dict["name"] = row[1]
            resultArray.append(dict)
        })
        return resultArray
    }
}
