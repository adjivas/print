#!/usr/bin/env bb

(require '[babashka.process :refer [shell]])
(require '[babashka.fs :as fs])

(def project-dir (-> *file* fs/absolutize fs/normalize fs/parent))
(def project-name (-> project-dir fs/file-name str str/lower-case))

(defn vox [author] (if (re-find #"adjivas" author)
  "\\newcommand{\\adjivasvox}[2]{#1}"
  "\\newcommand{\\adjivasvox}[2]{#2}"))

(defn run-hevea [hevea author dir filename]
  (let [temp (fs/create-temp-file)]
    (fs/write-bytes temp (.getBytes (vox author)))
    (shell {:dir project-dir}
         hevea
         (str "core" ".hva")
         temp
         (str "-o")
         (str dir "/" filename ".html")
         (str filename ".tex"))))

(defn run-latex [compiler_method author dir filename]
  (shell {:dir project-dir}
         compiler_method
         "--shell-escape"
         (str "-jobname=" author)
         (str "-output-directory=" dir)
         (str filename ".tex"))
  (fs/delete (str dir "/" author ".aux"))
  (fs/delete (str dir "/" author ".log"))
  (fs/move (str dir "/" author ".pdf")
           (str dir "/" filename ".pdf")
           {:replace-existing true}))


(defn copy-dir-files! [src dst]
  (let [src (fs/real-path src)]
    (doseq [path (file-seq (.toFile src))]
      (when (.isFile path)
        (let [path-str (str path)
              rel (fs/relativize src path)
              target (fs/path dst rel)]
          (fs/create-dirs (fs/parent target))
          (fs/copy path target {:replace-existing true}))))))

(let [name project-name
      dest "public"
      languages ["fr" "lb"]
      authors ["navi" "adjivas"]
      compiler_method "lualatex"
      hevea "hevea"]

  (doseq [author authors]
    (let [dir (str (fs/path (fs/cwd) dest author))]
      (copy-dir-files! (fs/path project-dir "ressources")
         (fs/path dir "ressources"))))
  (doseq [author authors
          language languages]
    (let [dir (str (fs/path (fs/cwd) dest author))
          filename (str name "." language)]
      (fs/create-dirs dir)
      (run-latex compiler_method author dir filename)
      (run-hevea hevea author dir filename))))
