(defproject av-clj "0.1.0-SNAPSHOT"
  :description "Audio Visual stuff with Shadertone / GLSL"
  :url "http://github.com/markus-wa/av-clj"
  :license
  {:name "MIT"
   :url  "https://opensource.org/licenses/MIT"}
  :dependencies [[org.clojure/clojure "1.10.0"]
                 [overtone "0.10.6" :exclusions [[clj-native]]]
                 [shadertone "0.2.6-SNAPSHOT"]
                 [clj-native "0.9.5"]]
  :main ^:skip-aot av-clj.core
  :repl-options {:init-ns av-clj.core}
  :jvm-opts ^replace [])
