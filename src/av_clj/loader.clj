(ns av-clj.loader
    (:use [overtone.live]))

;(connect-external-server)

(definst external-l [] (sound-in 0))
(definst external-r [] (sound-in 1))

(defn external-lr
  []
  (do
    (external-l)
    (external-r)))

(external-lr)
