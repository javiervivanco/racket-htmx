#lang racket/base

(require "private/normalize.rkt"
         "private/ajax.rkt"
         "private/parameters.rkt"
         "private/triggers.rkt"
         "private/swapping.rkt"
         "private/indicators.rkt"
         "private/boosting.rkt"
         "private/extensions.rkt"
         "private/attributes.rkt"
         "private/tags.rkt")

;; ============================================================================
;; PUBLIC API - HTMX DSL for Racket
;; ============================================================================

;; Re-export all HTMX functionality
(provide
 ;; AJAX Core
 get post put patch delete req

 ;; Parameters & Values
 vals params

 ;; Triggers & Events
 trigger poll on-load

 ;; Swapping & Targets
 target swap swap-oob

 ;; Indicators & Sync
 indicator sync

 ;; Boosting & History
 boost push-url history confirm preserve

 ;; Extensions
 ws-connect sse-connect sse-swap on ext

 ;; HTML Attributes
 id class name value type placeholder
 href src alt title
 disabled required readonly checked selected hidden
 autocomplete method action enctype html-target rel role
 aria data style

 ;; HTML Tags
 hx:div hx:span hx:p hx:a hx:button
 hx:form hx:input hx:textarea hx:select hx:option
 hx:label hx:fieldset hx:legend
 hx:ul hx:ol hx:li
 hx:table hx:thead hx:tbody hx:tr hx:th hx:td
 hx:h1 hx:h2 hx:h3 hx:h4 hx:h5 hx:h6
 hx:section hx:article hx:header hx:footer hx:nav hx:aside
 hx:main hx:figure hx:figcaption
 hx:img hx:video hx:audio hx:source
 hx:iframe hx:embed hx:object
 hx:script hx:style hx:link hx:meta
 hx:br hx:hr
 hx:code hx:pre hx:blockquote
 hx:em hx:strong hx:small hx:mark
 hx:del hx:ins hx:sub hx:sup
 hx:time hx:progress hx:meter
 hx:details hx:summary hx:dialog
 hx:canvas hx:svg)

;; ============================================================================
;; HTML TAGS IMPLEMENTATION
;; ============================================================================

;; Common block elements
(define hx:div (make-tag 'div))
(define hx:span (make-tag 'span))
(define hx:p (make-tag 'p))
(define hx:a (make-tag 'a))
(define hx:button (make-tag 'button))

;; Form elements
(define hx:form (make-tag 'form))
(define hx:input (make-tag 'input))
(define hx:textarea (make-tag 'textarea))
(define hx:select (make-tag 'select))
(define hx:option (make-tag 'option))
(define hx:label (make-tag 'label))
(define hx:fieldset (make-tag 'fieldset))
(define hx:legend (make-tag 'legend))

;; Lists
(define hx:ul (make-tag 'ul))
(define hx:ol (make-tag 'ol))
(define hx:li (make-tag 'li))

;; Tables
(define hx:table (make-tag 'table))
(define hx:thead (make-tag 'thead))
(define hx:tbody (make-tag 'tbody))
(define hx:tr (make-tag 'tr))
(define hx:th (make-tag 'th))
(define hx:td (make-tag 'td))

;; Headings
(define hx:h1 (make-tag 'h1))
(define hx:h2 (make-tag 'h2))
(define hx:h3 (make-tag 'h3))
(define hx:h4 (make-tag 'h4))
(define hx:h5 (make-tag 'h5))
(define hx:h6 (make-tag 'h6))

;; Semantic HTML5
(define hx:section (make-tag 'section))
(define hx:article (make-tag 'article))
(define hx:header (make-tag 'header))
(define hx:footer (make-tag 'footer))
(define hx:nav (make-tag 'nav))
(define hx:aside (make-tag 'aside))
(define hx:main (make-tag 'main))
(define hx:figure (make-tag 'figure))
(define hx:figcaption (make-tag 'figcaption))

;; Media
(define hx:img (make-tag 'img))
(define hx:video (make-tag 'video))
(define hx:audio (make-tag 'audio))
(define hx:source (make-tag 'source))
(define hx:iframe (make-tag 'iframe))
(define hx:embed (make-tag 'embed))
(define hx:object (make-tag 'object))

;; Document metadata
(define hx:script (make-tag 'script))
(define hx:style (make-tag 'style))
(define hx:link (make-tag 'link))
(define hx:meta (make-tag 'meta))

;; Line breaks and separators
(define hx:br (make-tag 'br))
(define hx:hr (make-tag 'hr))

;; Text formatting
(define hx:code (make-tag 'code))
(define hx:pre (make-tag 'pre))
(define hx:blockquote (make-tag 'blockquote))
(define hx:em (make-tag 'em))
(define hx:strong (make-tag 'strong))
(define hx:small (make-tag 'small))
(define hx:mark (make-tag 'mark))
(define hx:del (make-tag 'del))
(define hx:ins (make-tag 'ins))
(define hx:sub (make-tag 'sub))
(define hx:sup (make-tag 'sup))

;; Interactive elements
(define hx:time (make-tag 'time))
(define hx:progress (make-tag 'progress))
(define hx:meter (make-tag 'meter))
(define hx:details (make-tag 'details))
(define hx:summary (make-tag 'summary))
(define hx:dialog (make-tag 'dialog))

;; Graphics
(define hx:canvas (make-tag 'canvas))
(define hx:svg (make-tag 'svg))

;; ============================================================================
;; TESTS
;; ============================================================================

(module+ test
  (require rackunit)

  ;; Test normalización básica
  (check-equal? (normalize-selector 'mi-id) "#mi-id")
  (check-equal? (normalize-selector ".clase") ".clase")
  (check-equal? (normalize-time 500) "500ms")
  (check-equal? (normalize-time "2s") "2s")

  ;; Test AJAX Core
  (check-equal? (get "/api/data") '(hx-get "/api/data"))
  (check-equal? (post "/api/submit" (hash 'q "test"))
                '(hx-post "/api/submit?q=test"))

  ;; Test triggers simples
  (check-equal? (trigger 'click) '(hx-trigger "click"))
  (check-equal? (trigger 'keyup #:changed? #t #:delay 500)
                '(hx-trigger "keyup changed delay:500ms"))

  ;; Test swap
  (check-equal? (swap 'innerHTML) '(hx-swap "innerHTML"))
  (check-equal? (swap 'innerHTML #:transition? #t)
                '(hx-swap "innerHTML transition:true"))

  ;; Test target
  (check-equal? (target 'results) '(hx-target "#results"))

  ;; Test indicator
  (check-equal? (indicator 'spinner) '(hx-indicator "#spinner"))

  ;; Test vals
  (check-equal? (vals (hash 'a 1)) '(hx-vals "{\"a\":1}"))

  ;; Test params
  (check-equal? (params '(a b)) '(hx-params "a, b"))

  ;; Test boost
  (check-equal? (boost) '(hx-boost "true"))
  (check-equal? (boost #f) '(hx-boost "false"))

  ;; Test HTML attributes
  (check-equal? (id 'test) '(id "test"))
  (check-equal? (class "a" "b") '(class "a b"))
  (check-equal? (name 'username) '(name "username"))

  ;; Test tag construction básico
  (check-equal? (hx:div) '(div))
  (check-equal? (hx:div "texto") '(div "texto"))
  (check-equal? (hx:div (id 'test) "texto")
                '(div ((id "test")) "texto"))

  ;; Test case completo de la especificación
  (check-equal?
   (hx:div
    (id 'search-box)
    (class "p-4" "bg-gray-100")
    (post "/search" (hash 'v 2))
    (trigger 'keyup #:changed? #t #:delay 500)
    (target 'results-area)
    (indicator 'loading-spinner)
    (swap 'innerHTML #:transition? #t)
    (hx:input (name "q") (placeholder "Buscar..."))
    (hx:div (id 'loading-spinner) "Cargando..."))
   '(div ((id "search-box")
          (class "p-4 bg-gray-100")
          (hx-post "/search?v=2")
          (hx-trigger "keyup changed delay:500ms")
          (hx-target "#results-area")
          (hx-indicator "#loading-spinner")
          (hx-swap "innerHTML transition:true"))
         (input ((name "q") (placeholder "Buscar...")))
         (div ((id "loading-spinner")) "Cargando..."))))
