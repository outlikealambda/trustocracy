module Influence
( Influence(..)
, updateTotal
, increment
, decrement
, updatePuid
, Uid
, Puid
) where

type Uid = Int
type Puid = Int

data Influence = Influence { uid :: Uid       -- ^ influence user id
                           , puid :: Puid      -- ^ parent uid
                           , total :: Int -- ^ current influence
                           , note :: String   -- ^ testimony?
                           } deriving (Show)

updateTotal :: (Int -> Int) -> Influence -> Influence
updateTotal f (Influence uid puid total note) = Influence uid puid (f total) note

increment :: Influence -> Influence
increment infl = updateTotal (+ 1) infl

decrement :: Influence -> Influence
decrement infl = updateTotal (+ (-1)) infl

updatePuid :: Puid -> Influence -> Influence
updatePuid puid (Influence uid _ total note) = Influence uid puid total note
