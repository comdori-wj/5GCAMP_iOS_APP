//
//  Observable.swift
//  5GCAMP
//
//  Created by WONJI HA on 11/7/24.
//

import Foundation

public final class Observable<T> {
    // 1-1. 값 담을 value 만듦
    var value: T {
        // 2. didSet 생성
        didSet {
            // 4. 값이 변경 될 떄마다 listener 에 담겨있는 행동 수행
            self.listener?(value)
        }
    }
    
    // 3. 값이 변경 될 떄 마다 listener 에 담겨있는 행동 수행
    private var listener: ((T) -> Void)?
    
    // 1-2. init 생성
    init(_ value: T) {
        self.value = value
    }
    
    // 5. 구독을 통해 파라미터로 넘어온 '특정 행동'을 수행하고, 나중에 didSet 에서도 실행할 수 있도록 클로저 변수에 담기
    func bind(_ closure: @escaping (T) -> Void) {
        listener = closure
        closure(value)
    }
}
