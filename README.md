# StreetArt - Digital Street Art Community Platform

A blockchain-based platform built on Stacks that connects street artists through spot documentation, art piece logging, and community rewards.

## Overview

StreetArt is a decentralized application that rewards street artists and art enthusiasts for contributing to the community by documenting art spots, creating art pieces, writing reviews, and achieving milestones. The platform issues **Culture Tokens (SCT)** as rewards for community participation.

## Features

### 🎨 Core Functionality

- **Artist Profiles**: Personalized profiles tracking username, art style, pieces created, spots documented, total canvas size, and artist level
- **Art Spot Database**: Community-curated database of street art locations with detailed information about surfaces, visibility, and legal status
- **Art Piece Creation**: Log your street art with details about medium, dimensions, technique, and visibility status
- **Spot Reviews**: Rate and review art spots with safety considerations to help the community
- **Milestone System**: Earn special rewards for reaching community milestones
- **SCT Token Rewards**: Get rewarded for contributions with blockchain-based tokens

### 🪙 Token Economics

**Token Details:**
- Name: StreetArt Culture Token
- Symbol: SCT
- Decimals: 6
- Max Supply: 52,000 SCT

**Reward Structure:**
- **Art Piece Creation**: 2.5 SCT (+ 1.0 SCT bonus if still visible)
- **Spot Documentation**: 3.3 SCT
- **Milestone Achievement**: 9.5 SCT

## Smart Contract Functions

### Public Functions

#### Profile Management

##### `update-username`
```clarity
(update-username (new-username (string-ascii 24)))
```
Update your artist username.

##### `update-art-style`
```clarity
(update-art-style (new-art-style (string-ascii 12)))
```
Set your art style: "graffiti", "stencil", "mural", "poster", or "mixed".

#### Spot Management

##### `add-art-spot`
```clarity
(add-art-spot 
  (spot-name (string-ascii 20))
  (neighborhood (string-ascii 18))
  (surface-type (string-ascii 12))
  (visibility (string-ascii 8))
  (legal-status (string-ascii 8))
  (access-level (string-ascii 8)))
```
Add a new street art spot to the community database.

**Parameters:**
- `spot-name`: Name of the spot (max 20 chars)
- `neighborhood`: Neighborhood/area (max 18 chars)
- `surface-type`: "wall", "bridge", "tunnel", "building", or "fence"
- `visibility`: "high", "medium", "low", or "hidden"
- `legal-status`: "legal", "tolerated", or "illegal"
- `access-level`: "public", "private", or "restricted"

**Rewards**: 3.3 SCT

#### Art Piece Creation

##### `create-art-piece`
```clarity
(create-art-piece
  (spot-id uint)
  (piece-title (string-ascii 20))
  (art-medium (string-ascii 12))
  (dimensions uint)
  (completion-time uint)
  (technique (string-ascii 12))
  (piece-notes (string-ascii 70))
  (still-visible bool))
```
Log a street art piece creation at a specific spot.

**Parameters:**
- `spot-id`: ID of the art spot
- `piece-title`: Title of the artwork (max 20 chars)
- `art-medium`: "spray", "marker", "paste", "chalk", or "paint"
- `dimensions`: Size in square meters
- `completion-time`: How long it took in hours
- `technique`: "freehand", "stencil", "wheatpaste", or "tag"
- `piece-notes`: Description (max 70 chars)
- `still-visible`: Whether the piece is still visible/intact

**Rewards**: 2.5 SCT (3.5 SCT if still-visible is true)

**Additional Effects:**
- Increases artist level based on dimensions (1 level per 10 sq meters)
- Updates total canvas size
- Increments piece count
- Updates spot piece count

#### Reviews

##### `write-review`
```clarity
(write-review
  (spot-id uint)
  (rating uint)
  (review-text (string-ascii 70))
  (safety-rating (string-ascii 6)))
```
Write a review for an art spot.

**Parameters:**
- `spot-id`: ID of the spot to review
- `rating`: Rating from 1-10
- `review-text`: Review content (max 70 chars)
- `safety-rating`: "safe", "risky", or "danger"

**Notes**: Each artist can only review a spot once.

##### `vote-dope`
```clarity
(vote-dope (spot-id uint) (reviewer principal))
```
Vote a review as "dope" (upvote). Cannot vote on your own reviews.

#### Milestones

##### `claim-milestone`
```clarity
(claim-milestone (milestone (string-ascii 12)))
```
Claim a milestone achievement and receive bonus tokens.

**Available Milestones:**
- `"writer-80"`: Create 80+ art pieces
- `"scout-15"`: Document 15+ spots

**Rewards**: 9.5 SCT per milestone

### Read-Only Functions

##### `get-artist-profile`
```clarity
(get-artist-profile (artist principal))
```
Retrieve an artist's profile information.

##### `get-art-spot`
```clarity
(get-art-spot (spot-id uint))
```
Get details about a specific art spot.

##### `get-art-piece`
```clarity
(get-art-piece (piece-id uint))
```
Retrieve information about a created art piece.

##### `get-spot-review`
```clarity
(get-spot-review (spot-id uint) (reviewer principal))
```
Get a specific review for a spot.

##### `get-milestone`
```clarity
(get-milestone (artist principal) (milestone (string-ascii 12)))
```
Check if an artist has claimed a specific milestone.

##### Token Functions
- `get-name`: Returns token name
- `get-symbol`: Returns token symbol
- `get-decimals`: Returns token decimals
- `get-balance`: Returns token balance for a user

## Data Structures

### Artist Profile
```clarity
{
  username: (string-ascii 24),
  art-style: (string-ascii 12),
  pieces-created: uint,
  spots-documented: uint,
  total-size: uint,
  artist-level: uint,
  join-date: uint
}
```

### Art Spot
```clarity
{
  spot-name: (string-ascii 20),
  neighborhood: (string-ascii 18),
  surface-type: (string-ascii 12),
  visibility: (string-ascii 8),
  legal-status: (string-ascii 8),
  access-level: (string-ascii 8),
  finder: principal,
  piece-count: uint,
  average-rating: uint
}
```

### Art Piece
```clarity
{
  spot-id: uint,
  artist: principal,
  piece-title: (string-ascii 20),
  art-medium: (string-ascii 12),
  dimensions: uint,
  completion-time: uint,
  technique: (string-ascii 12),
  piece-notes: (string-ascii 70),
  creation-date: uint,
  still-visible: bool
}
```

### Spot Review
```clarity
{
  rating: uint,
  review-text: (string-ascii 70),
  safety-rating: (string-ascii 6),
  review-date: uint,
  dope-votes: uint
}
```

## Error Codes

- `u100`: Owner only operation
- `u101`: Resource not found
- `u102`: Resource already exists
- `u103`: Unauthorized operation
- `u104`: Invalid input

## Usage Examples

### Documenting an Art Spot
```clarity
(contract-call? .streetart add-art-spot
  "The Bowery Wall"
  "Lower East Side"
  "wall"
  "high"
  "legal"
  "public")
```

### Creating an Art Piece
```clarity
(contract-call? .streetart create-art-piece
  u1
  "Urban Dreams"
  "spray"
  u25
  u8
  "freehand"
  "Colorful abstract piece celebrating city life"
  true)
```

### Writing a Review
```clarity
(contract-call? .streetart write-review
  u1
  u9
  "Perfect spot, great lighting and visibility"
  "safe")
```

### Claiming a Milestone
```clarity
(contract-call? .streetart claim-milestone "writer-80")
```

## Legal & Safety Considerations

### Important Notes

⚠️ **Legal Disclaimer**: This platform is for documentation and community building purposes. Users are responsible for:
- Understanding and complying with local laws regarding street art
- Respecting property rights
- Considering safety when visiting or creating art at documented spots

The contract includes fields for `legal-status` and `safety-rating` to help users make informed decisions about participating in street art activities.

### Safety Features

- **Safety Ratings**: Reviews include safety assessments ("safe", "risky", "danger")
- **Legal Status Tracking**: Spots are tagged with legal status information
- **Access Level**: Indicates whether spots are public, private, or restricted
- **Visibility Tracking**: Artists can note if their work is still visible (useful for ephemeral art)

## Development

### Prerequisites
- Clarity CLI
- Stacks blockchain node (for deployment)

### Testing
Test the contract using the Clarity REPL or Clarinet testing framework.

### Testing Focus Areas
- Profile creation and updates
- Spot documentation workflow
- Art piece creation with various parameters
- Review system and voting
- Milestone requirement validation
- Token minting and supply cap
- Edge cases (invalid inputs, duplicates, etc.)

### Deployment
Deploy to Stacks mainnet or testnet using the Stacks CLI.

## Contributing

Contributions are welcome! Areas for improvement:
- Additional milestone types (total size milestones, style diversity)
- Art style categorization and tracking
- Crew/collective functionality
- Image hash storage (IPFS integration)
- Time-lapse tracking for pieces
- Collaboration features (multi-artist pieces)
- Exhibition/gallery events
- Art preservation tracking

## Comparison with Similar Platforms

This contract is structurally similar to community documentation platforms but specifically tailored for street art:
- **Focus on ephemeral art**: Tracks visibility over time
- **Safety considerations**: Includes safety ratings for spots
- **Legal awareness**: Documents legal status of locations
- **Physical dimensions**: Tracks actual canvas size and completion time
- **Medium diversity**: Supports various street art techniques

## License

[Add your license here]

## Community

Join the street art revolution on the blockchain! 🎨⛓️

---

*Respect the culture, document the art, build the community!*
