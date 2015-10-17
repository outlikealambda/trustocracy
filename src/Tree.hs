module Tree
( Tree(..)
, getBranch
, deleteBranch
, createBranch
) where

import Data.Map as M
import Model

data Tree a = Node { element :: a
                   , children :: M.Map Int (Tree a)
                   } deriving (Show)

getBranch :: Int    -- ^ branch key
          -> Tree a -- ^ parent tree
          -> Tree a -- ^ branch tree

getBranch key (Node _ siblings) = siblings ! key

deleteBranch :: Int    -- ^ branch key
             -> Tree a -- ^ parent tree
             -> Tree a -- ^ parent tree sans child

deleteBranch key (Node v siblings) = Node v (M.delete key siblings)

createBranch :: Keyed a
             => Tree a  -- ^ branch tree
             -> Tree a  -- ^ parent tree
             -> Tree a  -- ^ parent tree with new branch

createBranch child (Node v siblings) = Node v (M.insert (getTreeKey child) child siblings)

getTreeKey :: Keyed a => Tree a -> Int
getTreeKey (Node element _) = getKey element
