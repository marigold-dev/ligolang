
module AST.Completion where

import Data.Function (on)
import Data.List (isSubsequenceOf, nubBy)
import Data.Maybe (listToMaybe)
import Data.Text (Text)
import qualified Data.Text as Text

import Duplo.Lattice
import Duplo.Pretty
import Duplo.Tree

import AST.Scope
import AST.Skeleton
import Product
import Range

data Completion = Completion
  { cName :: Text
  , cType :: Text
  , cDoc  :: Text
  }
  deriving (Show)

complete
  :: ( Eq (Product xs)
     , Modifies (Product xs)
     , Contains Range xs
     , Contains [ScopedDecl] xs
     , Contains (Maybe Category) xs
     )
  => Range
  -> LIGO (Product xs)
  -> Maybe [Completion]
complete r tree = do
  let l = spineTo (leq r . getElem) tree
  word <- listToMaybe l
  let scope   = getElem (extract word)
  let nameCat = getElem (extract word)
  return
    $ filter (isSubseqOf (ppToText word) . cName)
    $ nubBy ((==) `on` cName)
    $ map asCompletion
    $ filter (fits nameCat . catFromType)
    $ scope

asCompletion :: ScopedDecl -> Completion
asCompletion sd = Completion
  { cName = ppToText (_sdName sd)
  , cType = ppToText (_sdType sd)
  , cDoc  = ppToText (fsep $ map pp $ _sdDoc sd)
  }

isSubseqOf :: Text -> Text -> Bool
isSubseqOf l r =
  -- traceShow (l, r, isSubsequenceOf (Text.unpack l) (Text.unpack r)) $
  isSubsequenceOf (Text.unpack l) (Text.unpack r)

fits :: Maybe Category -> Category -> Bool
fits  Nothing _  = True
fits (Just c) c' = c == c'

catFromType :: ScopedDecl -> Category
catFromType = maybe Variable (either (const Variable) (const Type)) . _sdType
