module Model
( Vote(..)
, Key
, Keyed(..)
, Direction
, Directions
) where

type Key = Int
type Direction = Key
type Directions = [Key]

class Keyed a where
    getKey :: a -> Key

data Vote = Vote { uid :: Int
                 , influence :: Int
                 , note :: String
                 } deriving (Show)

instance Keyed Vote where
    getKey = uid
