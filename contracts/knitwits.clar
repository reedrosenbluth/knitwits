;; knitwits NFT contract

;; (impl-trait 'ST1JSH2FPE8BWNTP228YZ1AZZ0HE0064PS54Q30F0.nft-trait.nft-trait)

;; error codes
(define-constant ERR_NFT_ALREADY_EXISTS      u1)
(define-constant ERR_AMOUNT_NOT_POSITIVE     u2)
(define-constant ERR_SENDER_NOT_CALLER       u3)
(define-constant ERR_NFT_NOT_FOUND           u4)
(define-constant ERR_OWNER_NOT_CALLER        u5)
(define-constant ERR_COULD_NOT_TRANSFER_STX  u6)

;; constants
(define-constant INITIAL_PRICE u200000000)
(define-constant PRICE_FUN_K   u13000000000000)

;; NFT definition
(define-non-fungible-token knitwits uint)

(define-data-var knitwit-id uint u0)
(define-data-var num-minted uint u0)

;; ID to URI map
(define-map metadata { id: uint } { uri: (string-ascii 256) })

;; get most recent token ID
(define-read-only (get-last-token-id)
  (ok (var-get knitwit-id)))

;; get a sweater token's metadata URI
(define-read-only (get-token-uri (id uint))
  (ok (get uri (map-get? metadata { id: id }))))

;; get a sweater token's owner
(define-read-only (get-owner (id uint))
  (ok (nft-get-owner? knitwits id)))

;; mint a new knitwit NFT
(define-public (mint (maybe-uri (optional (string-ascii 256))))
  (let ((id (var-get knitwit-id)))
    (unwrap! (stx-transfer? (price) tx-sender (as-contract tx-sender)) (err ERR_COULD_NOT_TRANSFER_STX))
    ;; TODO: should the recipient be tx-sender or contract-caller?
    (unwrap! (nft-mint? knitwits id contract-caller) (err ERR_NFT_ALREADY_EXISTS))
    (var-set num-minted (+ (var-get num-minted) u1))
    (match maybe-uri
      uri (map-set metadata { id: id } { uri: uri })
      false)
    (ok (var-set knitwit-id (+ id u1)))))

(define-public (burn (id uint))
  (let ((owner (unwrap! (nft-get-owner? knitwits id) (err ERR_NFT_NOT_FOUND))))
    ;; TODO: should this be tx-sender or contract-caller?
    (asserts! (is-eq owner contract-caller) (err ERR_OWNER_NOT_CALLER))
    (nft-burn? knitwits id contract-caller)))

;; transfer a knitwit from one principal to another
(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    ;; TODO: should this be tx-sender or contract-caller?
    (asserts! (is-eq sender contract-caller) (err { kind: "nft-transfer-failed", code: ERR_SENDER_NOT_CALLER}))
    (match (nft-transfer? knitwits id sender recipient)
      success (ok true)
      error (err { kind: "nft-transfer-failed", code: error }))))

;; return the price for the next knitwit
(define-read-only (price)
  (+ INITIAL_PRICE (- (/ PRICE_FUN_K (- u670 (var-get num-minted)))
                      (/ PRICE_FUN_K u670))))