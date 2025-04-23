;; Donor Management Contract
;; Records contributions to scholarship funds

;; Define data variables
(define-data-var total-donations uint u0)
(define-map donors principal uint)
(define-map scholarship-funds (string-ascii 64) uint)

;; Public function to donate to the general fund
(define-public (donate (amount uint))
  (let
    (
      (sender tx-sender)
      (current-donation (default-to u0 (map-get? donors sender)))
    )
    (try! (stx-transfer? amount sender (as-contract tx-sender)))
    (map-set donors sender (+ current-donation amount))
    (var-set total-donations (+ (var-get total-donations) amount))
    (ok amount)
  )
)

;; Public function to donate to a specific scholarship fund
(define-public (donate-to-fund (fund-name (string-ascii 64)) (amount uint))
  (let
    (
      (sender tx-sender)
      (current-donation (default-to u0 (map-get? donors sender)))
      (current-fund-amount (default-to u0 (map-get? scholarship-funds fund-name)))
    )
    (try! (stx-transfer? amount sender (as-contract tx-sender)))
    (map-set donors sender (+ current-donation amount))
    (map-set scholarship-funds fund-name (+ current-fund-amount amount))
    (var-set total-donations (+ (var-get total-donations) amount))
    (ok amount)
  )
)

;; Read-only function to get total donations
(define-read-only (get-total-donations)
  (var-get total-donations)
)

;; Read-only function to get donor's total contribution
(define-read-only (get-donor-contribution (donor principal))
  (default-to u0 (map-get? donors donor))
)

;; Read-only function to get fund amount
(define-read-only (get-fund-amount (fund-name (string-ascii 64)))
  (default-to u0 (map-get? scholarship-funds fund-name))
)
