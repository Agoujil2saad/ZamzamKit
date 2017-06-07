//
//  WatchSession.swift
//  ZamzamKit
//
//  Created by Basem Emara on 3/13/17.
//  Copyright © 2017 Zamzam. All rights reserved.
//

import WatchConnectivity

public class WatchSession: NSObject, WCSessionDelegate {

    fileprivate var sessionDefault: WCSession? {
        guard WCSession.isSupported() else { return nil }
        return WCSession.default()
    }
    
    public override init() {
        super.init()
        sessionDefault?.delegate = self
    }
    
    /// Subscription queues for firing within delegates
    fileprivate var activationDidCompleteSingle = SynchronizedArray<ActivationHandler>()
    fileprivate var didBecomeInactive = SynchronizedArray<Observer<() -> Void>>()
    fileprivate var didDeactivate = SynchronizedArray<Observer<() -> Void>>()
    fileprivate var stateDidChange = SynchronizedArray<Observer<() -> Void>>()
    fileprivate var reachabilityDidChange = SynchronizedArray<ReachabilityChangeObserver>()
    fileprivate var didReceiveApplicationContext = SynchronizedArray<ReceiveApplicationContextObserver>()
    fileprivate var didReceiveUserInfo = SynchronizedArray<ReceiveUserInfoObserver>()
    fileprivate var didReceiveMessage = SynchronizedArray<ReceiveMessageObserver>()
    
    deinit {
        // Empty task queues of references
        activationDidCompleteSingle.removeAll()
        didBecomeInactive.removeAll()
        didDeactivate.removeAll()
        stateDidChange.removeAll()
        reachabilityDidChange.removeAll()
        didReceiveApplicationContext.removeAll()
        didReceiveUserInfo.removeAll()
        didReceiveMessage.removeAll()
    }
}

// MARK: - Location manager observers

public extension WatchSession {

    func addObserver(forInactive observer: Observer<() -> Void>) {
        didBecomeInactive += observer
    }

    func removeObserver(forInactive observer: Observer<() -> Void>) {
        didBecomeInactive -= observer
    }

    func addObserver(forDeactivate observer: Observer<() -> Void>) {
        didDeactivate += observer
    }

    func removeObserver(forDeactivate observer: Observer<() -> Void>) {
        didDeactivate -= observer
    }

    func addObserver(forStateChange observer: Observer<() -> Void>) {
        stateDidChange += observer
    }

    func removeObserver(forStateChange observer: Observer<() -> Void>) {
        stateDidChange -= observer
    }

    func addObserver(_ observer: ReachabilityChangeObserver) {
        reachabilityDidChange += observer
    }

    func removeObserver(_ observer: ReachabilityChangeObserver) {
        reachabilityDidChange -= observer
    }

    func addObserver(forApplicationContext observer: ReceiveApplicationContextObserver) {
        didReceiveApplicationContext += observer
    }

    func removeObserver(forApplicationContext observer: ReceiveApplicationContextObserver) {
        didReceiveApplicationContext -= observer
    }

    func addObserver(forUserInfo observer: ReceiveUserInfoObserver) {
        didReceiveUserInfo += observer
    }

    func removeObserver(forUserInfo observer: ReceiveUserInfoObserver) {
        didReceiveUserInfo -= observer
    }

    func addObserver(forMessage observer: ReceiveMessageObserver) {
        didReceiveMessage += observer
    }

    func removeObserver(forMessage observer: ReceiveMessageObserver) {
        didReceiveMessage -= observer
    }
    
    func removeObservers(with prefix: String) {
        let prefix = prefix + "."
    
        didBecomeInactive.remove(where: { $0.id.hasPrefix(prefix) })
        didDeactivate.remove(where: { $0.id.hasPrefix(prefix) })
        stateDidChange.remove(where: { $0.id.hasPrefix(prefix) })
        reachabilityDidChange.remove(where: { $0.id.hasPrefix(prefix) })
        didReceiveApplicationContext.remove(where: { $0.id.hasPrefix(prefix) })
        didReceiveUserInfo.remove(where: { $0.id.hasPrefix(prefix) })
        didReceiveMessage.remove(where: { $0.id.hasPrefix(prefix) })
    }

    func removeObservers(from file: String = #file) {
        removeObservers(with: file)
    }
}

// MARK: - Nested types
public extension WatchSession {

    /// Handler queue types
    typealias ActivationHandler = (Bool) -> Void
    typealias ReachabilityChangeObserver = Observer<(Bool) -> Void>
    typealias ReceiveApplicationContextObserver = Observer<([String: Any]) -> Void>
    typealias ReceiveUserInfoObserver = Observer<([String: Any]) -> Void>
    typealias ReceiveMessageObserver = Observer<([String: Any], ([String: Any]) -> Void) -> Void>
}

public extension WatchSession {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        activationDidCompleteSingle.removeAll { $0.forEach { $0(activationState == .activated) } }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        didBecomeInactive.forEach { $0.handler() }
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        didDeactivate.forEach { $0.handler() }
    }
    
    func sessionWatchStateDidChange(_ session: WCSession) {
        stateDidChange.forEach { $0.handler() }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        reachabilityDidChange.forEach { $0.handler(session.isReachable) }
    }
}

public extension WatchSession {
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        didReceiveApplicationContext.forEach { observer in
            DispatchQueue.main.async { observer.handler(applicationContext) }
        }
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
        didReceiveUserInfo.forEach { observer in
            DispatchQueue.main.async { observer.handler(userInfo) }
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        didReceiveMessage.forEach { observer in
            DispatchQueue.main.async { observer.handler(message, replyHandler) }
        }
    }
}

public extension WatchSession {
    
    /// Determines if the watch is available.
    var isAvailable: Bool {
        guard let session = sessionDefault else { return false }
        
        #if os(iOS)
        return session.isPaired
            && session.isWatchAppInstalled
            && session.activationState == .activated
        #else
        return session.activationState == .activated
        #endif
    }
    
    /// The current activation state of the session.
    var activationState: WCSessionActivationState {
        guard let session = sessionDefault else { return .notActivated }
        return session.activationState
    }
    
    /// The most recent contextual data sent to the paired and active device.
    var applicationContext: [String: Any] {
        guard let session = sessionDefault else { return [:] }
        return session.applicationContext
    }
    
    /// Request the one-time delivery of the user’s current location.
    ///
    /// - Parameter completion: The completion with the location object.
    func activate(completion: ActivationHandler? = nil) {
        guard let session = sessionDefault else { completion?(false); return }
        guard session.activationState != .activated else { completion?(true); return }
        if let completion = completion {
            activationDidCompleteSingle += completion
        }
        session.activate()
    }
}

public extension WatchSession {
    
    /// Transfers the values to the watch and overwrite older requests.
    ///
    /// - Parameters:
    ///   - values: The dictionary of values.
    ///   - completion: The callback of the success of the transmission.
    func transfer(context values: [String: Any], completion: ((Result<Bool>) -> Void)? = nil) {
        guard !values.isEmpty else { completion?(.success(true)); return }
    
        activate {
            guard $0, self.isAvailable, let session = self.sessionDefault
                else { completion?(.failure(ZamzamError.notReachable)); return }
            
            var values = values
            values.removeAllNulls()
            
            do { try session.updateApplicationContext(values) }
            catch { completion?(.failure(error)); return }
            
            completion?(.success(true))
        }
    }
    
    /// Transfers the values to the watch in a queue.
    ///
    /// - Parameters:
    ///   - values: The dictionary of values.
    ///   - completion: The callback of the success with the transmission object.
    func transfer(userInfo values: [String: Any], completion: ((Result<WCSessionUserInfoTransfer?>) -> Void)? = nil) {
        guard !values.isEmpty else { completion?(.success(nil)); return }
    
        activate {
            guard $0, self.isAvailable, let session = self.sessionDefault
                else { completion?(.failure(ZamzamError.notReachable)); return }
            
            var values = values
            values.removeAllNulls()
            
            let transfer = session.transferUserInfo(values)
            completion?(.success(transfer))
        }
    }
    
    /// Sends a message immediately to the paired and active device and optionally handles a response.
    ///
    /// - Parameters:
    ///   - values: A dictionary of property list values that you want to send.
    ///   - completion: A reply handler for receiving a response from the counterpart, or the error.
    ///     The dictionary of property list values contains the response from the counterpart.
    func transfer(message values: [String: Any], completion: ((Result<[String: Any]>) -> Void)? = nil) {
        guard !values.isEmpty else { completion?(.success([:])); return }
    
        activate {
            guard $0, self.isAvailable, let session = self.sessionDefault
                else { completion?(.failure(ZamzamError.notReachable)); return }
            
            guard session.isReachable else { completion?(.failure(ZamzamError.general)); return }
            
            var values = values
            values.removeAllNulls()
            
            return session.sendMessage(values,
                replyHandler: { completion?(.success($0)) },
                errorHandler: { completion?(.failure($0)) }
            )
        }
    }
}

#if os(iOS)
public extension WatchSession {

    /// The number of remaining times you can send complication data from the iOS app to the WatchKit extension
    @available(iOS 10.0, *)
    var remainingComplicationTransfers: Int {
        guard let session = sessionDefault else { return 0 }
        return session.remainingComplicationUserInfoTransfers
    }
    
    /// A directory for storing information specific to the currently paired and active Apple Watch.
    var directoryURL: URL? {
        guard let session = sessionDefault else { return nil }
        return session.watchDirectoryURL
    }
    
    /// Transfers the values to the watch in a queue relevant to complications.
    ///
    /// - Parameters:
    ///   - values: The dictionary of values.
    ///   - completion: The callback of the success with the transmission object.
    func transfer(complication values: [String: Any], completion: ((Result<WCSessionUserInfoTransfer?>) -> Void)? = nil) {
        guard !values.isEmpty else { completion?(.success(nil)); return }
    
        activate {
            guard $0, self.isAvailable, let session = self.sessionDefault
                else { completion?(.failure(ZamzamError.notReachable)); return }
            
            guard session.isComplicationEnabled else { completion?(.failure(ZamzamError.general)); return }
            
            var values = values
            values.removeAllNulls()
            
            let transfer = session.transferCurrentComplicationUserInfo(values)
            completion?(.success(transfer))
        }
    }
}
#endif
