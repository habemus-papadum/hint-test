{-# LANGUAGE OverloadedStrings #-}

module Main where

-- import Lib
import Language.Haskell.Interpreter
import Criterion.Main
import Data.Time
import Markup
import Text.Blaze.Html5 hiding (main)
import Text.Blaze.Html.Renderer.String


main :: IO ()
main = do
  x <- runInterpreter $ do
    spath <- get searchPath
    set [installedModulesInScope := True]
    liftIO $ putStrLn ("SEARCH PATH: " ++ (show spath))
    setImportsQ
      [
        ("Prelude", Nothing)
      , ("Data.Monoid", Nothing)
      -- , ("Text.Blaze.Html5", Nothing)
      -- , ("Text.Blaze.Html5.Attributes", Nothing)
      , ("Data.Time", Nothing)
      ]
    loadModules ["app/PluginMarkup.hs"]
    setImportsQ [("PluginMarkup", Nothing)]
    renderViaPlugin <- interpret "foliage" (as :: UTCTime -> Html)
    return renderViaPlugin

  case x of
    Left e -> putStrLn ("Error while running the interpreter: " ++ (show e))
    Right renderViaPlugin -> defaultMain
      [
        bench "without hint" $ nfIO $ generateMarkup foliage
      , bench "with hint" $ nfIO $ generateMarkup renderViaPlugin
      ]

generateMarkup :: (UTCTime -> Html) -> IO ()
generateMarkup renderFn = do
  tm <- getCurrentTime
  writeFile "/tmp/output.html" (renderHtml $ renderFn tm) 


-- [
--   GhcError {errMsg = "app/PluginMarkup.hs:9:1: error:\n    Failed to load interface for \8216Text.Blaze.Html5\8217\n    Use -v to see a list of the files searched for."},
--   GhcError {errMsg = "app/PluginMarkup.hs:10:1: error:\n    Failed to load interface for \8216Text.Blaze.Html5\8217\n    Use -v to see a list of the files searched for."},
--   GhcError {errMsg = "app/PluginMarkup.hs:11:1: error:\n    Failed to load interface for \8216Text.Blaze.Html5.Attributes\8217\n    Use -v to see a list of the files searched for."},
--   GhcError {errMsg = "app/PluginMarkup.hs:12:1: error:\n    Failed to load interface for \8216Text.Blaze.Html5.Attributes\8217\n    Use -v to see a list of the files searched for."},GhcError {errMsg = "app/PluginMarkup.hs:9:1: error:\n    Failed to load interface for \8216Text.Blaze.Html5\8217\n    Use -v to see a list of the files searched for."},GhcError {errMsg = "app/PluginMarkup.hs:10:1: error:\n    Failed to load interface for \8216Text.Blaze.Html5\8217\n    Use -v to see a list of the files searched for."},GhcError {errMsg = "app/PluginMarkup.hs:11:1: error:\n    Failed to load interface for \8216Text.Blaze.Html5.Attributes\8217\n    Use -v to see a list of the files searched for."},GhcError {errMsg = "app/PluginMarkup.hs:12:1: error:\n    Failed to load interface for \8216Text.Blaze.Html5.Attributes\8217\n    Use -v to see a list of the files searched for."}]