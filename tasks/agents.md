# AI Agents Guide

This document provides guidance for AI coding agents (Claude, Cursor, Copilot, etc.) working on the Honda AVP Lite codebase.

---

## CRITICAL CONSTRAINTS

### NO PAID DEVELOPER PROGRAMS
- **Apple Developer Program ($99/year)** - NOT AVAILABLE
- This means: NO CloudKit, NO Push Notifications, NO App Groups, NO paid Apple capabilities
- We are using a **free Personal Team** Apple account only

### ALWAYS INCLUDE PRICE TAGS
When suggesting any service, framework, or tool, ALWAYS specify the cost:
- Free tier available? State the limits
- Paid service? State the price
- Example: "Firebase (FREE tier: 1GB storage, 50k reads/day)" or "Heroku ($7/month for hobby dyno)"

### Backend Decision
Due to CloudKit requiring paid Apple Developer Program, we are using **Supabase** instead:
- Supabase FREE tier: 500MB database, 1GB file storage, 50k monthly active users
- This replaces all CloudKit references in the PRD

---

## Agent Roles

### Primary Agent: iOS Implementation Agent

**Purpose:** Implement features according to PRD user stories

**Capabilities:**
- Write Swift/SwiftUI code
- Create and modify CloudKit schemas
- Implement ARKit/RealityKit rendering
- Write unit tests

**Workflow:**
1. Read the relevant user story from `tasks/prd-honda-avp-lite.md`
2. Check acceptance criteria carefully
3. Implement the minimal code to satisfy criteria
4. Verify typecheck passes (`swift build` or Xcode build)
5. Update `tasks/progress.txt` when story is complete

**Boundaries:**
- Do NOT add features not in the PRD
- Do NOT over-engineer or add "nice-to-haves"
- Do NOT modify other user stories' code without explicit instruction
- STOP and ask if requirements are unclear

---

### Secondary Agent: Debug & Test Agent

**Purpose:** Create test data and debug issues

**Capabilities:**
- Write seed data scripts
- Debug CloudKit connectivity issues
- Test AR rendering on device
- Capture and analyze errors

**Workflow:**
1. Identify what needs testing
2. Create minimal reproduction case
3. Isolate the issue
4. Propose fix with explanation

**Boundaries:**
- Do NOT change production code without approval
- Always explain what the bug is before fixing

---

### Review Agent: Code Quality Agent

**Purpose:** Review code for correctness and simplicity

**Checklist:**
- [ ] Does it satisfy the acceptance criteria?
- [ ] Is it the simplest possible implementation?
- [ ] Are there any obvious bugs?
- [ ] Does it follow Swift conventions?
- [ ] Is error handling appropriate?

**Boundaries:**
- Do NOT suggest refactors unless code is broken
- Do NOT enforce style preferences beyond Swift conventions

---

## Coding Guidelines for AI Agents

### General Principles

```
1. MINIMAL: Write the least code that satisfies requirements
2. OBVIOUS: Prefer boring, readable code over clever code
3. FOCUSED: One change at a time, one purpose per function
4. TESTED: Verify typecheck passes before marking complete
```

### Swift/iOS Specific

```swift
// DO: Use simple, explicit types
let position = SIMD3<Float>(x: 1.0, y: 2.0, z: 3.0)

// DON'T: Use unnecessary generics or abstractions
func createVector<T: BinaryFloatingPoint>(...) // Overkill for this project

// DO: Handle errors explicitly
do {
    let records = try await database.fetch(query)
} catch {
    print("CloudKit error: \(error)")
    throw error
}

// DON'T: Silently swallow errors
let records = try? await database.fetch(query) // Where did the error go?

// DO: Use @MainActor for UI-related classes
@MainActor
class ARViewModel: ObservableObject { }

// DON'T: Forget thread safety with async code
```

### CloudKit Specific

```swift
// DO: Use explicit record types
let query = CKQuery(recordType: "Annotation", predicate: NSPredicate(value: true))

// DON'T: Use magic strings scattered throughout code
// Put record type names in constants

// DO: Handle CloudKit-specific errors
if let ckError = error as? CKError {
    switch ckError.code {
    case .networkUnavailable:
        // Handle offline
    case .notAuthenticated:
        // Handle not signed into iCloud
    default:
        // Generic error
    }
}
```

### ARKit/RealityKit Specific

```swift
// DO: Create simple entity hierarchies
let sphere = ModelEntity(mesh: .generateSphere(radius: 0.05))
sphere.position = annotation.position
anchor.addChild(sphere)

// DON'T: Create complex inheritance hierarchies for entities

// DO: Clean up entities when done
entity.removeFromParent()

// DON'T: Leave orphaned entities in the scene
```

---

## File Modification Rules

| File Type | Can Create | Can Modify | Notes |
|-----------|------------|------------|-------|
| `.swift` in `Models/` | Yes | Yes | Keep models simple |
| `.swift` in `Services/` | Yes | Yes | One service per concern |
| `.swift` in `Views/` | Yes | Yes | SwiftUI views only |
| `.swift` in `ViewModels/` | Yes | Yes | ObservableObject pattern |
| `.swift` in `Debug/` | Yes | Yes | Test utilities only |
| `*.md` in `tasks/` | No | Update progress only | Don't modify PRD |
| `Info.plist` | No | Only for capabilities | Ask before changing |
| `*.entitlements` | No | Only for capabilities | Ask before changing |

---

## Past Mistakes & Solutions

> **This section documents common mistakes made during development and their solutions. AI agents should review this before implementing to avoid repeating errors.**

### Mistake #0: Suggesting Paid Services Without Price Tags

**Symptom:** Wasted development time implementing features that require paid services the user cannot access.

**Root Cause:** AI agent suggested CloudKit as the backend without mentioning it requires a $99/year Apple Developer Program membership. User only has a free Personal Team account.

**Solution:**
- Switched backend from CloudKit to Supabase (FREE tier)
- Deleted all CloudKit-related code
- Updated PRD and schema for Supabase

**Prevention:**
1. ALWAYS check if a service/capability requires paid accounts
2. ALWAYS include price tags when suggesting services:
   - "CloudKit (requires $99/year Apple Developer Program)"
   - "Supabase (FREE tier: 500MB, 50k MAU)"
   - "Firebase (FREE tier: 1GB storage, 50k reads/day)"
3. ASK about budget constraints before recommending paid services
4. See "CRITICAL CONSTRAINTS" section at top of this file

---

### Mistake #1: CloudKit Container Not Configured

**Symptom:**
```
Error: CKError 0x... "Not Authenticated" or "Container not found"
```

**Root Cause:** CloudKit container identifier in code doesn't match Xcode capabilities or Apple Developer portal.

**Solution:**
1. Verify container ID in Xcode → Target → Signing & Capabilities → iCloud
2. Ensure CloudKit is checked (not just iCloud Documents)
3. Container format: `iCloud.com.company.appname`
4. Use the SAME container ID in code:
```swift
let container = CKContainer(identifier: "iCloud.com.honda.avplite")
```

**Prevention:** Always verify container ID matches across all three locations before writing CloudKit code.

---

### Mistake #2: ARView Not Rendering Entities

**Symptom:** AR camera works but no spheres/entities appear in scene.

**Root Cause:** Entities added to scene but not anchored, or anchor not added to scene.

**Solution:**
```swift
// WRONG: Entity floating without anchor
arView.scene.addChild(sphereEntity) // Won't render!

// RIGHT: Entity attached to anchor, anchor added to scene
let anchor = AnchorEntity(world: .zero)
anchor.addChild(sphereEntity)
arView.scene.addAnchor(anchor) // Renders correctly
```

**Prevention:** Always follow the pattern: Create Entity → Attach to Anchor → Add Anchor to Scene.

---

### Mistake #3: SwiftData Model Not Syncing with CloudKit

**Symptom:** Local SwiftData works, but data doesn't appear in CloudKit dashboard.

**Root Cause:** SwiftData + CloudKit integration requires specific configuration.

**Solution:**
For this MVP, we're NOT using automatic SwiftData-CloudKit sync. Instead:
- CloudKit is fetched manually via `CKDatabase`
- SwiftData models are populated from CloudKit records manually
- This is intentional for simplicity

**Prevention:** Don't assume automatic sync. This project uses explicit fetch/convert pattern.

---

### Mistake #4: Coordinates Appear in Wrong Position

**Symptom:** Spheres render but are in unexpected positions (too far, underground, behind camera).

**Root Cause:** Coordinate system confusion. ARKit uses meters, Y is up, -Z is forward.

**Solution:**
```swift
// ARKit coordinate system:
// X: right (+) / left (-)
// Y: up (+) / down (-)
// Z: behind camera (+) / in front of camera (-)

// For objects to appear 1 meter in front of camera at session start:
let position = SIMD3<Float>(0, 0, -1.0) // Negative Z!

// For objects at eye level (assuming phone held at ~1.5m):
// Y = 0 is where the phone was when AR started
```

**Prevention:** Test data should use small values (-2 to +2 meters) and negative Z to appear in front.

---

### Mistake #5: Async/Await Crashes on Wrong Thread

**Symptom:** App crashes with "UI API called from background thread" or similar.

**Root Cause:** CloudKit async calls return on background thread, but UI updates need main thread.

**Solution:**
```swift
// WRONG: Direct update after async call
func fetchAndDisplay() async {
    let annotations = try await cloudKit.fetch()
    self.annotations = annotations // Crash! Background thread
}

// RIGHT: Use @MainActor
@MainActor
class ARViewModel: ObservableObject {
    func fetchAndDisplay() async {
        let annotations = try await cloudKit.fetch()
        self.annotations = annotations // Safe! MainActor ensures main thread
    }
}
```

**Prevention:** Always mark ViewModels and Services with `@MainActor` when they update `@Published` properties.

---

### Mistake #6: RealityKit Text Not Visible

**Symptom:** Text entities created but invisible in AR.

**Root Cause:** Text too small, wrong color, or facing wrong direction.

**Solution:**
```swift
// Text needs to be large enough to see in AR (world units = meters)
let textMesh = MeshResource.generateText(
    "Label",
    extrusionDepth: 0.001,
    font: .systemFont(ofSize: 0.05), // 5cm tall text
    containerFrame: .zero,
    alignment: .center,
    lineBreakMode: .byWordWrapping
)

// Use a material with high contrast
let material = SimpleMaterial(color: .white, isMetallic: false)
let textEntity = ModelEntity(mesh: textMesh, materials: [material])

// Position above the sphere
textEntity.position.y += 0.08 // 8cm above sphere center
```

**Prevention:** Test with large text (0.05+ font size) and high-contrast colors first.

---

### Mistake #7: CloudKit Query Returns Empty

**Symptom:** `fetchAnnotations()` returns empty array even when data exists in dashboard.

**Root Cause:** Querying wrong database (public vs private) or wrong environment (development vs production).

**Solution:**
```swift
// Check you're using the right database
let database = container.privateCloudDatabase // NOT publicCloudDatabase

// Check you're in development mode (Xcode scheme)
// CloudKit has separate dev and prod environments

// Check the record type name matches EXACTLY (case-sensitive)
let query = CKQuery(recordType: "Annotation", ...) // Must match dashboard
```

**Prevention:**
1. Use CloudKit Dashboard to verify data exists
2. Check database type (private for this app)
3. Verify Xcode scheme is set to Development

---

### Mistake #8: Entity Materials Look Wrong in AR

**Symptom:** Spheres appear black, shiny, or wrong color in AR.

**Root Cause:** Using wrong material type or lighting not configured.

**Solution:**
```swift
// For solid colors that ignore lighting, use UnlitMaterial
let material = UnlitMaterial(color: .red)

// For realistic materials that respond to light, use SimpleMaterial
let material = SimpleMaterial(color: .red, isMetallic: false)

// Metallic materials need environment lighting to look correct
// For MVP, prefer UnlitMaterial - it always looks as expected
```

**Prevention:** Start with `UnlitMaterial` for predictable colors, upgrade to `SimpleMaterial` later if needed.

---

## Adding New Mistakes

When you encounter a new mistake during development:

1. Document the **symptom** (what you observed)
2. Document the **root cause** (why it happened)
3. Document the **solution** (exact code/config fix)
4. Document **prevention** (how to avoid next time)
5. Add to this file with the next number

Format:
```markdown
### Mistake #N: Short Title

**Symptom:** What you see/error message

**Root Cause:** Why this happened

**Solution:**
```code fix here```

**Prevention:** How to avoid this in the future
```

---

## Context for This Project

**What this app does:**
- Fetches spatial annotation data from CloudKit
- Renders simple spheres + text labels in AR at those positions
- No calibration (renders at world origin)
- Manual refresh only (no real-time sync)

**What this app does NOT do:**
- No login/auth UI (uses iCloud automatically)
- No annotation creation (read-only)
- No stroke/line rendering (spheres only for MVP)
- No project management (flat list)

**Key files to understand:**
- `tasks/prd-honda-avp-lite.md` - Full requirements
- `tasks/progress.txt` - Current implementation status
- `Models/Annotation.swift` - Data model
- `Services/CloudKitService.swift` - Data fetching
- `ViewModels/ARViewModel.swift` - Rendering logic
- `Views/ARViewerView.swift` - UI

---

## Checklist Before Submitting Code

```
[ ] Code compiles without errors
[ ] Code compiles without warnings (or warnings are explained)
[ ] Only changed files related to the current user story
[ ] No debug print statements left in (or marked clearly)
[ ] Error handling is appropriate (not swallowed silently)
[ ] @MainActor used where needed for UI updates
[ ] Tested on physical device if AR-related
[ ] Updated progress.txt if story is complete
```
