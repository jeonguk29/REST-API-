//
//  TodosAPI+Combine.swift
//  TodoAppTutorial
//
//  Created by Jeff Jeong on 2022/11/26.
//

import Foundation
import MultipartForm
import Combine
//import CombineExt

extension TodosAPI {
    
    /// 모든 할 일 목록 가져오기
    /// protocol Publisher<Output, Failure>  퍼블리셔는 보내지는 값과, 에러타입을 명시하는데
    /// Output 부분이 Result<BaseListResponse<Todo>, ApiError>
    /// Failure 에러 타입 명시 부분이 Never임 Never - 에러를 보내지 않겠다고 하는 것임 Output 에 Result를 활용하여 처리 할거라
    static func fetchTodosWithPublisherResult(page: Int = 1) -> AnyPublisher<Result<BaseListResponse<Todo>, ApiError>, Never>{
        
        // 1. urlRequest 를 만든다
        
        let urlString = baseURL + "/todos" + "?page=\(page)"
        
        guard let url = URL(string: urlString) else {
            return Just(.failure(ApiError.notAllowedUrl)).eraseToAnyPublisher() // Just를 활용하여 이벤트 한번 보내기
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        // 2. urlSession 으로 API를 호출한다
        // 3. API 호출에 대한 응답을 받는다
        // iOS 자체에서 이벤트를 dataTaskPublisher 이렇게 퍼블리셔로 반환하는게 있음
        /*
         API 호출: URLSession.shared.dataTaskPublisher(for: urlRequest)는 URLSession을 통해 API를 호출하고, Publisher를 반환합니다. 이 Publisher는 data와 urlResponse를 내보냅니다.

         map 함수: map 함수는 Publisher에서 내보낸 데이터를 변환하는 데 사용됩니다. 여기서는 data와 urlResponse를 받아서 Result<BaseListResponse<Todo>, ApiError> 타입으로 변환합니다.
         */
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .map({ (data: Data, urlResponse: URLResponse) -> Result<BaseListResponse<Todo>, ApiError> in
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
                
                do {
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
                  // decoding error
                    return .failure(ApiError.decodingError)
                }
            })
//            .catch({ err in
//                return Just(.failure(ApiError.unknown(nil)))
//            })
            .replaceError(with: .failure(ApiError.unknown(nil))) // (에러 -> 데이터로 변경)
//            .assertNoFailure() // 에러가 나지 않을 것이다 라고 설정 (위험) - 에러시 앱 크래시 
            .eraseToAnyPublisher()
    }
    

    
   

}
