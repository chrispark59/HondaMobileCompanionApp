# Honda AVP Mobile Companion App

A mobile iOS companion app that enables Honda engineers and designers to **view spatial annotations** created on Apple Vision Pro using the Logitech Muse stylus.

## Features

- **View Spatial Annotations**: See 3D annotations overlaid on car models using ARKit
- **Real-time Sync**: Annotations appear within 1 second of creation on Vision Pro
- **Project-based Access**: Browse projects you're invited to with secure authentication
- **Author Filtering**: Filter annotations by team member
- **Offline Support**: Cached data for offline viewing
- **Manual Coordinate Alignment**: Align AR space with reference point on vehicle

## Requirements

- iOS 17.0+
- iPhone 12+ or iPad Pro (LiDAR preferred but not required)
- Xcode 15.0+
- Swift 5.9+

## Setup

### 1. Install Dependencies

This project uses Swift Package Manager for dependencies. The main dependency is the Supabase Swift SDK.

### 2. Generate Xcode Project

Using XcodeGen (recommended):

```bash
# Install XcodeGen if not already installed
brew install xcodegen

# Generate the Xcode project
cd HondaAVP
xcodegen generate
```

Or manually create an Xcode project and add the files.

### 3. Configure Supabase

1. Create a Supabase project at [supabase.com](https://supabase.com)
2. Run the schema in `Supabase/schema.sql` in the Supabase SQL editor
3. Update `HondaAVP/Services/SupabaseClient.swift` with your credentials:

```swift
enum AppConfiguration {
    static let supabaseURL = "https://your-project-ref.supabase.co"
    static let supabaseAnonKey = "your-anon-key-here"
}
```

### 4. Enable Realtime

In Supabase Dashboard:
1. Go to Database → Replication
2. Enable realtime for the `annotations` table

### 5. Build and Run

1. Open `HondaAVP.xcodeproj` (or `HondaAVP.xcworkspace` if generated)
2. Select your development team in Signing & Capabilities
3. Build and run on a physical device (AR requires a real device)

## Project Structure

```
HondaAVP/
├── HondaAVP/
│   ├── Models/
│   │   ├── Project.swift       # Project data model
│   │   ├── User.swift          # User profile model
│   │   └── Annotation.swift    # Annotation with stroke data
│   ├── Views/
│   │   ├── Auth/
│   │   │   ├── LoginView.swift
│   │   │   ├── SignUpView.swift
│   │   │   └── ForgotPasswordView.swift
│   │   ├── Projects/
│   │   │   ├── ProjectListView.swift
│   │   │   ├── ProjectDetailView.swift
│   │   │   └── SettingsView.swift
│   │   └── AR/
│   │       └── ARViewerView.swift
│   ├── ViewModels/
│   │   └── ARViewModel.swift   # AR rendering logic
│   ├── Services/
│   │   ├── SupabaseClient.swift
│   │   ├── AuthService.swift
│   │   ├── ProjectService.swift
│   │   ├── AnnotationService.swift
│   │   └── CacheService.swift
│   ├── HondaAVPApp.swift       # App entry point
│   └── Info.plist
├── Supabase/
│   └── schema.sql              # Database schema
├── project.yml                  # XcodeGen configuration
└── Package.swift               # Swift Package Manager
```

## Database Schema

### Tables

- **projects**: Car model projects with metadata
- **users**: User profiles synced with Supabase Auth
- **project_members**: Access control (viewer, annotator, admin)
- **annotations**: Spatial annotations with stroke data

### Row Level Security

All tables have RLS policies that restrict access based on project membership. Users can only see data for projects they're members of.

## AR Coordinate Alignment

Since the iPhone's ARKit and Apple Vision Pro have independent coordinate systems, users must manually align them:

1. Open AR view for a project
2. Tap on the documented reference point (e.g., "front-left wheel center")
3. App calculates offset to align all annotations correctly
4. Re-calibrate anytime using the recalibrate button

## Real-time Updates

The app subscribes to Supabase Realtime channels for live annotation updates:

```swift
// Subscribes to INSERT, UPDATE, DELETE events
await annotationService.subscribe(projectId: project.id)
```

New annotations from Vision Pro appear within ~1 second.

## Key Constraints

- **Read-only on mobile**: Users can VIEW but cannot CREATE or EDIT annotations
- **No annotation creation**: All annotation creation happens on Apple Vision Pro with Muse stylus
- **Manual calibration**: No automatic car model detection; users select projects manually

## Security Notes

- Supabase credentials should be stored securely in production
- Consider using environment variables or a secure configuration service
- The anon key is safe for client-side use due to RLS policies
- All data access is controlled by project membership

## Troubleshooting

### AR Not Working
- Ensure you're running on a physical device (not simulator)
- Check camera permissions in Settings
- Try moving to a well-lit area with visual features

### Sync Not Working
- Check network connectivity
- Verify Supabase realtime is enabled for annotations table
- Check browser console in Supabase for connection issues

### Annotations Misaligned
- Recalibrate using the reference point
- Ensure you're tapping the correct reference point on the vehicle
- Check that the AVP app is using the same reference point

## License

Proprietary - Honda Motor Co., Ltd.
