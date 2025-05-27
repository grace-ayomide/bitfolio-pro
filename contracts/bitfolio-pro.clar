;; Title: BitFolio Pro - Decentralized Portfolio Management Protocol
;;
;; Summary: Advanced multi-asset portfolio rebalancing and allocation 
;;          management system built for Bitcoin-native DeFi on Stacks L2
;;
;; Description: BitFolio Pro enables users to create, manage, and 
;;              automatically rebalance diversified cryptocurrency portfolios
;;              with precision allocation controls. Built with institutional-
;;              grade risk management and gas-efficient operations optimized
;;              for the Bitcoin ecosystem via Stacks Layer 2 infrastructure.
;;
;; Features:
;;   - Multi-token portfolio creation with customizable allocations
;;   - Automated rebalancing with configurable time intervals  
;;   - Basis point precision for professional-grade allocation management
;;   - SIP-010 token standard compatibility for seamless DeFi integration
;;   - Gas-optimized operations with minimal on-chain storage footprint
;;   - Multi-portfolio management per user with institutional controls
;;

;; ERROR CODES - Structured Operational Failure States

(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-INVALID-PORTFOLIO (err u101))
(define-constant ERR-INSUFFICIENT-BALANCE (err u102))
(define-constant ERR-INVALID-TOKEN (err u103))
(define-constant ERR-REBALANCE-FAILED (err u104))
(define-constant ERR-PORTFOLIO-EXISTS (err u105))
(define-constant ERR-INVALID-PERCENTAGE (err u106))
(define-constant ERR-MAX-TOKENS-EXCEEDED (err u107))
(define-constant ERR-LENGTH-MISMATCH (err u108))
(define-constant ERR-USER-STORAGE-FAILED (err u109))
(define-constant ERR-INVALID-TOKEN-ID (err u110))

;; PROTOCOL CONFIGURATION - Immutable System Parameters

(define-data-var protocol-owner principal tx-sender)
(define-data-var portfolio-counter uint u0)
(define-data-var protocol-fee uint u25) ;; 0.25% fee in basis points (1 BP = 0.01%)

(define-constant MAX-TOKENS-PER-PORTFOLIO u10)
(define-constant BASIS-POINTS u10000)

;; DATA STORAGE - State Management Architecture

;; Core portfolio metadata with NFT-style unique identification
(define-map Portfolios
    uint ;; Unique portfolio identifier
    {
        owner: principal,
        created-at: uint,
        last-rebalanced: uint,
        total-value: uint, ;; Value stored in satoshi equivalents
        active: bool,
        token-count: uint,
    }
)

;; Individual asset allocations within portfolios
(define-map PortfolioAssets
    {
        portfolio-id: uint,
        token-id: uint,
    }
    {
        target-percentage: uint, ;; Target allocation in basis points
        current-amount: uint, ;; Current token quantity held
        token-address: principal, ;; SIP-010 compliant token contract
    }
)

;; User-to-portfolio relationship mapping
(define-map UserPortfolios
    principal
    (list 20 uint) ;; Maximum 20 portfolios per user
)

;; READ-ONLY INTERFACE - Query Functions

;; Retrieve complete portfolio information
(define-read-only (get-portfolio (portfolio-id uint))
    (map-get? Portfolios portfolio-id)
)

;; Get specific asset allocation within a portfolio
(define-read-only (get-portfolio-asset
        (portfolio-id uint)
        (token-id uint)
    )
    (map-get? PortfolioAssets {
        portfolio-id: portfolio-id,
        token-id: token-id,
    })
)

;; Retrieve all portfolios owned by a specific user
(define-read-only (get-user-portfolios (user principal))
    (default-to (list) (map-get? UserPortfolios user))
)

;; Calculate rebalancing requirements and recommendations
(define-read-only (calculate-rebalance-amounts (portfolio-id uint))
    (let (
            (portfolio (unwrap! (get-portfolio portfolio-id) ERR-INVALID-PORTFOLIO))
            (total-value (get total-value portfolio))
        )
        (ok {
            portfolio-id: portfolio-id,
            total-value: total-value,
            needs-rebalance: (> (- stacks-block-height (get last-rebalanced portfolio)) u144), ;; 24 hour block interval
        })
    )
)

;; CORE FUNCTIONALITY - Portfolio Creation & Management

;; Create new diversified portfolio with initial token allocation
(define-public (create-portfolio
        (initial-tokens (list 10 principal))
        (percentages (list 10 uint))
    )
    (let (
            (portfolio-id (+ (var-get portfolio-counter) u1))
            (token-count (len initial-tokens))
            (percentage-count (len percentages))
            (token-0 (element-at? initial-tokens u0))
            (token-1 (element-at? initial-tokens u1))
            (percentage-0 (element-at? percentages u0))
            (percentage-1 (element-at? percentages u1))
        )
        ;; Comprehensive validation layer
        (asserts! (<= token-count MAX-TOKENS-PER-PORTFOLIO)
            ERR-MAX-TOKENS-EXCEEDED
        )
        (asserts! (is-eq token-count percentage-count) ERR-LENGTH-MISMATCH)
        (asserts! (validate-portfolio-percentages percentages)
            ERR-INVALID-PERCENTAGE
        )
        ;; Initialize portfolio metadata
        (map-set Portfolios portfolio-id {
            owner: tx-sender,
            created-at: stacks-block-height,
            last-rebalanced: stacks-block-height,
            total-value: u0,
            active: true,
            token-count: token-count,
        })
        ;; Initialize first two assets (minimum viable portfolio)
        (asserts! (and (is-some token-0) (is-some token-1)) ERR-INVALID-TOKEN)
        (asserts! (and (is-some percentage-0) (is-some percentage-1))
            ERR-INVALID-PERCENTAGE
        )
        (try! (initialize-portfolio-asset u0 (unwrap-panic token-0)
            (unwrap-panic percentage-0) portfolio-id
        ))
        (try! (initialize-portfolio-asset u1 (unwrap-panic token-1)
            (unwrap-panic percentage-1) portfolio-id
        ))
        ;; Update user portfolio registry and increment counter
        (try! (add-to-user-portfolios tx-sender portfolio-id))
        (var-set portfolio-counter portfolio-id)
        (ok portfolio-id)
    )
)