//
//  NetworkServerManager.swift
//  PerfectServer
//
//  Created by zhangerbing on 2019/3/4.
//

import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

open class NetworkServerManager {
    fileprivate var server: HTTPServer
    internal init(root: String, port: UInt16) {
        
        // 创建HTTPServer
        self.server = HTTPServer()
        
        // 创建路由器
        var routes = Routes(baseUri: "/api")
        
        // 注册路由器
        configure(routes: &routes)
        
        // 服务器名称
        server.serverName = "Test"
        // 路由添加进服务
        server.addRoutes(routes)
        // 端口
        server.serverPort = port
        // 根目录
        server.documentRoot = root
        // 404过滤
        server.setResponseFilters([(Filter404(), .high)])
    }
    
    // MARK: - 开启服务
    open func startServer() {
        do {
            print("启动HTTP服务器")
            try server.start()
        } catch PerfectError.networkError(let error, let msg) {
            print("网络出现错误：\(error) \(msg)")
        } catch {
            print("网络未知错误")
        }
    }
    
    // MARK: - 注册路由
    private func configure(routes: inout Routes) {
        // 添加接口，请求方式，路径
        routes.add(method: .get, uri: "/**") { (request, response) in
            // 响应头
            response.setHeader(.contentType, value: "application/json, charset=utf-8")
            
            let jsonDic = ["hello": "world中"]
            
            let jsonString = self.baseResponseBodyJSONData(status: 200, message: "Success", data: jsonDic)
            
            response.setBody(string: jsonString)
            
            response.completed()
        }
    }
    
    // MARK: - 通用响应格式
    func baseResponseBodyJSONData(status: Int, message: String, data: Any!) -> String {
        var result = [String: Any]()
        
        result.updateValue(status, forKey: "status")
        result.updateValue(message, forKey: "message")
        if data != nil {
            result.updateValue(data, forKey: "data")
        } else {
            result.updateValue("", forKey: "data")
        }
        
        guard let jsonString = try? result.jsonEncodedString() else { return "" }
        return jsonString
    }
    
    // MARK: - 404过滤
    struct Filter404: HTTPResponseFilter {
        func filterBody(response: HTTPResponse, callback: (HTTPResponseFilterResult) -> ()) {
            callback(.continue)
        }
        
        func filterHeaders(response: HTTPResponse, callback: (HTTPResponseFilterResult) -> ()) {
            if case .notFound = response.status {
                response.setBody(string: "404 文件\(response.request.path) 不存在")
                response.setHeader(.contentLength, value: "\(response.bodyBytes.count)")
                response.setHeader(.contentType, value: "application/json, charset=utf-8")
                callback(.done)
            } else {
                callback(.continue)
            }
        }
        
    }
}
