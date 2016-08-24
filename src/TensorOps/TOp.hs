{-# LANGUAGE DataKinds     #-}
{-# LANGUAGE GADTs         #-}
{-# LANGUAGE LambdaCase    #-}
{-# LANGUAGE RankNTypes    #-}
{-# LANGUAGE TypeOperators #-}

module TensorOps.TOp where

-- import           Type.Class.Known
import           Data.Type.Combinator
import           Data.Type.Equality
import           Data.Type.Index
import           Data.Type.Product
import           Data.Type.Uniform
import           Data.Type.Vector
import           Prelude hiding         (map, replicate)
import           TensorOps.Types hiding (OpPipe(..))
import           Type.Class.Witness
import           Type.Family.Nat
import qualified Control.Foldl          as F

map :: Uniform n ns
    -> (forall a. Floating a => a -> a)
    -> TOp ns ns
map u f = Lift u u (fmap f)

zip :: Uniform n ns
    -> (forall a. Floating a => Vec (Len ns) a -> a)
    -> TOp ns '[n]
zip u f = Lift u (US UØ) ((:+ ØV) . f)

zip2
    :: (forall a. Floating a => a -> a -> a)
    -> TOp '[ n, n ] '[ n ]
zip2 f = Lift (US (US UØ)) (US UØ)
              (\case I x :* I y :* ØV -> f x y :+ ØV)

zip3
    :: (forall a. Floating a => a -> a -> a -> a)
    -> TOp '[ n, n, n ] '[ n ]
zip3 f = Lift (US (US (US UØ)))
              (US UØ)
              (\case I x :* I y :* I z :* ØV -> f x y z :+ ØV)

replicate
    :: Uniform n ns
    -> TOp '[ n ] ns
replicate u = Lift (US UØ)
                   u
                   (\case x :* ØV -> vrep x \\ u)

transpose :: TOp '[ '[m,n] ] '[ '[n,m] ]
transpose = Transp Refl (IS IZ :< IZ :< Ø)

sum :: TOp '[n ': ns] '[ns]
sum = Fold F.sum