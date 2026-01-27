{-# LANGUAGE ImportQualifiedPost #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE BlockArguments #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE ViewPatterns #-}
{-# OPTIONS_GHC -Wall -fno-warn-tabs #-}

module Main (main) where

import Data.Function
import Data.Foldable
import Data.Vector qualified as V
import Data.Text qualified as T
import Data.Aeson
import Data.Aeson.KeyMap qualified as KM
import Network.WebSockets

main :: IO ()
main = do
	putStrLn "KYOMU"
	runServer "0.0.0.0" 10000 \pconn -> do
		putStrLn "HELLO"
		conn <- acceptRequest pconn
		fix \a -> do
			r <- receive conn
			case r of
				(DataMessage _ _ _ (Text jsn _)) -> do
					print @(Maybe Value) $ decode jsn
					let	mv = recToSend =<< decode jsn
					case mv of
						Nothing -> pure ()
						Just v -> do
							print v
							sendDataMessage conn $
								Text (encode v) Nothing
					a
				ControlMessage (Close _ _) -> putStrLn "CLOSE"
				_ -> print r >> a
		sendClose conn ("Good-bye!" :: T.Text)

recToSend :: Value -> Maybe Value
recToSend (Array (toList -> (String "EVENT" : Object ((KM.lookup "id") -> Just (String nm)) : _))) =
	Just . Array $ V.fromList [String "OK", String nm, Bool True, String ""]
recToSend (Array (toList -> (String "REQ" : String nm : _))) =
	Just . Array $ V.fromList [String "EOSE", String nm]
recToSend _ = Nothing
