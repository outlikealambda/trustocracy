module Main where

import Zipper
import Tree
import Model
import Influence as Inf

import Data.Maybe
import Data.Map as M
import STMContainers.Map as TMap
import Control.Concurrent.STM as STM

main :: IO ()
main = do
    tmap <- STM.atomically $ TMap.new
    STM.atomically $ TMap.insert (Influence 1 0 1 "") 1 tmap
    STM.atomically $ maybeUpdate Inf.increment 1 tmap
    STM.atomically $ maybeUpdate Inf.increment 1 tmap
    STM.atomically $ maybeUpdate (Inf.updatePuid 2) 1 tmap
    STM.atomically (do
        maybeUpdate Inf.increment 1 tmap
        maybeUpdate Inf.increment 1 tmap)
    Just inf <- STM.atomically $ maybeUpdate Inf.increment 1 tmap
    putStrLn $ show inf
    --     TMap.insert "hi" "one" tmarp
    --     tval <- TMap.lookup "one" tmarp
    --     bar tval tmarp)
    -- val2 <- STM.atomically (TMap.lookup "two" tmarp)
    -- val3 <- STM.atomically (TMap.lookup "three" tmarp)
    -- putStrLn $ fromMaybe "bye" val
    -- putStrLn $ fromMaybe "bye" val2
    -- putStrLn $ fromMaybe "bye" val3



    -- STM.atomically(bar val tmarp)
        -- do
        --     y <- x
        --     Just (TMap.insert y "two" tmarp))

-- foo :: Maybe String -> STM()
-- foo Just x = TMap.insert x "two"

-- bar :: Maybe String -> TMap.Map String String -> STM(Maybe String)
-- bar (Just x) tmap = do
--     TMap.insert x "two" tmap
--     return (Just x)
--     -- return Just x
-- bar Nothing tmap = return Nothing

maybeUpdate :: (Influence -> Influence) -> Int -> TMap.Map Int Influence -> STM (Maybe Influence)
maybeUpdate f uid tmap = do
    influenceM <- TMap.lookup uid tmap
    case influenceM of
        Just infl -> do
            let updated = f infl
            TMap.insert updated uid tmap
            return (Just updated)
        Nothing -> do return Nothing

hasAncestor :: Inf.Puid -> Inf.Uid -> TMap.Map Int Influence -> STM Bool
hasAncestor targetPuid uid tmap = do
    influenceM <- TMap.lookup uid tmap
    case influenceM of
        Just (Influence _ puid _ _)
            | puid == targetPuid -> return True
            | otherwise -> hasAncestor targetPuid puid tmap
        Nothing -> return False

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

-- updateString :: (String -> String) -> String -> TMap.Map String String -> STM (Maybe String)
-- updateString f key tmap = do
--     maybeval <- TMap.lookup key tmap
--     case maybeval of
--         Nothing ->

-- updateInfluence :: (Influence -> Influence) -> Int -> TMap.Map Int Influence -> STM ()
-- updateInfluence f key tmap = do
--     infl <- TMap.lookup key tmap
--     TMap.insert (f infl) key tmap
