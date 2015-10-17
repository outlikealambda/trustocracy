module Main where

import Zipper
import Tree
import Model

import Data.Map as M

main :: IO ()
main = do
  putStrLn "hello world"

moveVote :: (Directions, Directions) -> Zipper Vote -> Zipper Vote
moveVote (sourceDs, targetDs) z = let (newZipper, targetTree) = extractUpdate loseInfluence sourceDs z
                                  in insertUpdate gainInfluence targetDs targetTree z

loseInfluence = alterInfluence (flip (-))
gainInfluence = alterInfluence (+)

testTree :: Tree Vote
testTree =
    Node (makeVote 0)
            (M.fromList [(10, Node (makeVote 10) M.empty)
                        ,(11, Node (makeVote 11) M.empty)
                        ,(12, Node (makeVote 12)
                            (M.fromList [(100, Node (makeVote 100) M.empty)
                                        ,(101, Node (makeVote 101) M.empty)]))])

makeVote :: Int -> Vote
makeVote uid = (Vote uid 1 "")

alterInfluence :: (Int -> Int -> Int) -> Vote -> Vote -> Vote
alterInfluence f (Vote _ infl1 _) (Vote uid infl2 c) = Vote uid (f infl1 infl2) c
