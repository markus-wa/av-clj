(ns av-clj.core
    (:use [av-clj.loader]
          [overtone.core]))

(require
 '[shadertone.tone :as t])

(defn disconnect
  "Disconnect from SuperCollider"
  []
  (kill-server))

(defn av
  "Start AV"
  []
  (t/start "resources/shaders/zoomwave.glsl" :width 1600 :height 900 :textures [:overtone-audio :previous-frame]))
