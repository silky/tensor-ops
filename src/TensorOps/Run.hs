{-# LANGUAGE DataKinds           #-}
{-# LANGUAGE FlexibleContexts    #-}
{-# LANGUAGE GADTs               #-}
{-# LANGUAGE LambdaCase          #-}
{-# LANGUAGE PolyKinds           #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TupleSections       #-}
{-# LANGUAGE TypeOperators       #-}

module TensorOps.Run where

-- import           Control.Arrow                       ((&&&))
-- import           Data.Bifunctor
-- import           Data.Functor.Identity
-- import           Data.Singletons
-- import           Data.Singletons.Prelude.List hiding (Length)
-- import           Data.Type.Length
-- import           TensorOps.Tensor
-- import           Type.Class.Known
-- import           Type.Family.List
-- import           Type.Family.List.Util
import           Data.Singletons
import           Data.Type.Combinator
import           Data.Type.Product hiding               (append')
import           Data.Type.Product.Util
import           Data.Type.Sing
import           Data.Type.Uniform
import           TensorOps.Types
import           Type.Class.Witness

runTOp
    :: forall (ns :: [[k]]) (ms :: [[k]]) (t :: [k] -> *).
     ( Tensor t
     , Floating (ElemT t)
     )
    => Sing ns
    -> Sing ms
    -> TOp ns ms
    -> Prod t ns
    -> Prod t ms
runTOp sNs sMs = (\case
    Lift uNs uMs f -> case uMs of
                        UØ   -> \_ -> Ø
                        US _ -> vecToProd getI uMs . liftT f . prodToVec I uNs
                                  \\ uniformLength uMs
    GMul lM lO lN  -> \case
      x :< y :< Ø  -> only (gmul lM lO lN x y)
    Transp _       -> only . transp . head'
    Shuffle i      -> select i
    ) \\ witSings sNs
      \\ witSings sMs
    -- Fold _ f       -> only . foldT f     . head'

runTensorOp
    :: forall t ns ms. (Tensor t, Floating (ElemT t))
    => TensorOp ns ms
    -> Prod t ns
    -> Prod t ms
runTensorOp = \case
    OPØ                 -> id
    Pop sA sB sD o os -> runTensorOp os
                       . overProdInit (singLength sA)
                                      (singLength sD)
                                      (runTOp sA sB o)

    -- OP1 o    -> runTOp o
    -- oL :. oR -> runTensorOp oR . runTensorOp oL
    -- oL :* oR -> overProdSplit known (runTensorOp oL) (runTensorOp oR)
    -- oL :& oR -> uncurry append' . (runTensorOp oL &&& runTensorOp oR)
