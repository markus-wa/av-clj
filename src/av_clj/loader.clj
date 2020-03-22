(ns av-clj.loader
    (:use [overtone.live]))

;(connect-external-server)

(definst external [] (sound-in 0))

(external)
