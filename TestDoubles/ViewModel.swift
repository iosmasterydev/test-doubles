import Combine
import Foundation

struct Token: Decodable {
  let value: String
  let expiryDate: Date
}

struct LoginPayload: Encodable {
  let email: String
  let password: String
}


final class LoginViewModel: ObservableObject {
  @Published var token: Token?
  @Published var error: Error?
  @Published var email: String = ""
  @Published var password: String = ""
  
  private let loginService: LoginService
  private let loggerService: LoggerService
  
  init(
    loginService: LoginService,
    loggerService: LoggerService
  ) {
    self.loginService = loginService
    self.loggerService = loggerService
  }
  
  @MainActor
  func login() async {
    do {
      token = try await loginService.attemptLogin(
        email: email,
        password: password
      )
//      loggerService.log(email: email)
    } catch {
      self.error = error
    }
  }
  
}


protocol LoginService {
  func attemptLogin(email: String, password: String) async throws -> Token
}

protocol LoggerService {
  func log(email: String)
}


struct DefaultLoggerService: LoggerService {
  func log(email: String) {
    print(email, "logged at \(Date.now.formatted())")
  }
}


struct DefaultLoginService: LoginService {
  
  func attemptLogin(email: String, password: String) async throws -> Token {
    var request = URLRequest(url: URL(string: "any-url")!)
    let payload = LoginPayload(email: email, password: password)
    request.httpBody = try? JSONEncoder().encode(payload)
    let (data, _) = try await URLSession.shared.data(for: request)
    guard let token = try? JSONDecoder().decode(Token.self, from: data) else {
      throw NSError(domain: "decoding-error", code: 0)
    }
    return token
  }
  
}


class A {
  
  func sum(number1: Int, number2: Int) -> Int {
    return number1 + number2
  }
  
}


class B {
  let number1: Int = 1
  let number2: Int = 2
  
  let a: A
  
  init(a: A) {
    self.a = a
  }
  
  func doSomething() {
    let result = a.sum(number1: number1, number2: number2)
    // do something with the result
    // ....
  }
  
}
