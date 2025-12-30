# racket-htmx

Un DSL funcional en Racket para generar atributos HTMX y X-expressions mediante composición pura.

## Instalación

Desde el directorio del paquete:

```bash
raco pkg install
```

## Filosofía de Diseño

### 1. Todo es una Expresión (Function-Driven)

El DSL no utiliza macros complejas. Cada función HTMX retorna un par atributo `'(hx-atributo "valor")` que se compone naturalmente con las funciones de tags HTML.

### 2. Heurística "Symbol-First"

Normalización automática de tipos para ergonomía máxima:

- **Selectores:** `'mi-id` → `"#mi-id"`, strings intactos
- **Tiempos:** `500` → `"500ms"`, strings intactos  
- **URLs:** Soporte de query params con `hash` o `alist`

### 3. Composición Natural

```racket
(hx:div
  (id 'container)
  (get "/api/data")
  (trigger 'click)
  "Contenido")
```

Produce:

```racket
'(div ((id "container") (hx-get "/api/data") (hx-trigger "click")) "Contenido")
```

## API Rápida

### AJAX Core

```racket
(get url [params])           ; hx-get
(post url [params])          ; hx-post
(put url [params])           ; hx-put
(patch url [params])         ; hx-patch
(delete url [params])        ; hx-delete

;; Helper para URLs complejas
(req path #:params (hash 'q "test") #:encode? #t)
```

### Triggers & Modifiers

```racket
(trigger event-name
  #:changed? [bool]
  #:once? [bool]
  #:delay [ms-or-string]
  #:throttle [ms-or-string]
  #:from [selector]
  #:target [selector]
  #:consume? [bool]
  #:queue ['first 'last 'all 'none]
  #:filter [js-condition])

;; Aliases
(poll interval #:filter [js-cond])
(on-load #:delay [ms] #:throttle [ms] #:filter [js-cond])
```

**Ejemplo:**

```racket
(trigger 'keyup 
  #:changed? #t 
  #:delay 500 
  #:filter "this.value.length > 3")
;; → '(hx-trigger "keyup[this.value.length > 3] changed delay:500ms")
```

### Swapping & Targets

```racket
(target selector)            ; hx-target

(swap style                  ; hx-swap
  #:transition? [bool]
  #:swap-delay [ms]
  #:settle-delay [ms]
  #:scroll [selector-or-'top/'bottom]
  #:scroll-focus? [bool]
  #:show [selector-or-'top/'bottom]
  #:show-focus? [bool])

(swap-oob style [selector])  ; hx-swap-oob
```

### Parameters & Values

```racket
(vals data)                  ; hx-vals (serializa hash/alist a JSON)
(params allow #:mode [mode]) ; hx-params (filtra parámetros)
```

### Indicators & Sync

```racket
(indicator selector)         ; hx-indicator
(sync selector [strategy])   ; hx-sync ('drop 'abort 'replace, etc.)
```

### Boosting & History

```racket
(boost [active?])            ; hx-boost
(push-url [url-or-bool])     ; hx-push-url
(history [enabled?])         ; hx-history
(confirm text)               ; hx-confirm
(preserve [enabled?])        ; hx-preserve
```

### Extensions

```racket
(ext . names)                ; hx-ext
(ws-connect url)             ; WebSocket (requiere ext 'ws)
(sse-connect url)            ; Server-Sent Events
(sse-swap message-name)
(on event-name js-code)      ; hx-on:eventname
```

### HTML Attributes

```racket
(id val)
(class . classes)            ; Múltiples clases
(name val)
(value val)
(type val)
(placeholder text)
(href url)
(src url)
(alt text)
(title text)

;; Booleanos
(disabled [active?])
(required [active?])
(readonly [active?])
(checked [active?])
(selected [active?])
(hidden [active?])

;; Otros
(autocomplete val)
(method val)
(action url)
(html-target val)            ; <a target="_blank">
(rel val)
(role val)
(style css)

;; Dinámicos
(data attr-name val)         ; data-*
(aria attr-name val)         ; aria-*
```

### HTML Tags

Todos los tags siguen el patrón `hx:tagname`:

```racket
;; Block
hx:div hx:span hx:p hx:a hx:button

;; Forms
hx:form hx:input hx:textarea hx:select hx:option
hx:label hx:fieldset hx:legend

;; Lists
hx:ul hx:ol hx:li

;; Tables
hx:table hx:thead hx:tbody hx:tr hx:th hx:td

;; Headings
hx:h1 hx:h2 hx:h3 hx:h4 hx:h5 hx:h6

;; Semantic
hx:section hx:article hx:header hx:footer hx:nav
hx:aside hx:main hx:figure hx:figcaption

;; Media
hx:img hx:video hx:audio hx:source
hx:iframe hx:embed hx:object

;; Text formatting
hx:code hx:pre hx:blockquote hx:em hx:strong
hx:small hx:mark hx:del hx:ins hx:sub hx:sup

;; Interactive
hx:time hx:progress hx:meter
hx:details hx:summary hx:dialog

;; Graphics
hx:canvas hx:svg

;; Meta/Scripts
hx:script hx:style hx:link hx:meta
hx:br hx:hr
```

## Ejemplos

### Search con Debounce

```racket
(hx:div
  (id 'search-box)
  (class "p-4" "bg-gray-100")
  
  (hx:input
    (name "q")
    (placeholder "Buscar...")
    
    ;; HTMX Logic
    (post "/search" (hash 'v 2))
    (trigger 'keyup #:changed? #t #:delay 500)
    (target 'results-area)
    (indicator 'loading-spinner)
    (swap 'innerHTML #:transition? #t))
  
  (hx:div (id 'loading-spinner) "Cargando...")
  (hx:div (id 'results-area)))
```

**Resultado X-expr:**

```racket
'(div ((id "search-box") (class "p-4 bg-gray-100"))
  (input ((name "q")
          (placeholder "Buscar...")
          (hx-post "/search?v=2")
          (hx-trigger "keyup changed delay:500ms")
          (hx-target "#results-area")
          (hx-indicator "#loading-spinner")
          (hx-swap "innerHTML transition:true")))
  (div ((id "loading-spinner")) "Cargando...")
  (div ((id "results-area"))))
```

### Infinite Scroll

```racket
(hx:div
  (id 'posts)
  
  ;; Contenido existente
  (hx:article "Post 1")
  (hx:article "Post 2")
  
  ;; Trigger de carga
  (hx:div
    (get "/api/posts" (hash 'offset 10))
    (trigger 'revealed)
    (swap 'afterend)
    "Scroll para más..."))
```

### Polling (Updates Automáticos)

```racket
(hx:div
  (id 'status)
  
  (get "/api/status")
  (poll 5000)  ; Cada 5 segundos
  (swap 'innerHTML)
  
  "Estado: Cargando...")
```

### Form con Confirmación

```racket
(hx:form
  (hx:button
    (delete "/api/user/123")
    (confirm "¿Eliminar usuario?")
    (target 'result)
    (swap 'innerHTML)
    "Eliminar"))
```

### Triggers Complejos

```racket
(hx:input
  (type 'text)
  (name "data")
  
  (post "/validate")
  (trigger 'keyup 
    #:changed? #t
    #:delay 300
    #:filter "this.value.length > 3"
    #:queue 'last)
  (sync 'result 'abort)
  (target 'result))
```

### WebSocket Chat

```racket
(hx:div
  (ext 'ws)
  (ws-connect "ws://localhost:8080/chat")
  
  (hx:div (id 'messages))
  
  (hx:form
    (hx:input (name "message"))
    (hx:button
      (post "/chat/send")
      (vals (hash 'room "general"))
      (target 'messages)
      (swap 'beforeend)
      "Enviar")))
```

### Composición y Reutilización

```racket
;; Helper function
(define (make-card title url target-id)
  (hx:div
    (class "card")
    (hx:h3 title)
    (hx:button
      (get url)
      (target target-id)
      (swap 'innerHTML #:transition? #t)
      "Cargar")))

;; Usar
(hx:div
  (class "grid")
  (make-card "Usuarios" "/api/users" 'users-list)
  (make-card "Productos" "/api/products" 'products-list)
  
  (hx:div (id 'users-list))
  (hx:div (id 'products-list)))
```

## Arquitectura Interna

### Normalización de Tipos

```racket
;; private/normalize.rkt
(normalize-selector 'mi-id)        ; → "#mi-id"
(normalize-time 500)               ; → "500ms"
(normalize-json (hash 'a 1))       ; → "{\"a\":1}"
(normalize-url "/api" (hash 'q 1)) ; → "/api?q=1"
```

### Fusión de Atributos

El módulo `private/tags.rkt` implementa la lógica de separación:

1. Identifica pares `'(key val)` como atributos
2. Aplana listas anidadas (splice)
3. Separa contenido (body)
4. Construye X-expr final

```racket
(hx:div
  (id 'test)           ; → atributo
  '((class "a"))       ; → aplanar a atributo
  "contenido")         ; → body

;; Resultado: '(div ((id "test") (class "a")) "contenido")
```

## Testing

Ejecutar tests:

```bash
raco test main.rkt
```

Ver ejemplos completos:

```racket
(require htmx/examples/complete-example)
```

## Contribuir

1. Fork del repositorio
2. Crear branch: `git checkout -b feature/nueva-funcionalidad`
3. Commit: `git commit -am 'Agregar nueva funcionalidad'`
4. Push: `git push origin feature/nueva-funcionalidad`
5. Pull Request

## Licencia

Dual licensed bajo Apache-2.0 o MIT.

## Recursos

- [HTMX Documentation](https://htmx.org/docs/)
- [Racket X-expressions](https://docs.racket-lang.org/xml/index.html)
- [Ejemplos en htmx/examples/](examples/)

---

**Nota:** Este DSL genera X-expressions válidas. Para renderizar HTML, usar librerías como `html-writing` o `web-server/templates`.