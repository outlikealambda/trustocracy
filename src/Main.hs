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
    STM.atomically $ do
        TMap.insert (Influence 1 0 3 "") 1 tmap
        TMap.insert (Influence 2 1 1 "") 2 tmap
        TMap.insert (Influence 3 1 1 "") 3 tmap
    ancestors <- getAncestorChain 3 tmap
    putStrLn $ unwords $ fmap show ancestors
    success <- STM.atomically $ tryMove 3 2 tmap
    ancestors <- getAncestorChain 3 tmap
    putStrLn $ unwords $ fmap show ancestors

tryMove :: Inf.Uid -> Inf.Puid -> TMap.Map Inf.Uid Influence -> STM (Either String Influence)
tryMove uid targetPuid tmap = do
    -- check if target parent is a child of uid
    isCircular <- hasAncestor targetPuid uid tmap
    case isCircular of
        False -> tryUpdate (Inf.updatePuid targetPuid) uid tmap
        True -> return $ Left $ "targetPuid " ++ (show targetPuid) ++ " is already a child of Uid " ++ (show uid) ++ ". This would create a circular reference"

tryUpdate :: (Influence -> Influence) -> Inf.Uid -> TMap.Map Inf.Uid Influence -> STM (Either String Influence)
tryUpdate f uid tmap = do
    influenceM <- TMap.lookup uid tmap
    case influenceM of
        Just infl -> do
            let updated = f infl
            TMap.insert updated uid tmap
            return (Right updated)
        Nothing -> return $ Left $ "Unable to update, couldn't find: " ++ (show uid)

getAncestorChain :: Inf.Uid -> TMap.Map Inf.Uid Influence ->  IO [Influence]
getAncestorChain uid tmap = do
    influenceM <- STM.atomically $ TMap.lookup uid tmap
    case influenceM of
        Just (Influence uid puid total note) -> do
            ancestorChain <- getAncestorChain puid tmap
            return $ (Influence uid puid total note) : ancestorChain
        Nothing -> return []

hasAncestor :: Inf.Uid -> Inf.Puid -> TMap.Map Inf.Uid Influence -> STM Bool
hasAncestor uid targetUid tmap = do
    influenceM <- TMap.lookup uid tmap
    case influenceM of
        Just (Influence _ nextUid _ _)
            | nextUid == targetUid -> return True
            | otherwise -> hasAncestor nextUid targetUid tmap
        Nothing -> return False
