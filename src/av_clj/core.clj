(ns av-clj.core
    (:use [overtone.core]))

(defn connect
  "Connect to SuperCollider and redirect audio"
  []
  (connect-external-server)
  (definst external [] (sound-in 0))
  (external))

(defn disconnect
  "Disconnect from SuperCollider"
  []
  (kill-server))

(defn av
  "Start AV"
  []
  (require '[shadertone.tone :as t])
  (t/start "resources/shaders/zoomwave.glsl" :textures [:overtone-audio :previous-frame]))
