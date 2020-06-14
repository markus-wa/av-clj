(ns av-clj.core
  (:use [av-clj.loader]
        [overtone.core])
  (:require [shadertone.tone :as t]))

(defn disconnect
  "Disconnect from SuperCollider"
  []
  (kill-server))

(def title "av-clj-output")

(defn wave
  "Start Zoomwave"
  []
  (t/start "resources/shaders/zoomwave.glsl"
           :title title
           :width 1600 :height 900
           :textures [:overtone-audio :previous-frame]))

(defn cubes
  "Start Cubeworld"
  []
  (t/start "resources/shaders/cubes.glsl"
           :title title
           :width 1600 :height 900
           :textures [:overtone-audio "resources/textures/matrix.png"]))

(defn vis
  "Start FFT and wave visualisation"
  []
  (t/start "resources/shaders/sound.glsl"
           :title title
           :width 420 :height 236
           :textures [:overtone-audio]))

(defn spec
  "Start FFT/Spectrum vis"
  []
  (t/start "resources/shaders/spectrum.glsl"
           :title title
           :width 420 :height 236
           :textures [:overtone-audio]))

(defn voronoi
  "Start Voronoi"
  []
  (t/start "resources/shaders/voronoi.glsl"
           :title title
           :width 1600 :height 900
           :textures [:overtone-audio]))

(defn flower
  "Start Soundflower"
  []
  (t/start "resources/shaders/soundflower.glsl"
           :title title
           :width 1600 :height 900
           :textures [:overtone-audio]))

(defn -main
  [& args]
  (voronoi))
