{-# LANGUAGE DeriveGeneric   #-}
{-# LANGUAGE TemplateHaskell #-}

module Cardano.Chain.Genesis.Initializer
  ( GenesisInitializer(..)
  , TestnetBalanceOptions(..)
  , FakeAvvmOptions(..)
  )
where

import Cardano.Prelude

import Cardano.Chain.Common (Lovelace, LovelacePortion)

-- | Options determining generated genesis stakes, balances, and delegation
data GenesisInitializer = GenesisInitializer
  { giTestBalance       :: !TestnetBalanceOptions
  , giFakeAvvmBalance   :: !FakeAvvmOptions
  , giAvvmBalanceFactor :: !LovelacePortion
  -- ^ Avvm balances will be multiplied by this factor
  , giUseHeavyDlg       :: !Bool
  -- ^ Whether to use heavyweight delegation for genesis keys
  } deriving (Eq, Show)


-- | These options determine balances of nodes specific for testnet
data TestnetBalanceOptions = TestnetBalanceOptions
  { tboPoors          :: !Word
  -- ^ Number of poor nodes (with small balance).
  , tboRichmen        :: !Word
  -- ^ Number of rich nodes (with huge balance).
  , tboTotalBalance   :: !Lovelace
  -- ^ Total balance owned by these nodes.
  , tboRichmenShare   :: !LovelacePortion
  -- ^ Portion of stake owned by all richmen together.
  } deriving (Eq, Show)


-- | These options determines balances of fake AVVM nodes which didn't really go
--   through vending, but pretend they did
data FakeAvvmOptions = FakeAvvmOptions
  { faoCount      :: !Word
  , faoOneBalance :: !Lovelace
  } deriving (Eq, Show, Generic)

