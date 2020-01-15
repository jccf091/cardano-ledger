{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeApplications  #-}

module Test.Cardano.Chain.Genesis.Dummy
  ( dummyConfig
  , dummyK
  , dummyEpochSlots
  , dummySlotSecurityParam
  , dummyGenesisInitializer
  , dummyGenesisAvvmBalances
  , dummyGeneratedSecrets
  , dummyGenesisSigningKeys
  , dummyGenesisSigningKeysRich
  , dummyGenesisSigningKeysPoor
  , dummyGenesisSecretsRich
  , dummyGenesisSecretsPoor
  , dummyGenesisSpec
  , dummyProtocolParameters
  , dummyGenesisData
  , dummyGenesisHash
  )
where

import Cardano.Prelude

import Data.Time (Day(..), UTCTime(..))

import Cardano.Chain.Common
  ( BlockCount (..)
  , TxFeePolicy(..)
  , TxSizeLinear(..)
  , mkKnownLovelace
  , mkKnownLovelacePortion
  )
import Cardano.Chain.Genesis
  ( Config(..)
  , FakeAvvmOptions(..)
  , GeneratedSecrets(..)
  , GenesisAvvmBalances(..)
  , GenesisData(..)
  , GenesisDelegation(..)
  , GenesisHash(..)
  , GenesisInitializer(..)
  , GenesisSpec(..)
  , PoorSecret
  , TestnetBalanceOptions(..)
  , gsSigningKeys
  , gsSigningKeysPoor
  , generateGenesisConfigWithEntropy
  )
import Cardano.Chain.ProtocolConstants (kEpochSlots, kSlotSecurityParam)
import Cardano.Chain.Slotting (EpochNumber(..), EpochSlots, SlotCount)
import Cardano.Chain.Update (ProtocolParameters(..), SoftforkRule(..))
import Cardano.Crypto as Crypto (SigningKey, deterministic)

import qualified Test.Cardano.Crypto.Dummy as Dummy


dummyConfig           :: Config
dummyGeneratedSecrets :: GeneratedSecrets
(dummyConfig, dummyGeneratedSecrets) =
    either (panic . show) identity $
      Crypto.deterministic seed $ -- supply fake entropy to make this pure
        runExceptT $
          generateGenesisConfigWithEntropy startTime dummyGenesisSpec
  where
    seed :: ByteString
    seed      = "\0"
    startTime = UTCTime (ModifiedJulianDay 0) 0

dummyK :: BlockCount
dummyK = BlockCount 10

dummyEpochSlots :: EpochSlots
dummyEpochSlots = kEpochSlots dummyK

dummySlotSecurityParam :: SlotCount
dummySlotSecurityParam = kSlotSecurityParam dummyK

dummyGenesisSecretsRich :: [SigningKey]
dummyGenesisSecretsRich = gsRichSecrets dummyGeneratedSecrets

dummyGenesisSecretsPoor :: [PoorSecret]
dummyGenesisSecretsPoor = gsPoorSecrets dummyGeneratedSecrets

dummyGenesisSigningKeys :: [SigningKey]
dummyGenesisSigningKeys = gsSigningKeys dummyGeneratedSecrets

dummyGenesisSigningKeysRich :: [SigningKey]
dummyGenesisSigningKeysRich = gsRichSecrets dummyGeneratedSecrets

dummyGenesisSigningKeysPoor :: [SigningKey]
dummyGenesisSigningKeysPoor = gsSigningKeysPoor dummyGeneratedSecrets

dummyGenesisSpec :: GenesisSpec
dummyGenesisSpec = UnsafeGenesisSpec
  { gsAvvmDistr   = dummyGenesisAvvmBalances
  , gsHeavyDelegation = UnsafeGenesisDelegation mempty
  , gsProtocolParameters = dummyProtocolParameters
  , gsK           = dummyK
  , gsProtocolMagic = Dummy.protocolMagic
  , gsInitializer = dummyGenesisInitializer
  }

dummyGenesisAvvmBalances :: GenesisAvvmBalances
dummyGenesisAvvmBalances = GenesisAvvmBalances mempty

dummyProtocolParameters :: ProtocolParameters
dummyProtocolParameters = ProtocolParameters
  { ppScriptVersion     = 0
  , ppSlotDuration      = 7000
  , ppMaxBlockSize      = 2000000
  , ppMaxHeaderSize     = 2000000
  , ppMaxTxSize         = 4096
  , ppMaxProposalSize   = 700
  , ppMpcThd            = mkKnownLovelacePortion @10000000000000
  , ppHeavyDelThd       = mkKnownLovelacePortion @5000000000000
  , ppUpdateVoteThd     = mkKnownLovelacePortion @1000000000000
  , ppUpdateProposalThd = mkKnownLovelacePortion @100000000000000
  , ppUpdateProposalTTL = 10
  , ppSoftforkRule      = SoftforkRule
    (mkKnownLovelacePortion @900000000000000)
    (mkKnownLovelacePortion @600000000000000)
    (mkKnownLovelacePortion @50000000000000)
  , ppTxFeePolicy       = TxFeePolicyTxSizeLinear
    (TxSizeLinear (mkKnownLovelace @155381) (mkKnownLovelace @44))
  , ppUnlockStakeEpoch  = EpochNumber maxBound
  }

dummyGenesisInitializer :: GenesisInitializer
dummyGenesisInitializer = GenesisInitializer
  { giTestBalance = TestnetBalanceOptions
    { tboPoors          = 12
    , tboRichmen        = 4
    , tboTotalBalance   = mkKnownLovelace @6000000000000000
    , tboRichmenShare   = mkKnownLovelacePortion @990000000000000
    }
  , giFakeAvvmBalance = FakeAvvmOptions
    { faoCount      = 10
    , faoOneBalance = mkKnownLovelace @100000
    }
  , giAvvmBalanceFactor = mkKnownLovelacePortion @1000000000000000
  , giUseHeavyDlg = True
  , giSeed        = 0
  }

dummyGenesisData :: GenesisData
dummyGenesisData = configGenesisData dummyConfig

dummyGenesisHash :: GenesisHash
dummyGenesisHash = configGenesisHash dummyConfig
