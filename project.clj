(defproject av-clj "0.1.0-SNAPSHOT"
  :description "Audio Visual stuff with Shadertone / GLSL"
  :url "http://github.com/markus-wa/av-clj"
  :license
  {:name "MIT"
   :url  "https://opensource.org/licenses/MIT"}
  :dependencies [[org.clojure/clojure "1.10.0"]
                 [overtone "e925f06d25786ad9b3b9fddcd87eb2a11f359762" :exclusions [[clj-native]]]
                 [shadertone "89d3a647d18e95fce4f90fff3feb5d8af2522575"]
                 [clj-native "6b75d4a59cf85779c3935ff55330bed68da92124"]]
  :plugins [[reifyhealth/lein-git-down "0.4.0"]]
  :middleware [lein-git-down.plugin/inject-properties]
  :repositories [["public-github" {:url "git://github.com"}]]
  :git-down {overtone {:coordinates markus-wa/overtone}
             clj-native {:coordinates markus-wa/clj-native}
             shadertone {:coordinates markus-wa/shadertone}}
  :main ^:skip-aot av-clj.core
  :repl-options {:init-ns av-clj.core}
  :jvm-opts ^replace [])
