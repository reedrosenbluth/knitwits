;; knitwits NFT contract

;; (impl-trait 'ST1JSH2FPE8BWNTP228YZ1AZZ0HE0064PS54Q30F0.nft-trait.nft-trait)

;; NFT definition
(define-non-fungible-token knitwits uint)

;; data-var to keep track of IDs
(define-data-var knitwit-id uint u0)

;; ID to URI map
(define-map metadata { id: uint } { uri: (string-ascii 256) })

;; get most recent token ID
(define-read-only (get-last-token-id)
  (ok (var-get knitwit-id)))

;; get a sweater token's metadata URI
(define-read-only (get-token-uri (id uint))
  (ok (map-get? metadata { id: id })))

;; get a sweater token's owner
(define-read-only (get-owner (id uint))
  (ok (nft-get-owner? knitwits id)))

(define-public (mint)
  (begin
    (unwrap! (nft-mint? knitwits (var-get knitwit-id) contract-caller) (err u1))
    (ok (var-set knitwit-id (+ (var-get knitwit-id) u1)))))

;; (define-public (transfer (id uint) (sender principal) (recipient principal))
;;   (begin
;;     (unwrap! (nft-transfer? sweater id sender recipient) (err { kind: (), code: }))))

;; (define-private (price (id uint))
;;   (+ u200 (pow (var-get knitwit-id) u3)))