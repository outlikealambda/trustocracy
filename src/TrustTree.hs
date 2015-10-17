{-# LANGUAGE ViewPatterns #-}

import Data.Map as M
import Data.Sequence as S

data Vote = Vote { uid :: Int
                 , influence :: Int
                 , note :: String } deriving (Show)

class Keyed a where
    getKey :: a -> Int

instance Keyed Vote where
    getKey = uid

data Tree a = Node { element :: a
                   , children :: Children a } deriving (Show)

type Children a = M.Map Int (Tree a)

-- :: child key -> parent -> child
getBranch :: Int -> Tree a -> Tree a
getBranch key (Node _ siblings) = siblings ! key

-- :: child key -> parent -> parent sans child
deleteBranch :: Int -> Tree a -> Tree a
deleteBranch key (Node v siblings) = Node v (M.delete key siblings)

-- :: child -> parent -> parent with child
createBranch :: Keyed a => Tree a -> Tree a -> Tree a
createBranch child (Node v siblings) = Node v (M.insert (getTreeKey child) child siblings)

getTreeKey :: Keyed a => Tree a -> Int
getTreeKey (Node element _) = getKey element

type Direction = Int
type Directions = S.Seq Direction

type Crumb a = Tree a
type Zipper a = (Tree a, [Crumb a])

tunzip :: Direction -> Zipper a -> Zipper a
tunzip k (t, crumbs) = (getBranch k t, (deleteBranch k t):crumbs)

tunzipTo :: Directions -> Zipper a -> Zipper a
tunzipTo (viewl -> S.EmptyL) z = z
tunzipTo (viewl -> d:<ds) z = tunzipTo ds (tunzip d z)

tzip :: Keyed a => Zipper a -> Zipper a
tzip (t, parent:crumbs) = (createBranch t parent, crumbs)

tzipSkip :: Zipper a -> Zipper a
tzipSkip (_, parent:crumbs) = (parent, crumbs)

extractUpdate :: Keyed a => (a -> a -> a) -> Directions -> Zipper a -> (Zipper a, Tree a)
extractUpdate f ds z = let (zippedDown, target) = extractSubTree ds z
                          in (updateToTop (alterNode f target) zippedDown, target)

insertUpdate :: Keyed a => (a -> a -> a) -> Directions -> Tree a -> Zipper a -> Zipper a
insertUpdate f ds tree z = updateToTop (alterNode f tree) (insertSubTree ds tree z)

extractSubTree :: Directions -> Zipper a -> (Zipper a, Tree a)
extractSubTree ds z = let zipTarget = tunzipTo ds z
                      in (tzipSkip zipTarget, fst zipTarget)

insertSubTree :: Keyed a => Directions -> Tree a -> Zipper a -> Zipper a
insertSubTree ds tree z = let (parentTree, crumbs) = tunzipTo ds z
                          in (createBranch tree parentTree, crumbs)

updateToTop :: Keyed a => (Tree a -> Tree a) -> Zipper a -> Zipper a
updateToTop f (t, []) = (f t, [])
updateToTop f (t, crumbs) = updateToTop f (tzip (f t, crumbs))

alterNode :: (a -> a -> a) -> Tree a -> Tree a -> Tree a
alterNode f (Node v1 _) (Node v2 children) = Node (f v1 v2) children

alterInfluence :: (Int -> Int -> Int) -> Vote -> Vote -> Vote
alterInfluence f (Vote _ infl1 _) (Vote uid infl2 c) = Vote uid (f infl1 infl2) c

-- for the exploring

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
