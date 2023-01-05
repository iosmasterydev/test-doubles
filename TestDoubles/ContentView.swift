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
  
  init(loginService: LoginService = DefaultLoginService()) {
    self.loginService = loginService
  }
  
  @MainActor
  func login() async {
    do {
      token = try await loginService.attemptLogin(
        email: email,
        password: password
      )
    } catch {
      self.error = error
    }
  }
  
}


protocol LoginService {
  func attemptLogin(email: String, password: String) async throws -> Token
}

struct DefaultLoginService: LoginService {
  
  func attemptLogin(email: String, password: String) async throws -> Token {
    var request = URLRequest(url: URL(string: "any-url")!)
    let payload = LoginPayload(email: email, password: password)
    request.httpBody = try? JSONEncoder().encode(payload)
    let (data, _) = try await URLSession.shared.data(for: request)
    guard let token = try? JSONDecoder().decode(Token.self, from: data) else {
      throw NSError(domain: "decoding-error", code: 1)
    }
    return token
  }
  
}
