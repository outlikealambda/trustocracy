{-# LANGUAGE ViewPatterns #-}

module Zipper
( Zipper
, extractUpdate
, insertUpdate
, examineNode
) where

import Tree
import Model

type Crumb a = Tree a
type Zipper a = (Tree a, [Crumb a])

extractUpdate :: Keyed a
    => (a -> a -> a)      -- ^ updating function; takes the extracted tree as 1st param
    -> Directions         -- ^ directions to get to the tree
    -> Zipper a           -- ^ fully zipped zipper
    -> (Zipper a, Tree a) -- ^ (zipper without tree, tree)

extractUpdate f ds z = let (zippedDown, target) = extractSubTree ds z
                       in (updateToTop (alterNode f target) zippedDown, target)

insertUpdate :: Keyed a
    => (a -> a -> a)    -- ^ updating function, takes the inserted tree as 1st param
    -> Directions       -- ^ directions to the new parent
    -> Tree a           -- ^ tree to insert
    -> Zipper a         -- ^ fully zipped zipper
    -> Zipper a         -- ^ zipper with new tree

insertUpdate f ds tree z = updateToTop (alterNode f tree) (insertSubTree ds tree z)

examineNode :: Directions
            -> Zipper a
            -> Tree a
-- is there a way to _not_ pattern match here?
examineNode ds z = fst $ unzipperTo ds z

unzipperTo :: Directions -> Zipper a -> Zipper a
unzipperTo [] z = z
unzipperTo (d:ds) z = unzipperTo ds $ unzipper d z

unzipper :: Direction -> Zipper a -> Zipper a
unzipper k (t, crumbs) = (getBranch k t, (deleteBranch k t):crumbs)

zipper :: Keyed a => Zipper a -> Zipper a
zipper (t, parent:crumbs) = (createBranch t parent, crumbs)

zipperSkip :: Zipper a -> Zipper a
zipperSkip (_, parent:crumbs) = (parent, crumbs)


extractSubTree :: Directions -> Zipper a -> (Zipper a, Tree a)
extractSubTree ds z = let zipTarget = unzipperTo ds z
                      in (zipperSkip zipTarget, fst zipTarget)

insertSubTree :: Keyed a => Directions -> Tree a -> Zipper a -> Zipper a
insertSubTree ds tree z = let (parentTree, crumbs) = unzipperTo ds z
                          in (createBranch tree parentTree, crumbs)

updateToTop :: Keyed a => (Tree a -> Tree a) -> Zipper a -> Zipper a
updateToTop f (t, []) = (f t, [])
updateToTop f (t, crumbs) = updateToTop f (zipper (f t, crumbs))

alterNode :: (a -> a -> a) -> Tree a -> Tree a -> Tree a
alterNode f (Node v1 _) (Node v2 children) = Node (f v1 v2) children
