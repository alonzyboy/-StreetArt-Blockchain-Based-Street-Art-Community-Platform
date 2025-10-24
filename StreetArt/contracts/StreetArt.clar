;; StreetArt - Digital Street Art Community Platform
;; A blockchain-based platform for murals, art pieces, 
;; and street artist community rewards

;; Contract constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-exists (err u102))
(define-constant err-unauthorized (err u103))
(define-constant err-invalid-input (err u104))

;; Token constants
(define-constant token-name "StreetArt Culture Token")
(define-constant token-symbol "SCT")
(define-constant token-decimals u6)
(define-constant token-max-supply u52000000000) ;; 52k tokens with 6 decimals

;; Reward amounts (in micro-tokens)
(define-constant reward-creation u2500000) ;; 2.5 SCT
(define-constant reward-spot u3300000) ;; 3.3 SCT
(define-constant reward-milestone u9500000) ;; 9.5 SCT

;; Data variables
(define-data-var total-supply uint u0)
(define-data-var next-spot-id uint u1)
(define-data-var next-piece-id uint u1)

;; Token balances
(define-map token-balances principal uint)

;; Artist profiles
(define-map artist-profiles
  principal
  {
    username: (string-ascii 24),
    art-style: (string-ascii 12), ;; "graffiti", "stencil", "mural", "poster", "mixed"
    pieces-created: uint,
    spots-documented: uint,
    total-size: uint, ;; square meters
    artist-level: uint, ;; 1-5
    join-date: uint
  }
)

;; Art spots
(define-map art-spots
  uint
  {
    spot-name: (string-ascii 20),
    neighborhood: (string-ascii 18),
    surface-type: (string-ascii 12), ;; "wall", "bridge", "tunnel", "building", "fence"
    visibility: (string-ascii 8), ;; "high", "medium", "low", "hidden"
    legal-status: (string-ascii 8), ;; "legal", "tolerated", "illegal"
    access-level: (string-ascii 8), ;; "public", "private", "restricted"
    finder: principal,
    piece-count: uint,
    average-rating: uint
  }
)

;; Art pieces
(define-map art-pieces
  uint
  {
    spot-id: uint,
    artist: principal,
    piece-title: (string-ascii 20),
    art-medium: (string-ascii 12), ;; "spray", "marker", "paste", "chalk", "paint"
    dimensions: uint, ;; square meters
    completion-time: uint, ;; hours
    technique: (string-ascii 12), ;; "freehand", "stencil", "wheatpaste", "tag"
    piece-notes: (string-ascii 70),
    creation-date: uint,
    still-visible: bool
  }
)

;; Spot reviews
(define-map spot-reviews
  { spot-id: uint, reviewer: principal }
  {
    rating: uint, ;; 1-10
    review-text: (string-ascii 70),
    safety-rating: (string-ascii 6), ;; "safe", "risky", "danger"
    review-date: uint,
    dope-votes: uint
  }
)

;; Artist milestones
(define-map artist-milestones
  { artist: principal, milestone: (string-ascii 12) }
  {
    achievement-date: uint,
    piece-count: uint
  }
)

;; Helper function to get or create profile
(define-private (get-or-create-profile (artist principal))
  (match (map-get? artist-profiles artist)
    profile profile
    {
      username: "",
      art-style: "graffiti",
      pieces-created: u0,
      spots-documented: u0,
      total-size: u0,
      artist-level: u1,
      join-date: stacks-block-height
    }
  )
)

;; Token functions
(define-read-only (get-name)
  (ok token-name)
)

(define-read-only (get-symbol)
  (ok token-symbol)
)

(define-read-only (get-decimals)
  (ok token-decimals)
)

(define-read-only (get-balance (user principal))
  (ok (default-to u0 (map-get? token-balances user)))
)

(define-private (mint-tokens (recipient principal) (amount uint))
  (let (
    (current-balance (default-to u0 (map-get? token-balances recipient)))
    (new-balance (+ current-balance amount))
    (new-total-supply (+ (var-get total-supply) amount))
  )
    (asserts! (<= new-total-supply token-max-supply) err-invalid-input)
    (map-set token-balances recipient new-balance)
    (var-set total-supply new-total-supply)
    (ok amount)
  )
)

;; Add art spot
(define-public (add-art-spot (spot-name (string-ascii 20)) (neighborhood (string-ascii 18)) (surface-type (string-ascii 12)) (visibility (string-ascii 8)) (legal-status (string-ascii 8)) (access-level (string-ascii 8)))
  (let (
    (spot-id (var-get next-spot-id))
    (profile (get-or-create-profile tx-sender))
  )
    (asserts! (> (len spot-name) u0) err-invalid-input)
    (asserts! (> (len neighborhood) u0) err-invalid-input)
    
    (map-set art-spots spot-id {
      spot-name: spot-name,
      neighborhood: neighborhood,
      surface-type: surface-type,
      visibility: visibility,
      legal-status: legal-status,
      access-level: access-level,
      finder: tx-sender,
      piece-count: u0,
      average-rating: u0
    })
    
    ;; Update profile
    (map-set artist-profiles tx-sender
      (merge profile {spots-documented: (+ (get spots-documented profile) u1)})
    )
    
    ;; Award spot documentation tokens
    (try! (mint-tokens tx-sender reward-spot))
    
    (var-set next-spot-id (+ spot-id u1))
    (print {action: "art-spot-added", spot-id: spot-id, finder: tx-sender})
    (ok spot-id)
  )
)

;; Create art piece
(define-public (create-art-piece (spot-id uint) (piece-title (string-ascii 20)) (art-medium (string-ascii 12)) (dimensions uint) (completion-time uint) (technique (string-ascii 12)) (piece-notes (string-ascii 70)) (still-visible bool))
  (let (
    (piece-id (var-get next-piece-id))
    (spot (unwrap! (map-get? art-spots spot-id) err-not-found))
    (profile (get-or-create-profile tx-sender))
  )
    (asserts! (> (len piece-title) u0) err-invalid-input)
    (asserts! (> dimensions u0) err-invalid-input)
    (asserts! (> completion-time u0) err-invalid-input)
    
    (map-set art-pieces piece-id {
      spot-id: spot-id,
      artist: tx-sender,
      piece-title: piece-title,
      art-medium: art-medium,
      dimensions: dimensions,
      completion-time: completion-time,
      technique: technique,
      piece-notes: piece-notes,
      creation-date: stacks-block-height,
      still-visible: still-visible
    })
    
    ;; Update spot piece count
    (map-set art-spots spot-id
      (merge spot {piece-count: (+ (get piece-count spot) u1)})
    )
    
    ;; Update profile
    (map-set artist-profiles tx-sender
      (merge profile {
        pieces-created: (+ (get pieces-created profile) u1),
        total-size: (+ (get total-size profile) dimensions),
        artist-level: (+ (get artist-level profile) (/ dimensions u10))
      })
    )
    
    ;; Award creation tokens with visibility bonus
    (let (
      (base-reward reward-creation)
      (visible-bonus (if still-visible u1000000 u0))
    )
      (try! (mint-tokens tx-sender (+ base-reward visible-bonus)))
    )
    
    (var-set next-piece-id (+ piece-id u1))
    (print {action: "art-piece-created", piece-id: piece-id, spot-id: spot-id})
    (ok piece-id)
  )
)

;; Write spot review
(define-public (write-review (spot-id uint) (rating uint) (review-text (string-ascii 70)) (safety-rating (string-ascii 6)))
  (let (
    (spot (unwrap! (map-get? art-spots spot-id) err-not-found))
    (profile (get-or-create-profile tx-sender))
  )
    (asserts! (and (>= rating u1) (<= rating u10)) err-invalid-input)
    (asserts! (> (len review-text) u0) err-invalid-input)
    (asserts! (is-none (map-get? spot-reviews {spot-id: spot-id, reviewer: tx-sender})) err-already-exists)
    
    (map-set spot-reviews {spot-id: spot-id, reviewer: tx-sender} {
      rating: rating,
      review-text: review-text,
      safety-rating: safety-rating,
      review-date: stacks-block-height,
      dope-votes: u0
    })
    
    ;; Update spot average rating (simplified calculation)
    (let (
      (current-avg (get average-rating spot))
      (piece-count (get piece-count spot))
      (new-avg (if (> piece-count u0)
                 (/ (+ (* current-avg piece-count) rating) (+ piece-count u1))
                 rating))
    )
      (map-set art-spots spot-id (merge spot {average-rating: new-avg}))
    )
    
    (print {action: "review-written", spot-id: spot-id, reviewer: tx-sender})
    (ok true)
  )
)

;; Vote review dope
(define-public (vote-dope (spot-id uint) (reviewer principal))
  (let (
    (review (unwrap! (map-get? spot-reviews {spot-id: spot-id, reviewer: reviewer}) err-not-found))
  )
    (asserts! (not (is-eq tx-sender reviewer)) err-unauthorized)
    
    (map-set spot-reviews {spot-id: spot-id, reviewer: reviewer}
      (merge review {dope-votes: (+ (get dope-votes review) u1)})
    )
    
    (print {action: "review-voted-dope", spot-id: spot-id, reviewer: reviewer})
    (ok true)
  )
)

;; Update art style
(define-public (update-art-style (new-art-style (string-ascii 12)))
  (let (
    (profile (get-or-create-profile tx-sender))
  )
    (asserts! (> (len new-art-style) u0) err-invalid-input)
    
    (map-set artist-profiles tx-sender (merge profile {art-style: new-art-style}))
    
    (print {action: "art-style-updated", artist: tx-sender, style: new-art-style})
    (ok true)
  )
)

;; Claim milestone
(define-public (claim-milestone (milestone (string-ascii 12)))
  (let (
    (profile (get-or-create-profile tx-sender))
  )
    (asserts! (is-none (map-get? artist-milestones {artist: tx-sender, milestone: milestone})) err-already-exists)
    
    ;; Check milestone requirements
    (let (
      (milestone-met
        (if (is-eq milestone "writer-80") (>= (get pieces-created profile) u80)
        (if (is-eq milestone "scout-15") (>= (get spots-documented profile) u15)
        false)))
    )
      (asserts! milestone-met err-unauthorized)
      
      ;; Record milestone
      (map-set artist-milestones {artist: tx-sender, milestone: milestone} {
        achievement-date: stacks-block-height,
        piece-count: (get pieces-created profile)
      })
      
      ;; Award milestone tokens
      (try! (mint-tokens tx-sender reward-milestone))
      
      (print {action: "milestone-claimed", artist: tx-sender, milestone: milestone})
      (ok true)
    )
  )
)

;; Update username
(define-public (update-username (new-username (string-ascii 24)))
  (let (
    (profile (get-or-create-profile tx-sender))
  )
    (asserts! (> (len new-username) u0) err-invalid-input)
    (map-set artist-profiles tx-sender (merge profile {username: new-username}))
    (print {action: "username-updated", artist: tx-sender})
    (ok true)
  )
)

;; Read-only functions
(define-read-only (get-artist-profile (artist principal))
  (map-get? artist-profiles artist)
)

(define-read-only (get-art-spot (spot-id uint))
  (map-get? art-spots spot-id)
)

(define-read-only (get-art-piece (piece-id uint))
  (map-get? art-pieces piece-id)
)

(define-read-only (get-spot-review (spot-id uint) (reviewer principal))
  (map-get? spot-reviews {spot-id: spot-id, reviewer: reviewer})
)

(define-read-only (get-milestone (artist principal) (milestone (string-ascii 12)))
  (map-get? artist-milestones {artist: artist, milestone: milestone})
)