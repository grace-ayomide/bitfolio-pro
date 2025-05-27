# BitFolio Pro

## Decentralized Portfolio Management Protocol for Bitcoin-native DeFi

---

## 🧠 Overview

**BitFolio Pro** is an advanced, gas-efficient protocol built on **Stacks Layer 2**, enabling users to create and manage diversified cryptocurrency portfolios with institutional-grade controls. It supports **automated portfolio rebalancing**, **custom allocation strategies**, and **multi-portfolio management** — all designed for seamless integration within the Bitcoin DeFi ecosystem.

---

## 📌 Key Features

* ✅ **Multi-token portfolio creation** with precision allocation in basis points
* 🔁 **Automated rebalancing** triggered by time or allocation deviation
* 🎯 **Professional-grade asset management** with SIP-010 token compatibility
* 🪙 **Low gas & storage footprint**, optimized for Bitcoin-based smart contracts
* 👤 **Multi-portfolio support per user** with authorization controls
* 🔒 **Immutable protocol configuration** with owner-controlled governance

---

## ⚙️ Architecture Overview

### 📂 Data Structures

* **Portfolios (`Portfolios`)**
  Stores metadata like owner, creation time, token count, rebalancing timestamps, and portfolio status.

* **Assets (`PortfolioAssets`)**
  Maps each token to a portfolio, with target allocation percentage, current balance, and SIP-010 token address.

* **User Registry (`UserPortfolios`)**
  Associates each user with up to 20 portfolios.

### 🔄 Rebalancing Engine

* Calculates whether a portfolio needs rebalancing based on a 24-hour block interval.
* Enables users to trigger rebalancing transactions to align current holdings with target percentages.

### ✅ Validation Layer

* Validates:

  * Allocation percentages (0–10000 basis points)
  * Portfolio-token relationships
  * Maximum portfolio/token limits
  * User authorization before mutating state

---

## 📜 Contract Constants

| Constant                   | Value        | Description                        |
| -------------------------- | ------------ | ---------------------------------- |
| `BASIS-POINTS`             | `10000`      | Basis point scale (1 BP = 0.01%)   |
| `MAX-TOKENS-PER-PORTFOLIO` | `10`         | Portfolio diversification cap      |
| `protocol-fee`             | `25` (0.25%) | Protocol-level fee in basis points |

---

## 🔧 Public Functions

### 📁 Portfolio Management

```clojure
(create-portfolio (initial-tokens) (percentages))
```

Creates a portfolio with specified tokens and allocation ratios.

```clojure
(update-portfolio-allocation (portfolio-id) (token-id) (new-percentage))
```

Adjusts target allocation for a token in a portfolio.

### 🔁 Rebalancing

```clojure
(rebalance-portfolio (portfolio-id))
```

Triggers realignment of assets to match target allocations.

---

## 📖 Read-Only Functions

```clojure
(get-portfolio (portfolio-id)) → portfolio metadata
(get-portfolio-asset (portfolio-id) (token-id)) → asset details
(get-user-portfolios (user)) → list of user portfolio IDs
(calculate-rebalance-amounts (portfolio-id)) → needs-rebalance? & portfolio value
```

---

## 🛡️ Error Codes

| Code                                | Meaning                      |
| ----------------------------------- | ---------------------------- |
| `u100` - `ERR-NOT-AUTHORIZED`       | Unauthorized access          |
| `u101` - `ERR-INVALID-PORTFOLIO`    | Invalid portfolio ID         |
| `u102` - `ERR-INSUFFICIENT-BALANCE` | Insufficient balance         |
| `u106` - `ERR-INVALID-PERCENTAGE`   | Invalid percentage value     |
| `u107` - `ERR-MAX-TOKENS-EXCEEDED`  | Too many tokens in portfolio |
| ...                                 | See contract for full list   |

---

## 🛠️ Governance & Admin

```clojure
(initialize (new-owner))
```

Transfers protocol ownership (one-time operation by current owner).

---

## 🧪 Development & Testing

To test locally:

* Deploy to the **Clarinet** environment
* Use mocks or real SIP-010 tokens for testing allocations
* Simulate rebalancing through controlled block advancement

---

## 📚 Dependencies

* **Stacks Blockchain (Clarity)**
* **SIP-010 Compliant Tokens**
* **Stacks 2.0 Smart Contracts Environment**
