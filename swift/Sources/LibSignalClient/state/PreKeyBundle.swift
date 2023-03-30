//
// Copyright 2020-2022 Signal Messenger, LLC.
// SPDX-License-Identifier: AGPL-3.0-only
//

import SignalFfi
import Foundation

public class PreKeyBundle: NativeHandleOwner {
    internal override class func destroyNativeHandle(_ handle: OpaquePointer) -> SignalFfiErrorRef? {
        return signal_pre_key_bundle_destroy(handle)
    }

    // with a prekey
    public convenience init<Bytes: ContiguousBytes>(registrationId: UInt32,
                                                    deviceId: UInt32,
                                                    prekeyId: UInt32,
                                                    prekey: PublicKey,
                                                    signedPrekeyId: UInt32,
                                                    signedPrekey: PublicKey,
                                                    signedPrekeySignature: Bytes,
                                                    identity identityKey: IdentityKey) throws {
        var result: OpaquePointer?
        try withNativeHandles(prekey, signedPrekey, identityKey.publicKey) { prekeyHandle, signedPrekeyHandle, identityKeyHandle in
            try signedPrekeySignature.withUnsafeBorrowedBuffer {
                try checkError(signal_pre_key_bundle_new(&result,
                                                         registrationId,
                                                         deviceId,
                                                         prekeyId,
                                                         prekeyHandle,
                                                         signedPrekeyId,
                                                         signedPrekeyHandle,
                                                         $0,
                                                         identityKeyHandle))
            }

        }
        self.init(owned: result!)
    }

    // without a prekey
    public convenience init<Bytes: ContiguousBytes>(registrationId: UInt32,
                                                    deviceId: UInt32,
                                                    signedPrekeyId: UInt32,
                                                    signedPrekey: PublicKey,
                                                    signedPrekeySignature: Bytes,
                                                    identity identityKey: IdentityKey) throws {
        var result: OpaquePointer?
        try withNativeHandles(signedPrekey, identityKey.publicKey) { signedPrekeyHandle, identityKeyHandle in
            try signedPrekeySignature.withUnsafeBorrowedBuffer {
                try checkError(signal_pre_key_bundle_new(&result,
                                                         registrationId,
                                                         deviceId,
                                                         ~0,
                                                         nil,
                                                         signedPrekeyId,
                                                         signedPrekeyHandle,
                                                         $0,
                                                         identityKeyHandle))
            }
        }
        self.init(owned: result!)
    }

    public var registrationId: UInt32 {
        return withNativeHandle { nativeHandle in
            failOnError {
                try invokeFnReturningInteger {
                    signal_pre_key_bundle_get_registration_id($0, nativeHandle)
                }
            }
        }
    }

    public var deviceId: UInt32 {
        return withNativeHandle { nativeHandle in
            failOnError {
                try invokeFnReturningInteger {
                    signal_pre_key_bundle_get_device_id($0, nativeHandle)
                }
            }
        }
    }

    public var signedPreKeyId: UInt32 {
        return withNativeHandle { nativeHandle in
            failOnError {
                try invokeFnReturningInteger {
                    signal_pre_key_bundle_get_signed_pre_key_id($0, nativeHandle)
                }
            }
        }
    }

    public var preKeyId: UInt32? {
        let prekey_id = withNativeHandle { nativeHandle in
            failOnError {
                try invokeFnReturningInteger {
                    signal_pre_key_bundle_get_signed_pre_key_id($0, nativeHandle)
                }
            }
        }

        if prekey_id == ~0 {
            return nil
        } else {
            return prekey_id
        }
    }

    public var preKeyPublic: PublicKey? {
        return withNativeHandle { nativeHandle in
            failOnError {
                try invokeFnReturningOptionalNativeHandle {
                    signal_pre_key_bundle_get_pre_key_public($0, nativeHandle)
                }
            }
        }
    }

    public var identityKey: IdentityKey {
        let pk: PublicKey = withNativeHandle { nativeHandle in
            failOnError {
                try invokeFnReturningNativeHandle {
                    signal_pre_key_bundle_get_identity_key($0, nativeHandle)
                }
            }
        }
        return IdentityKey(publicKey: pk)
    }

    public var signedPreKeyPublic: PublicKey {
        return withNativeHandle { nativeHandle in
            failOnError {
                try invokeFnReturningNativeHandle {
                    signal_pre_key_bundle_get_signed_pre_key_public($0, nativeHandle)
                }
            }
        }
    }

    public var signedPreKeySignature: [UInt8] {
        return withNativeHandle { nativeHandle in
            failOnError {
                try invokeFnReturningArray {
                    signal_pre_key_bundle_get_signed_pre_key_signature($0, $1, nativeHandle)
                }
            }
        }
    }
}
