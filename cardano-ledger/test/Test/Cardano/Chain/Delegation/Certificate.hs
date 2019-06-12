{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell   #-}

module Test.Cardano.Chain.Delegation.Certificate
  ( tests
  )
where

import Cardano.Prelude

import qualified Data.ByteString.Lazy as BSL

import Hedgehog (Group, Property, assert, discover, forAll, property)
import qualified Hedgehog.Gen as Gen

import Cardano.Binary (decodeFull, serialize, slice)
import Cardano.Chain.Delegation
  (ACertificate(delegateVK), Certificate, isValid, mkCertificate)

import Test.Cardano.Chain.Slotting.Gen (genEpochIndex)
import qualified Test.Cardano.Crypto.Dummy as Dummy
import Test.Cardano.Crypto.Gen (genSafeSigner, genVerificationKey)


--------------------------------------------------------------------------------
-- Test Group
--------------------------------------------------------------------------------

tests :: Group
tests = $$discover

--------------------------------------------------------------------------------
-- Certificate Properties
--------------------------------------------------------------------------------

-- | Can validate 'Certificate's produced by 'mkCertificate'
prop_certificateCorrect :: Property
prop_certificateCorrect = property $ do
  cert <-
    forAll
    $   mkCertificate Dummy.protocolMagicId
    <$> genSafeSigner
    <*> genVerificationKey
    <*> genEpochIndex

  let aCert = annotateCert cert

  assert $ isValid Dummy.annotatedProtocolMagicId aCert

-- | Cannot validate 'Certificate's with incorrect verification keys
prop_certificateIncorrect :: Property
prop_certificateIncorrect = property $ do
  cert <-
    forAll
    $   mkCertificate Dummy.protocolMagicId
    <$> genSafeSigner
    <*> genVerificationKey
    <*> genEpochIndex
  badDelegateVK <- forAll $ Gen.filter (/= delegateVK cert) genVerificationKey

  let
    badCert  = cert { delegateVK = badDelegateVK }
    aBadCert = annotateCert badCert

  assert . not $ isValid Dummy.annotatedProtocolMagicId aBadCert

annotateCert :: Certificate -> ACertificate ByteString
annotateCert cert =
  fmap (BSL.toStrict . slice bytes)
    . fromRight
        (panic "prop_certificateCorrect: Round trip broken for Certificate")
    $ decodeFull bytes
  where bytes = serialize cert