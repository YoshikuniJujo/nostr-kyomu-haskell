{-# LANGUAGE ImportQualifiedPost #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE BlockArguments #-}
{-# OPTIONS_GHC -Wall -fno-warn-tabs #-}

module Main (main) where

import Data.Function
import Data.Text qualified as T
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
				dm@(DataMessage _ _ _ _) -> send conn dm >> a
				ControlMessage (Close _ _) -> putStrLn "CLOSE"
				_ -> print r >> a
		sendClose conn ("Good-bye!" :: T.Text)
