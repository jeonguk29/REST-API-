//
//  TodosAPI+Async.swift
//  TodoAppTutorial
//
//  Created by Jeff Jeong on 2022/11/28.
//

import Foundation
import MultipartForm
import Combine
import CombineExt

extension TodosAPI {
    
    /// 모든 할 일 목록 가져오기
    static func fetchTodosWithAsyncResult(page: Int = 1) async -> Result<BaseListResponse<Todo>, ApiError>{
        
        // 1. urlRequest 를 만든다
        
        let urlString = baseURL + "/todos" + "?page=\(page)"
        
        guard let url = URL(string: urlString) else {
            return .failure(ApiError.notAllowedUrl)
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        // 2. urlSession 으로 API를 호출한다
        // 3. API 호출에 대한 응답을 받는다
        
        do {
            
            let (data, urlResponse) = try await URLSession.shared.data(for: urlRequest)
            
            print("data: \(data)")
            print("urlResponse: \(urlResponse)")
                 
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                print("bad status code")
                return .failure(ApiError.unknown(nil))
            }
            
            switch httpResponse.statusCode {
            case 401:
                return .failure(ApiError.unauthorized)
            default: print("default")
            }
            
            if !(200...299).contains(httpResponse.statusCode){
                return .failure(ApiError.badStatus(code: httpResponse.statusCode))
            }
            
            // JSON -> Struct 로 변경 즉 디코딩 즉 데이터 파싱
            let listResponse = try JSONDecoder().decode(BaseListResponse<Todo>.self, from: data)
            let todos = listResponse.data
            print("todosResponse: \(listResponse)")
            
            // 상태 코드는 200인데 파싱한 데이터에 따라서 에러처리
            guard let todos = todos,
                  !todos.isEmpty else {
                return .failure(ApiError.noContent)
            }
            
            return .success(listResponse)
            
        } catch {
            // 어떤에러가 들어올지는 모르겠지만 처리
            if let _ = error as? DecodingError {
                return .failure(ApiError.decodingError)
            }
            
            return .failure(ApiError.unknown(error))
        }
    }
    
    /// 모든 할 일 목록 가져오기
    /// async throws - 비동기이고 에러를 던질거다
    static func fetchTodosWithAsync(page: Int = 1) async throws -> BaseListResponse<Todo>{
        
        // 1. urlRequest 를 만든다
        
        let urlString = baseURL + "/todos" + "?page=\(page)"
        
        
        guard let url = URL(string: urlString) else {
            throw ApiError.notAllowedUrl
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        // 2. urlSession 으로 API를 호출한다
        // 3. API 호출에 대한 응답을 받는다
        
        do {
            let (data, urlResponse) = try await URLSession.shared.data(for: urlRequest)
            
            print("data: \(data)")
            print("urlResponse: \(urlResponse)")
                 
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                print("bad status code")
                
                throw ApiError.unknown(nil)
            }
            
            switch httpResponse.statusCode {
            case 401:
                throw ApiError.unauthorized
                
            default: print("default")
            }
            
            if !(200...299).contains(httpResponse.statusCode){
                throw ApiError.badStatus(code: httpResponse.statusCode)
            }
            
            // JSON -> Struct 로 변경 즉 디코딩 즉 데이터 파싱
            let listResponse = try JSONDecoder().decode(BaseListResponse<Todo>.self, from: data)
            let todos = listResponse.data
            print("todosResponse: \(listResponse)")
            
            // 상태 코드는 200인데 파싱한 데이터에 따라서 에러처리
            guard let todos = todos,
                  !todos.isEmpty else {
                
                throw ApiError.noContent
            }
            
            return listResponse
            
        } catch {
            // 이렇게 그물망 처리 하는게 좋음
            if let apiError = error as? URLError {
                throw ApiError.badStatus(code: apiError.errorCode)
            }
            
            if let _ = error as? DecodingError {
                throw ApiError.decodingError
            }
            
            throw ApiError.unknown(error)
        }
            
    }
    
    /// 특정 할 일 가져오기
    static func fetchATodoWithAsync(id: Int) async throws -> BaseResponse<Todo>{
        
        // 1. urlRequest 를 만든다
        
        let urlString = baseURL + "/todos" + "/\(id)"
        
        guard let url = URL(string: urlString) else {
            throw ApiError.notAllowedUrl
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        // 2. urlSession 으로 API를 호출한다
        // 3. API 호출에 대한 응답을 받는다
        
        do { // ⭐️ 지금 우리가 do-catch 해주는 이유는 우리가 만든 ApiError로 처리하기 위해서 해주는 것임
            let (data, urlResponse) = try await URLSession.shared.data(for: urlRequest)
            
            print("data: \(data)")
            print("urlResponse: \(urlResponse)")
                 
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                print("bad status code")
                
                throw ApiError.unknown(nil)
            }
            
            switch httpResponse.statusCode {
            case 401:
                throw ApiError.unauthorized
                
            default: print("default")
            }
            
            if !(200...299).contains(httpResponse.statusCode){
                throw ApiError.badStatus(code: httpResponse.statusCode)
            }
            
            // JSON -> Struct 로 변경 즉 디코딩 즉 데이터 파싱
            let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: data)
            let aTodo = baseResponse.data
            print("baseResponse: \(baseResponse)")
            
            // 상태 코드는 200인데 파싱한 데이터에 따라서 에러처리
            guard let _ = aTodo else {
                throw ApiError.noContent
            }
            
            return baseResponse
            
        } catch {
            
            if let apiError = error as? URLError {
                throw ApiError.badStatus(code: apiError.errorCode)
            }
            
            if let _ = error as? DecodingError {
                throw ApiError.decodingError
            }
            
            throw ApiError.unknown(error)
        }
        
    }
    
    /// 할 일 검색하기
    static func searchTodosWithAsync(searchTerm: String, page: Int = 1) async throws -> BaseListResponse<Todo>{
        
        // 1. urlRequest 를 만든다
        let requestUrl = URL(baseUrl: baseURL + "/todos/search", queryItems: ["query" : searchTerm,
                                                                              "page" : "\(page)"])
        guard let url = requestUrl else {
            throw ApiError.notAllowedUrl
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        // 2. urlSession 으로 API를 호출한다
        // 3. API 호출에 대한 응답을 받는다
        
        do {
            let (data, urlResponse) = try await URLSession.shared.data(for: urlRequest)
            
            print("data: \(data)")
            print("urlResponse: \(urlResponse)")
                 
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                print("bad status code")
                
                throw ApiError.unknown(nil)
            }
            
            switch httpResponse.statusCode {
            case 401:
                throw ApiError.unauthorized
                
            default: print("default")
            }
            
            if !(200...299).contains(httpResponse.statusCode){
                throw ApiError.badStatus(code: httpResponse.statusCode)
            }
            
            // JSON -> Struct 로 변경 즉 디코딩 즉 데이터 파싱
            let listResponse = try JSONDecoder().decode(BaseListResponse<Todo>.self, from: data)
            let todos = listResponse.data
            print("todosResponse: \(listResponse)")
            
            // 상태 코드는 200인데 파싱한 데이터에 따라서 에러처리
            guard let todos = todos,
                  !todos.isEmpty else {
                
                throw ApiError.noContent
            }
            
            return listResponse
            
        } catch {
            
            if let apiError = error as? URLError {
                throw ApiError.badStatus(code: apiError.errorCode)
            }
            
            if let _ = error as? DecodingError {
                throw ApiError.decodingError
            }
            
            throw ApiError.unknown(error)
        }
    }
    
    /// 할 일 추가하기
    /// - Parameters:
    ///   - title: 할일 타이틀
    ///   - isDone: 할일 완료여부
    ///   - completion: 응답 결과
    static func addATodoWithAsync(title: String,
                         isDone: Bool = false) async throws -> BaseResponse<Todo>{
        
        // 1. urlRequest 를 만든다
        
        let urlString = baseURL + "/todos"
        
        guard let url = URL(string: urlString) else {
            throw ApiError.notAllowedUrl
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        let form = MultipartForm(parts: [
            MultipartForm.Part(name: "title", value: title),
            MultipartForm.Part(name: "is_done", value: "\(isDone)")
        ])
        
        print("form.contentType : \(form.contentType)")
        
        urlRequest.addValue(form.contentType, forHTTPHeaderField: "Content-Type")
        
        urlRequest.httpBody = form.bodyData
        
        // 2. urlSession 으로 API를 호출한다
        // 3. API 호출에 대한 응답을 받는다
        do {
            let (data, urlResponse) = try await URLSession.shared.data(for: urlRequest)
            
            print("data: \(data)")
            print("urlResponse: \(urlResponse)")
                 
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                print("bad status code")
                
                throw ApiError.unknown(nil)
            }
            
            switch httpResponse.statusCode {
            case 401:
                throw ApiError.unauthorized
                
            default: print("default")
            }
            
            if !(200...299).contains(httpResponse.statusCode){
                throw ApiError.badStatus(code: httpResponse.statusCode)
            }
            
            // JSON -> Struct 로 변경 즉 디코딩 즉 데이터 파싱
            let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: data)
            let aTodo = baseResponse.data
            print("baseResponse: \(baseResponse)")
            
            // 상태 코드는 200인데 파싱한 데이터에 따라서 에러처리
            guard let _ = aTodo else {
                throw ApiError.noContent
            }
            
            return baseResponse
            
        } catch {
            
            if let apiError = error as? URLError {
                throw ApiError.badStatus(code: apiError.errorCode)
            }
            
            if let _ = error as? DecodingError {
                throw ApiError.decodingError
            }
            
            throw ApiError.unknown(error)
        }
    }
    
    /// 할 일 추가하기 - Json
    /// - Parameters:
    ///   - title: 할일 타이틀
    ///   - isDone: 할일 완료여부
    ///   - completion: 응답 결과
    static func addATodoJsonWithAsync(title: String,
                         isDone: Bool = false) async throws -> BaseResponse<Todo>{
        
        // 1. urlRequest 를 만든다
        
        let urlString = baseURL + "/todos-json"
        
        guard let url = URL(string: urlString) else {
            throw ApiError.notAllowedUrl
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestParams : [String : Any] = ["title": title, "is_done" : "\(isDone)"]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestParams, options: [.prettyPrinted])
            
            urlRequest.httpBody = jsonData
            
        } catch {
            throw ApiError.jsonEncoding
        }
        
        // 2. urlSession 으로 API를 호출한다
        // 3. API 호출에 대한 응답을 받는다
        do {
            let (data, urlResponse) = try await URLSession.shared.data(for: urlRequest)
            
            print("data: \(data)")
            print("urlResponse: \(urlResponse)")
                 
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                print("bad status code")
                
                throw ApiError.unknown(nil)
            }
            
            switch httpResponse.statusCode {
            case 401:
                throw ApiError.unauthorized
                
            default: print("default")
            }
            
            if !(200...299).contains(httpResponse.statusCode){
                throw ApiError.badStatus(code: httpResponse.statusCode)
            }
            
            // JSON -> Struct 로 변경 즉 디코딩 즉 데이터 파싱
            let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: data)
            let aTodo = baseResponse.data
            print("baseResponse: \(baseResponse)")
            
            // 상태 코드는 200인데 파싱한 데이터에 따라서 에러처리
            guard let _ = aTodo else {
                throw ApiError.noContent
            }
            
            return baseResponse
            
        } catch {
            
            if let apiError = error as? URLError {
                throw ApiError.badStatus(code: apiError.errorCode)
            }
            
            if let _ = error as? DecodingError {
                throw ApiError.decodingError
            }
            
            throw ApiError.unknown(error)
        }
    }
    
    /// 할 일 수정하기 - Json
    /// - Parameters:
    ///   - id: 수정할 아이템 아이디
    ///   - title: 타이틀
    ///   - isDone: 완료여부
    ///   - completion: 응답결과
    static func editTodoJsonWithAsync(id: Int,
                             title: String,
                             isDone: Bool = false) async throws -> BaseResponse<Todo>{
        
        // 1. urlRequest 를 만든다
        
        let urlString = baseURL + "/todos-json/\(id)"
        
        guard let url = URL(string: urlString) else {
            throw ApiError.notAllowedUrl
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestParams : [String : Any] = ["title": title, "is_done" : "\(isDone)"]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestParams, options: [.prettyPrinted])
            
            urlRequest.httpBody = jsonData
            
        } catch {
            throw ApiError.jsonEncoding
        }
        
        // 2. urlSession 으로 API를 호출한다
        // 3. API 호출에 대한 응답을 받는다
        do {
            let (data, urlResponse) = try await URLSession.shared.data(for: urlRequest)
            
            print("data: \(data)")
            print("urlResponse: \(urlResponse)")
                 
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                print("bad status code")
                
                throw ApiError.unknown(nil)
            }
            
            switch httpResponse.statusCode {
            case 401:
                throw ApiError.unauthorized
                
            default: print("default")
            }
            
            if !(200...299).contains(httpResponse.statusCode){
                throw ApiError.badStatus(code: httpResponse.statusCode)
            }
            
            // JSON -> Struct 로 변경 즉 디코딩 즉 데이터 파싱
            let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: data)
            let aTodo = baseResponse.data
            print("baseResponse: \(baseResponse)")
            
            // 상태 코드는 200인데 파싱한 데이터에 따라서 에러처리
            guard let _ = aTodo else {
                throw ApiError.noContent
            }
            
            return baseResponse
            
        } catch {
            
            if let apiError = error as? URLError {
                throw ApiError.badStatus(code: apiError.errorCode)
            }
            
            if let _ = error as? DecodingError {
                throw ApiError.decodingError
            }
            
            throw ApiError.unknown(error)
        }
    }
    
    /// 할 일 수정하기 - PUT urlEncoded
    /// - Parameters:
    ///   - id: 수정할 아이템 아이디
    ///   - title: 타이틀
    ///   - isDone: 완료여부
    ///   - completion: 응답결과
    static func editTodoWithAsync(id: Int,
                             title: String,
                             isDone: Bool = false) async throws -> BaseResponse<Todo>{
        
        // 1. urlRequest 를 만든다
        
        let urlString = baseURL + "/todos/\(id)"
        
        guard let url = URL(string: urlString) else {
            throw ApiError.notAllowedUrl
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let requestParams : [String : String] = ["title": title, "is_done" : "\(isDone)"]
        
        urlRequest.percentEncodeParameters(parameters: requestParams)
        
        // 2. urlSession 으로 API를 호출한다
        // 3. API 호출에 대한 응답을 받는다
        do {
            let (data, urlResponse) = try await URLSession.shared.data(for: urlRequest)
            
            print("data: \(data)")
            print("urlResponse: \(urlResponse)")
                 
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                print("bad status code")
                
                throw ApiError.unknown(nil)
            }
            
            switch httpResponse.statusCode {
            case 401:
                throw ApiError.unauthorized
                
            default: print("default")
            }
            
            if !(200...299).contains(httpResponse.statusCode){
                throw ApiError.badStatus(code: httpResponse.statusCode)
            }
            
            // JSON -> Struct 로 변경 즉 디코딩 즉 데이터 파싱
            let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: data)
            let aTodo = baseResponse.data
            print("baseResponse: \(baseResponse)")
            
            // 상태 코드는 200인데 파싱한 데이터에 따라서 에러처리
            guard let _ = aTodo else {
                throw ApiError.noContent
            }
            
            return baseResponse
            
        } catch {
            
            if let apiError = error as? URLError {
                throw ApiError.badStatus(code: apiError.errorCode)
            }
            
            if let _ = error as? DecodingError {
                throw ApiError.decodingError
            }
            
            throw ApiError.unknown(error)
        }
    }
    
    /// 할 일 삭제하기 - DELETE
    /// - Parameters:
    ///   - id: 삭제할 아이템 아이디
    ///   - completion: 응답결과
    static func deleteATodoWithAsync(id: Int) async throws -> BaseResponse<Todo>{
        
        print(#fileID, #function, #line, "- deleteATodo 호출됨 / id: \(id)")
        
        // 1. urlRequest 를 만든다
        
        let urlString = baseURL + "/todos/\(id)"
        
        guard let url = URL(string: urlString) else {
            throw ApiError.notAllowedUrl
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")

        
        // 2. urlSession 으로 API를 호출한다
        // 3. API 호출에 대한 응답을 받는다
        do {
            let (data, urlResponse) = try await URLSession.shared.data(for: urlRequest)
            
            print("data: \(data)")
            print("urlResponse: \(urlResponse)")
                 
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                print("bad status code")
                
                throw ApiError.unknown(nil)
            }
            
            switch httpResponse.statusCode {
            case 401:
                throw ApiError.unauthorized
            case 204:
                throw ApiError.noContent
            default: print("default")
            }
            
            if !(200...299).contains(httpResponse.statusCode){
                throw ApiError.badStatus(code: httpResponse.statusCode)
            }
            
            // JSON -> Struct 로 변경 즉 디코딩 즉 데이터 파싱
            let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: data)
            let aTodo = baseResponse.data
            print("baseResponse: \(baseResponse)")
            
            // 상태 코드는 200인데 파싱한 데이터에 따라서 에러처리
            guard let _ = aTodo else {
                throw ApiError.noContent
            }
            
            return baseResponse
            
        } catch {
            
            if let myError = error as? ApiError {
                throw myError
            }
            
            if let apiError = error as? URLError {
                throw ApiError.badStatus(code: apiError.errorCode)
            }
            
            if let _ = error as? DecodingError {
                throw ApiError.decodingError
            }
            
            throw ApiError.unknown(error)
        }
    }
    
    
    
    // MARK: - 연쇄 API 처리
    
    /// 할일 추가 -> 모든 할일 가져오기 - 에러함께
    /// - Parameters:
    ///   - title:
    ///   - isDone:
    ///   - completion:
    static func addATodoAndFetchTodosWithAsyncWithError(title: String,
                                      isDone: Bool = false) async throws -> [Todo]{
        
        // 1번 끝나고
        let firstResult = try await addATodoWithAsync(title: title)
        
        // 2번 호출
        let secondResult = try await fetchTodosWithAsync()
        // let secondResult = try await fetchTodosWithAsync(page: firstResult.message) 이런식으로 값 넣는것도 가능
        
        guard let finalResult = secondResult.data else { // 값이 없다면
            throw ApiError.noContent
        }
        
        return finalResult
    }
    
    /// 할일 추가 -> 모든 할일 가져오기 - NO 에러
    /// - Parameters:
    ///   - title:
    ///   - isDone:
    ///   - completion:
    static func addATodoAndFetchTodosWithAsyncNoError(title: String,
                                      isDone: Bool = false) async -> [Todo]{
        
        //throw 던지는게 아닌 빈 배열로 반환 하는 것임 
        do {
            
            // 1번 끝나고
            let firstResult = try await addATodoWithAsync(title: title)
            
            // 2번 호출
            let secondResult = try await fetchTodosWithAsync()
            
            guard let finalResult = secondResult.data else {
                return []
            }
            
            return finalResult
            
        } catch {
            if let _ = error as? ApiError {
                return []
            }
            
            return []
        }
    }
    
    
    // MARK: - 동시 API 처리
    
    /// 클로져 기반 api 동시 처리
    /// 선택된 할일들 삭제하기
    /// - Parameters:
    ///   - selectedTodoIds: 선택된 할일 아이디들
    ///   - completion: 실제 삭제가 완료된 아이디들
    static func deleteSelectedTodosWithAsyncNoError(selectedTodoIds: [Int]) async -> [Int]{
        
        // await을 사용하지 않음 동시에 출발해야함 , async을 문법 맨 앞으로 위치시켜 각자가 출발한다 명시
        async let firstResult = self.deleteATodoWithAsync(id: 5434)
        async let secondResult = self.deleteATodoWithAsync(id: 5433)
        async let thirdResult = self.deleteATodoWithAsync(id: 5411)
        
        // 각각의 값들이 에러를 던짐 우리도 throw 던질 수 있지만  do - catch 로 받아 빈배열 처리
        do {
            let results : [Int?] = try await[firstResult.data?.id,
                                             secondResult.data?.id,
                                             thirdResult.data?.id]
            return results.compactMap{ $0 }
        } catch {
            
            if let _ = error as? URLError {
                return []
            }
            
            if let _ = error as? ApiError {
                return []
            }
            return []
        }
    }
    
    /// 클로져 기반 api 동시 처리
    /// 선택된 할일들 삭제하기
    /// - Parameters:
    ///   - selectedTodoIds: 선택된 할일 아이디들
    ///   - completion: 실제 삭제가 완료된 아이디들
    static func deleteSelectedTodosWithAsyncWithError(selectedTodoIds: [Int]) async throws -> [Int]{
        
        async let firstResult = self.deleteATodoWithAsync(id: 5434)
        async let secondResult = self.deleteATodoWithAsync(id: 5433)
        async let thirdResult = self.deleteATodoWithAsync(id: 5411)
        
        
        let results : [Int?] = try await[firstResult.data?.id,
                                         secondResult.data?.id,
                                         thirdResult.data?.id] // try 하는 과정에서 애러가 나감
        return results.compactMap{ $0 }
    }
    
    /// Async 기반 api 동시 처리
    /// 선택된 할일들 삭제하기
    /// - Parameters:
    ///   - selectedTodoIds: 선택된 할일 아이디들
    ///   - completion: 실제 삭제가 완료된 아이디들
    static func deleteSelectedTodosWithAsyncTaskGroupWithError(selectedTodoIds: [Int]) async throws -> [Int]{
        
        // Sendable.Type : 각각의 테스크들에서 반환되는 녀석 즉 addTask에서 반환되는 타입
        try await withThrowingTaskGroup(of: Int?.self) { (group : inout ThrowingTaskGroup<Int?, Error>) -> [Int] in
            
            // 각각 자식 async 태스크를 그룹에 넣기
            for aTodoId in selectedTodoIds {
                group.addTask(operation: {
                    // 단일 api 쏘기
                    let childTaskResult = try await self.deleteATodoWithAsync(id: aTodoId)
                    return childTaskResult.data?.id
                    // 이 값이 of: Int?.self, ThrowingTaskGroup<Int?, Error> 이것과 같음
                })
            }
            
            var deleteTodoIds : [Int] = [] // 언래핑한 최종 결과값 담기 위한 배열
            
            for try await singleValue in group { // 반복하여 결과 받기 
                if let value = singleValue {
                    deleteTodoIds.append(value)
                }
            }
            
            return deleteTodoIds
        }
    }
    
    
    /// Async 기반 api 동시 처리
    /// 선택된 할일들 삭제하기
    /// - Parameters:
    ///   - selectedTodoIds: 선택된 할일 아이디들
    ///   - completion: 실제 삭제가 완료된 아이디들
    static func deleteSelectedTodosWithAsyncTaskGroupNoError(selectedTodoIds: [Int]) async -> [Int]{
        
        // 에러를 던지지 않는 TaskGroup,   TaskGroup<Int?>에도 에러없음
        await withTaskGroup(of: Int?.self) { (group : inout TaskGroup<Int?>) -> [Int] in
            
            // 각각 자식 async 태스크를 그룹에 넣기
            for aTodoId in selectedTodoIds {
                group.addTask(operation: {
                    do {
                        // 단일 api 쏘기
                        let childTaskResult = try await self.deleteATodoWithAsync(id: aTodoId)
                        return childTaskResult.data?.id
                    } catch {
                        return nil
                    }
                })
            }
            
            var deleteTodoIds : [Int] = []
            
            for await singleValue in group {
                if let value = singleValue {
                    deleteTodoIds.append(value)
                }
            }
            return deleteTodoIds
        }
    }
    
    
}
