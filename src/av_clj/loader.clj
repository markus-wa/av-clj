(ns av-clj.loader
    (:use [overtone.core]))

(connect-external-server)

(definst external [] (sound-in 0))

(external)
