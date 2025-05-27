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