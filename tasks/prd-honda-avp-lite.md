# PRD: Honda AVP Lite

## Introduction

Honda AVP Lite is a stripped-down proof-of-concept iOS app that validates the core pipeline: **Supabase → Data Model → ARKit Rendering**. This MVP extracts annotation data from Supabase and displays simple 3D markers (spheres with text labels) in AR space.

This is NOT the full Honda AVP Viewer app. It's a technical validation to prove:
1. Supabase can store and sync spatial annotation data
2. ARKit can render that data in 3D space
3. The data pipeline works end-to-end

## Goals

- Validate Supabase as a viable backend for spatial annotation data
- Prove the data pipeline: Supabase → Swift Model → ARKit rendering
- Render 3D spheres at annotation positions in AR space
- Display text labels associated with each annotation
- Keep implementation as simple as possible (no auth, no calibration, no real-time)
- Create seed script to populate test data in Supabase

## User Stories

### US-001: Set up Supabase project and schema
**Description:** As a developer, I need a Supabase project with the annotation schema so data can be stored and retrieved.

**Acceptance Criteria:**
- [ ] Supabase project created at supabase.com (FREE tier)
- [ ] `annotations` table defined with fields: `id`, `position_x`, `position_y`, `position_z`, `text_label`, `created_at`
- [ ] Row Level Security configured for public read access (no auth for MVP)
- [ ] Supabase URL and anon key obtained for iOS app
- [ ] Typecheck passes

### US-002: Create Swift model for Annotation
**Description:** As a developer, I need a local data model that maps to Supabase records so I can work with annotations in Swift.

**Acceptance Criteria:**
- [ ] `Annotation` struct with properties: `id: UUID`, `positionX: Float`, `positionY: Float`, `positionZ: Float`, `textLabel: String`, `createdAt: Date`
- [ ] Conforms to `Codable` for JSON decoding from Supabase
- [ ] Computed property `position: SIMD3<Float>` for easy access
- [ ] Model compiles without errors
- [ ] Typecheck passes

### US-003: Implement Supabase fetch service
**Description:** As a developer, I need a service that fetches all annotations from Supabase so I can display them.

**Acceptance Criteria:**
- [ ] `SupabaseService` class with `fetchAnnotations() async throws -> [Annotation]`
- [ ] Uses Supabase Swift SDK to query all `annotations` records
- [ ] Converts JSON response to `Annotation` model
- [ ] Handles empty results gracefully
- [ ] Handles network errors with clear error messages
- [ ] Typecheck passes

### US-004: Create seed script for test data
**Description:** As a developer, I need sample data in Supabase so I can test the AR rendering without the Vision Pro app.

**Acceptance Criteria:**
- [ ] Seed function that creates 7 test annotations (or SQL script in `Supabase/schema.sql`)
- [ ] Annotations positioned in a recognizable pattern (3D cross in front of camera)
- [ ] Each annotation has a descriptive text label (e.g., "Center", "Left", "Up")
- [ ] Can be triggered from SQL or a debug button in the app
- [ ] Typecheck passes

### US-005: Build minimal AR view with ARKit
**Description:** As a user, I want to launch an AR view that shows the camera feed so I can see annotations overlaid on the real world.

**Acceptance Criteria:**
- [ ] `ARViewerView` using `UIViewRepresentable` wrapping `ARView`
- [ ] `ARWorldTrackingConfiguration` with basic settings
- [ ] AR session starts when view appears
- [ ] AR session pauses when view disappears
- [ ] Camera feed displays on screen
- [ ] Typecheck passes

### US-006: Render spheres at annotation positions
**Description:** As a user, I want to see colored spheres floating in AR space at each annotation position so I can visualize where annotations exist.

**Acceptance Criteria:**
- [ ] Each annotation renders as a sphere (0.05m radius)
- [ ] Spheres use solid red color (UnlitMaterial for consistent appearance)
- [ ] Spheres positioned at `(positionX, positionY, positionZ)` relative to world origin
- [ ] All fetched annotations render on AR session start
- [ ] Typecheck passes

### US-007: Display text labels on annotations
**Description:** As a user, I want to see text labels near each sphere so I know what each annotation represents.

**Acceptance Criteria:**
- [ ] Text label renders above each sphere (0.03m offset)
- [ ] Text is readable (appropriate size, contrasting color)
- [ ] Text uses fixed orientation in space (no billboarding required)
- [ ] Label shows `textLabel` content from annotation
- [ ] Typecheck passes

### US-008: Add manual refresh button
**Description:** As a user, I want to manually refresh annotations so I can see new data without restarting the app.

**Acceptance Criteria:**
- [ ] Refresh button visible in AR view UI
- [ ] Tapping button fetches latest annotations from Supabase
- [ ] Existing spheres are cleared before rendering new ones
- [ ] Loading indicator shows during fetch
- [ ] Typecheck passes

### US-009: Create simple app entry point
**Description:** As a user, I want to launch the app and immediately see the AR view so I can start viewing annotations.

**Acceptance Criteria:**
- [ ] App launches directly to AR view (no login, no project selection)
- [ ] Annotations auto-fetch on appear
- [ ] Network errors display as inline message on screen (e.g., "Unable to retrieve data")
- [ ] Typecheck passes

## Functional Requirements

- **FR-1:** App must use Supabase (FREE tier) for annotation storage
- **FR-2:** App must use Codable Swift structs for data modeling
- **FR-3:** App must use ARKit/RealityKit for 3D rendering
- **FR-4:** Annotations render at world origin (0,0,0) with no calibration offset
- **FR-5:** Each annotation displays as a solid red sphere + text label at fixed orientation
- **FR-6:** User can manually refresh to fetch latest data
- **FR-7:** No authentication required (public read access via RLS)
- **FR-8:** Seed data available in SQL script
- **FR-9:** Network errors display as inline message on screen (not alerts)

## Non-Goals (Out of Scope)

- **No authentication UI** - public read access for MVP
- **No project/workspace concept** - single flat list of annotations
- **No real-time sync** - manual refresh only
- **No calibration system** - annotations render at absolute positions from origin
- **No stroke rendering** - only spheres and text, no 3D drawn lines
- **No annotation creation** - read-only, data comes from seed script or Vision Pro
- **No offline caching** - always fetches from Supabase
- **No author/user tracking** - annotations have no owner
- **No filtering or search** - shows all annotations

## Technical Considerations

### Supabase Schema

```sql
-- Table: annotations
CREATE TABLE annotations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  position_x FLOAT NOT NULL DEFAULT 0,
  position_y FLOAT NOT NULL DEFAULT 0,
  position_z FLOAT NOT NULL DEFAULT 0,
  text_label TEXT NOT NULL DEFAULT '',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Public read access (no auth for MVP)
ALTER TABLE annotations ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read access" ON annotations FOR SELECT USING (true);
```

### Data Flow

```
┌─────────────┐     ┌─────────────────┐     ┌─────────────┐
│  Supabase   │────►│ SupabaseService │────►│ [Annotation]  │
│  Database   │     │  .fetch()       │     │   Models      │
└─────────────┘     └─────────────────┘     └──────┬──────┘
                                                   │
                                                   ▼
                                          ┌─────────────┐
                                          │ ARViewModel │
                                          │ .render()   │
                                          └──────┬──────┘
                                                 │
                                                 ▼
                                          ┌─────────────┐
                                          │   ARView    │
                                          │  (Spheres)  │
                                          └─────────────┘
```

### Project Structure

```
HondaAVPLite/
├── App/
│   └── HondaAVPLiteApp.swift      # Entry point
├── Models/
│   └── Annotation.swift            # Codable model
├── Services/
│   ├── SupabaseConfig.swift        # URL + anon key
│   └── SupabaseService.swift       # Data fetching
├── Views/
│   └── ARViewerView.swift          # AR view + UI
├── ViewModels/
│   └── ARViewModel.swift           # Rendering logic
└── Debug/
    └── SeedData.swift              # Test data generator (optional)
```

### Dependencies

- **Supabase Swift SDK** - `supabase-swift` package (FREE, open source)
- ARKit (Apple framework, FREE)
- RealityKit (Apple framework, FREE)

### Device Requirements

- iOS 17.0+
- iPhone with ARKit support (iPhone 6s or later)
- Internet connection (for Supabase)
- Camera permission granted

## Success Metrics

- [ ] App compiles and runs on physical device
- [ ] Seed data successfully populates Supabase
- [ ] Annotations fetch from Supabase without errors
- [ ] Spheres render at correct positions in AR space
- [ ] Text labels are visible and readable
- [ ] Refresh button updates displayed annotations
- [ ] Pipeline validated: Supabase → Model → ARKit works end-to-end

## Design Decisions (Resolved)

| Decision | Choice | Rationale |
|----------|--------|-----------|
| **Backend** | Supabase (FREE tier) | CloudKit requires $99/year Apple Developer Program |
| **Coordinate scale** | 0.5m - 1.5m from origin | Close enough to see when AR starts |
| **Sphere appearance** | Solid color (red) | Simple, visible, no transparency needed |
| **Text rendering** | Fixed orientation | No billboarding - just render at correct position |
| **Error handling** | Inline message on screen | Show "Unable to retrieve data" or similar message |

---

## Appendix: Test Data Positions

Seed data pattern - 3D cross positioned 1 meter in front of camera at AR session start:

| Label | X | Y | Z | Notes |
|-------|---|---|---|-------|
| "Center" | 0.0 | 0.0 | -1.0 | Directly ahead, 1m away |
| "Left" | -0.3 | 0.0 | -1.0 | 30cm to the left |
| "Right" | 0.3 | 0.0 | -1.0 | 30cm to the right |
| "Up" | 0.0 | 0.3 | -1.0 | 30cm above center |
| "Down" | 0.0 | -0.3 | -1.0 | 30cm below center |
| "Close" | 0.0 | 0.0 | -0.5 | 50cm in front (closer) |
| "Far" | 0.0 | 0.0 | -1.5 | 1.5m away (further) |

**Coordinate System:**
- Units: Meters
- X: Right (+) / Left (-)
- Y: Up (+) / Down (-)
- Z: Behind camera (+) / **In front of camera (-)**

*All test positions are within arm's reach (0.5m - 1.5m) so they're immediately visible when AR starts.*

---

---

## Phase 5: Refresh Validation Test

### US-010: Validate refresh with new annotation
**Description:** As a developer, I want to verify that when a new annotation is added to Supabase (simulating a Vision Pro user creating one), pressing the refresh button updates the AR view with the new annotation.

**Acceptance Criteria:**
- [ ] Add a new test annotation to Supabase (simulating Vision Pro input)
- [ ] Press refresh button in the app
- [ ] New annotation appears in AR view without restarting the app
- [ ] Validates the "live data" workflow for the full system

**Test Annotation:**
| Label | X | Y | Z | Notes |
|-------|---|---|---|-------|
| "NEW!" | 0.5 | 0.5 | -1.0 | Upper-right diagonal, 1m away |

---

## Appendix: Supabase Setup Instructions

1. **Create Supabase Project** (FREE)
   - Go to [supabase.com](https://supabase.com)
   - Create new project (FREE tier: 500MB database, 50k monthly active users)

2. **Run Schema SQL**
   - Go to SQL Editor in Supabase dashboard
   - Copy contents of `Supabase/schema.sql`
   - Run the script (creates table + seed data)

3. **Get Credentials**
   - Go to Project Settings → API
   - Copy `Project URL` and `anon public` key
   - Add to `Services/SupabaseConfig.swift`

4. **Add Swift Package**
   - In Xcode: File → Add Package Dependencies
   - URL: `https://github.com/supabase-community/supabase-swift`
   - Add `Supabase` product to target
