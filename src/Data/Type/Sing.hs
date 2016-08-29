{-# LANGUAGE GADTs               #-}
{-# LANGUAGE LambdaCase          #-}
{-# LANGUAGE PolyKinds           #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeOperators       #-}

module Data.Type.Sing where

import           Data.Singletons
import           Data.Singletons.Prelude.List hiding (Length, Reverse)
import           Data.Type.Length
import           Data.Type.Uniform
import           Type.Class.Witness
import           Type.Family.List

singLength
    :: Sing ns
    -> Length ns
singLength = \case
    SNil        -> LZ
    _ `SCons` s -> LS (singLength s)

singSings
    :: forall ns. ()
    => SingI ns :- ListC (SingI <$> ns)
singSings = Sub (go (sing :: Sing ns))
  where
    go :: forall ms. ()
       => Sing ms
       -> Wit (ListC (SingI <$> ms))
    go = \case
      SNil         -> Wit
      s `SCons` ss -> case go ss of
                        Wit -> withSingI s Wit

-- uniformSings
--     :: forall a as. ()
--     => Uniform a as
--     -> SingI as :- SingI a
-- uniformSings u = Sub (go u sing)
--   where
--     go :: forall bs. ()
--        => Uniform a bs
--        -> Sing bs
--        -> Wit (SingI a)
--     go = \case
--       UØ   -> \case
--         SNil        -> Wit
--       US _ -> \case
--         s `SCons` _ -> withSingI s Wit


reverseReverseSing
    :: Sing as
    -> (as :~: Reverse (Reverse as))
reverseReverseSing = undefined

entailSing
    :: forall a b. ()
    => (Sing a -> Sing b)
    -> (SingI a :- SingI b)
entailSing f = Sub $ withSingI (f (sing :: Sing a)) Wit

entailSing2
    :: forall a b c. ()
    => (Sing a -> Sing b -> Sing c)
    -> ((SingI a, SingI b) :- SingI c)
entailSing2 f = Sub $ withSingI (f (sing :: Sing a) (sing :: Sing b)) Wit

sAppend
    :: Sing as
    -> Sing bs
    -> Sing (as ++ bs)
sAppend = \case
    SNil         -> id
    x `SCons` xs -> \ys ->
      x `SCons` sAppend xs ys
