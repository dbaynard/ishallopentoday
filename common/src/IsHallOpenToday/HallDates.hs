{-# LANGUAGE OverloadedStrings #-}    
{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE ViewPatterns #-}
{-# LANGUAGE DeriveGeneric #-}

module IsHallOpenToday.HallDates (
    module IsHallOpenToday.HallDates
  , Day
  , Day
  , runIdentity
)   where

import BasicPrelude
import IsHallOpenToday.Lens
import GHC.Generics

import Data.Aeson
import Data.Thyme
import System.Locale
import Data.String.Conv
import Data.Functor.Identity

class (Monad m) => MonadTime m where
    getTime :: m UTCTime

instance MonadTime IO where
    getTime = getCurrentTime

instance MonadTime Identity where
    getTime = pure $ read "2016-06-24 04:40:00 GMT"

defaultDay :: Day
defaultDay = read "2016-06-24"

data Message = Checking
             | NoHallToday
             | BreakFastToday
             | LunchToday
             | BandLToday
             | BrunchToday
             | DinnerToday
             | MCRDinnerToday
             | NoHallForAges
             | MaybeHall
             deriving (Show, Eq, Ord, Read, Enum, Bounded, Generic)

instance FromJSON Message
instance ToJSON Message

interpret :: Message -> Text
interpret Checking       = "Checking…"
interpret NoHallToday    = "Hall is closed today."
interpret BreakFastToday = "Hall is serving breakfast today."
interpret LunchToday     = "Hall is serving lunch today."
interpret BandLToday     = "Hall is serving breakfast and lunch today."
interpret BrunchToday    = "Hall is serving brunch today."
interpret DinnerToday    = "Hall is serving dinner today, 17:45 to 18:30."
interpret MCRDinnerToday = "Hall is serving breakfast and lunch today. And there’s an MCR dinner tonight!"
interpret NoHallForAges  = "Hall is closed until August 31st."
interpret MaybeHall      = "Who knows. Better get on your bike."

displayDay :: Day -> Text
displayDay = toS . formatTime ukTimeLocale "%A %e %B %Y"

ishallopen :: MonadTime m => m Message
ishallopen = ishallopentoday <$> getToday

getToday :: MonadTime m => m Day
getToday = view _utctDay <$> getTime

getToday :: MonadTime m => m Day
getToday = view _utctDay <$> getTime

ishallopentoday :: Day -> Message
ishallopentoday (subtract 57564 . view modifiedJulianDay -> day)
    | day == 17             = MCRDinnerToday
    | day >= 96 || day < 0  = MaybeHall
    | day < 48 || day >= 67 = 
        case day `mod` 7 of
            0 -> NoHallToday
            1 -> DinnerToday
            _ -> BandLToday
    | day >= 48 && day < 68 = NoHallForAges
    | otherwise             = MaybeHall

ukTimeLocale :: TimeLocale
ukTimeLocale = defaultTimeLocale { dateFmt = "%d/%m/%Y" }
