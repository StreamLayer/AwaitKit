/*
 * AwaitKit
 *
 * Copyright 2016-present Yannick Loriot.
 * http://yannickloriot.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

@testable import AwaitKitExample
import PromiseKit
import XCTest

class AwaitKitTests: XCTestCase {
  func testExcludeSameQueue() {
    let promise = Promise { resolve, reject in
      resolve()
    }

    XCTAssertThrowsError(try AwaitKit.awaitForPromise(on: dispatch_get_main_queue(), promise: promise))
  }

  func testAsyncAndAwaitOnDifferentQueue() {
    let expectation = expectationWithDescription("Async should fulfill")

    let promise = Promise { resolve, reject in
      resolve()
    }

    let result: Promise<Void> = async {
      try await(promise)
    }

    result.then { _ in
      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(0.1, handler: nil)
  }

  func testImbricationQueue() {
    let expectation = expectationWithDescription("Async should fulfill")

    let promise = Promise { resolve, reject in
      resolve()
    }

    let result: Promise<Void> = async {
      try await(async { try await(promise) })
    }

    result.then { _ in
      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(0.1, handler: nil)
  }
}
