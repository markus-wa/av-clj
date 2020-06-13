(ns av-clj.core
  (:use [av-clj.loader]
        [overtone.core])
  (:require [shadertone.tone :as t]))

(defn disconnect
  "Disconnect from SuperCollider"
  []
  (kill-server))

(defn wave
  "Start Zoomwave"
  []
  (t/start "resources/shaders/zoomwave.glsl" :width 1600 :height 900 :textures [:overtone-audio :previous-frame]))

(defn cubes
  "Start Cubeworld"
  []
  (t/start "resources/shaders/cubes.glsl" :width 1600 :height 900 :textures [:overtone-audio "resources/textures/matrix.png"]))

(defn vis
  "Start FFT and wave visualisation"
  []
  (t/start "resources/shaders/sound.glsl" :width 420 :height 236 :textures [:overtone-audio]))

(defn spec
  "Start FFT/Spectrum vis"
  []
  (t/start "resources/shaders/spectrum.glsl" :width 420 :height 236 :textures [:overtone-audio]))

(defn voronoi
  "Start Voronoi"
  []
  (t/start "resources/shaders/voronoi.glsl" :width 1600 :height 900 :textures [:overtone-audio]))

(defn -main
  [& args]
  (voronoi))
