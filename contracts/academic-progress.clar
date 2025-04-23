;; Academic Progress Contract
;; Tracks performance of scholarship recipients

;; Define data structures
(define-map academic-records principal
  {
    current-gpa: uint,
    credits-completed: uint,
    last-updated: uint,
    academic-standing: (string-ascii 32)
  }
)

(define-map progress-reporters principal bool)
(define-data-var contract-owner principal tx-sender)

;; Add a progress reporter (academic institution representative)
(define-public (add-progress-reporter (reporter principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u100))
    (map-set progress-reporters reporter true)
    (ok true)
  )
)

;; Remove a progress reporter
(define-public (remove-progress-reporter (reporter principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u100))
    (map-set progress-reporters reporter false)
    (ok true)
  )
)

;; Update student academic progress
(define-public (update-academic-progress
    (student principal)
    (current-gpa uint)
    (credits-completed uint)
    (academic-standing (string-ascii 32))
  )
  (begin
    (asserts! (default-to false (map-get? progress-reporters tx-sender)) (err u101))

    (map-set academic-records student {
      current-gpa: current-gpa,
      credits-completed: credits-completed,
      last-updated: block-height,
      academic-standing: academic-standing
    })

    (ok true)
  )
)

;; Get student academic record
(define-read-only (get-academic-record (student principal))
  (map-get? academic-records student)
)

;; Check if student is in good standing
(define-read-only (is-in-good-standing (student principal))
  (match (map-get? academic-records student)
    record (is-eq (get academic-standing record) "GOOD")
    false
  )
)

;; Get student GPA
(define-read-only (get-student-gpa (student principal))
  (match (map-get? academic-records student)
    record (get current-gpa record)
    u0
  )
)
