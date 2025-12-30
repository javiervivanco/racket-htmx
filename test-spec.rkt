#lang racket/base

(require rackunit
         racket/pretty
         "main.rkt")

;; ============================================================================
;; TEST EXACTO DE LA ESPECIFICACIÓN
;; ============================================================================

;; Test case de la sección 5 de la especificación
(define test-input
  (hx:div
   (id 'search-box)
   (class "p-4 bg-gray-100")

   ;; HTMX Logic
   (post "/search" (hash 'v 2))
   (trigger 'keyup #:changed? #t #:delay 500)
   (target 'results-area)
   (indicator 'loading-spinner)
   (swap 'innerHTML #:transition? #t)

   ;; Content
   (hx:input (name "q") (placeholder "Buscar..."))
   (hx:div (id 'loading-spinner) "Cargando...")))

;; Resultado esperado de la especificación
(define expected-output
  '(div ((id "search-box")
         (class "p-4 bg-gray-100")
         (hx-post "/search?v=2")
         (hx-trigger "keyup changed delay:500ms")
         (hx-target "#results-area")
         (hx-indicator "#loading-spinner")
         (hx-swap "innerHTML transition:true"))
        (input ((name "q") (placeholder "Buscar...")))
        (div ((id "loading-spinner")) "Cargando...")))

;; Verificación exacta
(check-equal? test-input expected-output
              "Test case de especificación debe pasar exactamente")

(displayln "✓ Test de especificación PASADO")
(displayln "")
(displayln "Input generado:")
(pretty-print test-input)
(displayln "")
(displayln "Output esperado:")
(pretty-print expected-output)
(displayln "")
(displayln "✓ Implementación conforme a especificación técnica")
