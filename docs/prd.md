# Roblox Tycoon Game V1 – Product Requirements Document

## 1. Game Overview

**Genre & Style:** Idle-tycoon simulation on Roblox where players build and automate a shared economy of small businesses.

**Objective:** Place businesses anywhere in a persistent world, intertwining with other players' networks to form dynamic production chains and logistics routes.

**Key Hook:** Socially emergent optimization—players discover synergies by connecting their chains with those of others, driving long-term engagement and competitive collaboration.

## 2. Core Gameplay Loop

1. **Place Business:** Spend currency to place a facility anywhere on the shared map.
2. **Buy Inventory:** Purchase input resources (at a per-unit cost) to fill the facility's incoming buffer.
3. **Produce Goods:** Facility converts inputs into outputs at its processing rate, storing them in buffers.
4. **Hire Deliverer:** Hire a delivery bot at the facility; it becomes "home-based" there and begins automated transport.
5. **Deliver or Sell:** Bot picks up finished goods and delivers to the nearest requesting facility (full profit) or to the Market (discounted rate).
6. **Earn & Upgrade:** Profits fund new placements, additional bots, three upgrade paths per facility, and more inventory purchases.
7. **Repeat & Scale:** Networks grow organically as players interact, optimize shared logistics, and expand production tiers.

## 3. Business Logic

### 3.1 Production Chain

**Input → Processing → Output:**

- **Incoming Buffer:** Holds purchased inputs up to its current capacity.
- **Processing:** Converts each batch of inputs into outputs over a fixed processing time.
- **Outgoing Buffer:** Queues outputs awaiting pickup.

### 3.2 Inventory Purchase

- **Cost to Acquire:** Players must pay an in-game currency cost per unit of input resource.
- **Buffer Limits:** Purchased resources cannot exceed the facility's Incoming Buffer capacity; excess purchase attempts are disallowed or partially filled.
- **Profit Flow:** Buying input incurs expense; selling output via bots yields revenue, creating a full buy-produce-sell economic cycle.

### 3.3 Upgrade Paths (per Facility)

- Incoming Inventory Capacity – increases maximum stored inputs.
- Processing Speed – reduces processing time per batch.
- Outgoing Inventory Capacity – increases maximum stored outputs.

### 3.4 Market vs. Chain Pricing

- **Chain Delivery:** Full internal trade value when delivering to another facility.
- **Market Delivery:** Discounted rate (e.g. 50% of trade value) when no requests exist.

### 3.5 Request System

- Facilities below full input capacity display a floating request icon (resource + "!").
- Deliverers scan for these signals and target the closest facility, irrespective of ownership.

## 4. Delivery System & Bot Behavior

### 4.1 Hiring & Assignment

- "Hire Deliverer" button in each facility's floating UI spawns a bot bound to that facility.
- Bot stats (carry size, speed) and hire cost are shown next to the action.

### 4.2 Delivery Logic

- **Pickup:** Bot collects goods from its home facility's Outgoing Buffer.
- **Targeting:** Searches the entire shared world for the nearest facility requesting that resource.
- **Fallback:** If no request exists, delivers to the Market.
- **Cycle:** Returns home and repeats indefinitely.

### 4.3 Profit Calculation

- **Full-Value Sale:** Delivery to another facility → full credit.
- **Market Sale:** Delivery to Market → discounted credit.
- **Bot ROI:** Measured by how quickly its deliveries recoup its hire cost.

## 5. Visual & UI Elements

### Facility Upgrade Panel

Each facility opens a dedicated UI panel (adjacent to or overlapping the model) that consolidates all upgrade and management controls:

#### Input Controls
- **Input Capacity Slider/Button:**
  - Displays current and maximum incoming inventory capacity
  - Allows incrementing capacity in defined upgrade tiers
  - Shows cost per tier with coin icon

#### Output Controls
- **Output Capacity Slider/Button:**
  - Displays current and maximum outgoing inventory capacity
  - Allows incrementing capacity
  - Shows cost and level

#### Processing Controls
- **Processing Speed Control:**
  - Shows current processing rate in units per minute (e.g. "10/min")
  - Buttons to upgrade speed
  - Displays cost and resulting new rate

#### Deliverer Settings
- **Speed Upgrade:**
  - Shows current deliverer travel speed
  - Button to upgrade
  - Displays upgrade cost and new speed metric
- **# of Deliverers Management:**
  - Displays number of active deliverers
  - Button to hire additional deliverers
  - Shows hire cost per deliverer

### Panel Layout & Indicators

- Organized into two columns: Inputs & Processing on the left, Deliverers & Outputs on the right
- Each upgrade control shows:
  - Icon
  - Current value
  - Next-level value
  - Cost (coin icon)
- Current use vs. capacity bars appear inline with capacity controls (e.g. 40/100)

### HUD Elements

- Global currency balance and income rate remain fixed in the top corner
- Optional minimap or overlay can show nearby facility connections and active requests

## 6. Progression & Scaling

- **Emergent Synergies:** Players discover and exploit others' networks
- **Dynamic World:** No individual plots—facilities interact across all players
- **Bottleneck Visibility:** Highlight paused facilities when buffers fill
- **Performance:** Spatial streaming and culling for distant builds

## 7. Technical Considerations

### Multiplayer Interaction
- Use RemoteEvents to broadcast facility state changes
- Minimize data replication

### Performance Optimization
- Maintain ≤30K parts per server region
- Merge meshes
- Minimize small Instances
- Bots disable collisions when idle
- Cache common paths

### Security & Authority
- Server validates purchases and delivery completions

### UI Scaling
- Scale-based sizing
- Mobile-first testing priority

## 8. MVP Scope

### Must-Haves
- Shared-world placement and interaction
- Full buy-produce-deliver-sell loop
- Three upgrade paths per facility
- Floating facility UI with all controls
- Market differential pricing
- Delivery bots with automated routing

### Stretch Goals
- Advanced resource tiers
- Bot upgrades
- Offline earnings
- Social features
- Achievements and leaderboards
- Cosmetic customization
- Localization support
