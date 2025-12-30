#lang racket/base

(require "../main.rkt")

;; ============================================================================
;; EJEMPLO COMPLETO: Search Component con HTMX
;; ============================================================================

;; Componente de búsqueda interactivo con todos los features HTMX
(define search-component
  (hx:div
   (id 'search-container)
   (class "max-w-4xl" "mx-auto" "p-6")

   ;; Header
   (hx:h1 (class "text-3xl" "font-bold" "mb-4") "Búsqueda Dinámica")

   ;; Search Form
   (hx:form
    (id 'search-form)
    (class "mb-6")

    ;; Input con HTMX triggers
    (hx:input
     (type 'search)
     (name "q")
     (id 'search-input)
     (class "w-full" "px-4" "py-2" "border" "rounded")
     (placeholder "Escribe para buscar...")

     ;; HTMX: POST on keyup con debounce
     (post "/api/search" (hash 'version 2))
     (trigger 'keyup #:changed? #t #:delay 500)
     (target 'results-area)
     (indicator 'loading-spinner)
     (swap 'innerHTML #:transition? #t #:swap-delay 200))

    ;; Loading indicator
    (hx:div
     (id 'loading-spinner)
     (class "htmx-indicator" "text-gray-500" "mt-2")
     "Buscando..."))

   ;; Results area
   (hx:div
    (id 'results-area)
    (class "space-y-4")

    ;; Initial state
    (hx:p (class "text-gray-400" "text-center") "Sin resultados aún"))))

;; ============================================================================
;; EJEMPLO 2: Infinite Scroll
;; ============================================================================

(define infinite-scroll
  (hx:div
   (id 'posts-container)
   (class "space-y-4")

   ;; Existing posts
   (hx:article
    (class "post" "p-4" "border" "rounded")
    (hx:h2 (class "font-bold") "Post 1")
    (hx:p "Contenido del primer post..."))

   ;; Load more trigger
   (hx:div
    (id 'load-more-trigger)

    ;; HTMX: Load more on scroll into view
    (get "/api/posts" (hash 'offset 10))
    (trigger 'revealed)
    (swap 'afterend)
    (indicator 'load-spinner)

    (hx:div
     (id 'load-spinner)
     (class "htmx-indicator" "text-center" "py-4")
     "Cargando más posts...")

    (hx:div
     (class "text-center" "py-4")
     "Scroll para cargar más"))))

;; ============================================================================
;; EJEMPLO 3: Form Submit con Confirmación
;; ============================================================================

(define delete-form
  (hx:form
   (id 'delete-form)
   (class "p-4" "border" "border-red-500" "rounded")

   (hx:h3 (class "text-red-600" "font-bold" "mb-2") "Zona Peligrosa")

   (hx:button
    (type 'button)
    (class "bg-red-600" "text-white" "px-4" "py-2" "rounded")

    ;; HTMX: DELETE con confirmación
    (delete "/api/user/123")
    (confirm "¿Estás seguro de eliminar este usuario?")
    (target 'result-message)
    (swap 'innerHTML)

    "Eliminar Usuario")

   (hx:div
    (id 'result-message)
    (class "mt-4"))))

;; ============================================================================
;; EJEMPLO 4: Polling (Server Updates)
;; ============================================================================

(define status-monitor
  (hx:div
   (id 'status-board)
   (class "p-6" "border" "rounded")

   ;; HTMX: Poll every 5 seconds
   (get "/api/status")
   (poll 5000)
   (swap 'innerHTML)

   (hx:h3 (class "font-bold" "mb-2") "Estado del Sistema")
   (hx:p (id 'status-text) "Cargando...")))

;; ============================================================================
;; EJEMPLO 5: Multiple Triggers y Queue Strategy
;; ============================================================================

(define advanced-input
  (hx:input
   (type 'text)
   (name "data")
   (class "w-full" "px-4" "py-2" "border" "rounded")

   ;; HTMX: Multiple conditions con queue
   (post "/api/validate")
   (trigger 'keyup
            #:changed? #t
            #:delay 300
            #:filter "this.value.length > 3"
            #:queue 'last)
   (target 'validation-result)
   (sync 'validation-result 'abort)
   (swap 'innerHTML)))

;; ============================================================================
;; EJEMPLO 6: WebSocket Connection
;; ============================================================================

(define chat-component
  (hx:div
   (id 'chat-container)
   (class "border" "rounded" "p-4")

   ;; Enable WebSocket extension
   (ext 'ws)

   ;; Connect to WebSocket
   (ws-connect "ws://localhost:8080/chat")

   (hx:div
    (id 'messages)
    (class "space-y-2" "mb-4" "h-64" "overflow-y-auto"))

   (hx:form
    (id 'chat-form)
    (class "flex" "gap-2")

    (hx:input
     (type 'text)
     (name "message")
     (class "flex-1" "px-4" "py-2" "border" "rounded")
     (placeholder "Escribe un mensaje..."))

    (hx:button
     (type 'submit)
     (class "bg-blue-600" "text-white" "px-4" "py-2" "rounded")

     ;; HTMX: Send via WebSocket
     (post "/api/chat/send")
     (vals (hash 'room "general"))
     (target 'messages)
     (swap 'beforeend)

     "Enviar"))))

;; ============================================================================
;; EJEMPLO 7: Out of Band Swaps
;; ============================================================================

(define dashboard-update
  (hx:div
   (id 'dashboard)
   (class "grid" "grid-cols-2" "gap-4")

   (hx:button
    (class "bg-blue-600" "text-white" "px-4" "py-2" "rounded")

    ;; HTMX: Update múltiples secciones
    (get "/api/dashboard/refresh")
    (target 'main-content)
    (swap 'innerHTML)

    ;; El servidor enviará OOB swaps para otros elementos
    "Actualizar Dashboard")

   (hx:div (id 'main-content) (class "col-span-2") "Contenido principal")
   (hx:div (id 'sidebar-stats) "Stats")
   (hx:div (id 'notifications) "Notificaciones")))

;; ============================================================================
;; EJEMPLO 8: Custom Events (hx-on)
;; ============================================================================

(define custom-events
  (hx:div
   (id 'event-demo)
   (class "p-4" "border" "rounded")

   (hx:button
    (class "bg-green-600" "text-white" "px-4" "py-2" "rounded")

    (get "/api/data")
    (target 'result)
    (swap 'innerHTML)

    ;; Custom event handlers
    (on 'htmx:beforeRequest "console.log('Starting request...')")
    (on 'htmx:afterSwap "alert('Data loaded!')")

    "Load Data")

   (hx:div (id 'result) (class "mt-4"))))

;; ============================================================================
;; EJEMPLO 9: Composición y Reutilización
;; ============================================================================

;; Helper function: crear un card con HTMX
(define (make-card title url target-id)
  (hx:div
   (class "bg-white" "border" "rounded" "p-4" "shadow")

   (hx:h3 (class "font-bold" "mb-2") title)

   (hx:button
    (class "bg-blue-500" "text-white" "px-3" "py-1" "rounded" "text-sm")

    (get url)
    (target target-id)
    (indicator (string->symbol (string-append (symbol->string target-id) "-spinner")))
    (swap 'innerHTML #:transition? #t)

    "Cargar")))

;; Usar el helper
(define cards-grid
  (hx:div
   (class "grid" "grid-cols-3" "gap-4")

   (make-card "Usuarios" "/api/users" 'users-list)
   (make-card "Productos" "/api/products" 'products-list)
   (make-card "Órdenes" "/api/orders" 'orders-list)

   (hx:div (id 'users-list) (class "col-span-3"))
   (hx:div (id 'products-list) (class "col-span-3"))
   (hx:div (id 'orders-list) (class "col-span-3"))))

;; ============================================================================
;; EJEMPLO 10: All Attributes
;; ============================================================================

(define kitchen-sink
  (hx:div
   (id 'kitchen-sink)
   (class "container")
   (data 'test-id "123")
   (aria 'label "Complete example")

   (hx:form
    (method 'post)
    (action "/submit")

    (hx:fieldset
     (hx:legend "Formulario Completo")

     (hx:label (name "email-label") "Email:")
     (hx:input
      (type 'email)
      (name "email")
      (required)
      (autocomplete 'email)
      (placeholder "tu@email.com"))

     (hx:label (name "password-label") "Password:")
     (hx:input
      (type 'password)
      (name "password")
      (required)
      (autocomplete 'current-password))

     (hx:label (name "remember-label") "Recordar:")
     (hx:input
      (type 'checkbox)
      (name "remember")
      (value "1"))

     (hx:button
      (type 'submit)
      (disabled #f)

      ;; HTMX comprehensive
      (post "/api/login")
      (vals (hash 'source "web"))
      (params '(email password remember))
      (trigger 'submit)
      (target 'login-result)
      (indicator 'login-spinner)
      (swap 'innerHTML #:transition? #t #:swap-delay 200)
      (boost)
      (push-url "/dashboard")
      (confirm "¿Iniciar sesión?")

      "Ingresar"))

    (hx:div (id 'login-spinner) (class "htmx-indicator") "Procesando...")
    (hx:div (id 'login-result) (class "mt-4")))))

;; ============================================================================
;; EXPORTS para testing
;; ============================================================================

(provide search-component
         infinite-scroll
         delete-form
         status-monitor
         advanced-input
         chat-component
         dashboard-update
         custom-events
         cards-grid
         kitchen-sink)
