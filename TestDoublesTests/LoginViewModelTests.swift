import XCTest
@testable import TestDoubles


final class LoginViewModelTests: XCTestCase {

  func test_error_is_not_nil_if_service_sends_a_network_error() async {
    let sut = LoginViewModel(
      loginService: LoginServiceSadPathStub(),
      loggerService: LoggerServiceMock()
    )
    
    await sut.login()
    
    XCTAssertNotNil(sut.error)
  }
  
  func test_token_is_not_nil_when_the_api_sent_a_successful_response() async {
    let sut = LoginViewModel(
      loginService: LoginServiceHappyPathStub(),
      loggerService: LoggerServiceMock()
    )
    
    await sut.login()
    
    XCTAssertNotNil(sut.token)
    XCTAssertEqual(sut.token?.value, "jwt-token")
  }
  
  func test_attemptLogin_is_only_called_once() async {
    let loginMock = LoginServiceHappyPathMock()
    let loggerMock = LoggerServiceMock()
    let sut = LoginViewModel(
      loginService: loginMock,
      loggerService: loggerMock
    )
    
    await sut.login()
    
    XCTAssertEqual(loginMock.loginCalledCount, 1)
  }
  
  func test_attemptLogin_throws_an_error_when_service_sends_network_error() async {
    let mock = LoginServiceSadPathMock()
    let sut = LoginViewModel(
      loginService: mock,
      loggerService: LoggerServiceMock()
    )
    
    await sut.login()
    
    XCTAssertEqual(mock.loginCalled, 1)
    XCTAssertNotNil(mock.error)
  }
  
  func test_right_arguments_are_passed() async {
    let spy = LoginServiceSpy()
    let sut = LoginViewModel(loginService: spy, loggerService: LoggerServiceMock())
    sut.email = "hello@gmail.com"
    sut.password = "password"
    
    await sut.login()
    
    XCTAssertEqual(spy.loginCalled, 1)
    XCTAssertEqual(spy.receivedInvocations.count, 1)
    XCTAssertEqual(spy.receivedArguments?.email, "hello@gmail.com")
    XCTAssertEqual(spy.receivedArguments?.password, "password")
  }
  
}


// MARK: - Stubs
class LoginServiceHappyPathStub: LoginService {
  func attemptLogin(email: String, password: String) async throws -> Token {
    return Token(
      value: "jwt-token",
      expiryDate: .now.addingTimeInterval(60 * 30)
    )
  }
}

class LoginServiceSadPathStub: LoginService {
  func attemptLogin(email: String, password: String) async throws -> Token {
    throw NSError(domain: "error", code: 0)
  }
}


// MARK: - Mocks
private class LoggerServiceMock: LoggerService {
  var logCalledCount: Int = 0
  
  func log(email: String) {
    logCalledCount += 1
  }
}


private class LoginServiceHappyPathMock: LoginService {
  var error: NSError?
  var loginCalledCount: Int = 0
  
  func attemptLogin(email: String, password: String) async throws -> Token {
    loginCalledCount += 1
    return Token(
      value: "jwt-token",
      expiryDate: .now.addingTimeInterval(60 * 30)
    )
  }
  
}


private class LoginServiceSadPathMock: LoginService {
  var error: NSError?
  var loginCalled: Int = 0
  
  func attemptLogin(email: String, password: String) async throws -> Token {
    loginCalled += 1
    let error = NSError(domain: "error", code: 0)
    self.error = error
    throw error
  }
  
}


// MARK: - Spies
class LoginServiceSpy: LoginService {
  var error: Error?
  var loginCalled: Int = 0
  var receivedArguments: (email: String, password: String)?
  var receivedInvocations: [(email: String, password: String)] = []
  
  func attemptLogin(email: String, password: String) async throws -> Token {
    loginCalled += 1
    if let error { throw error }
    receivedArguments = (email: email, password: password)
    receivedInvocations.append((email: email, password: password))
    return Token(
      value: "jwt-token",
      expiryDate: .now.addingTimeInterval(60 * 30)
    )
  }
  
}
