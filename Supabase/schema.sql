-- Honda AVP Lite - Simplified Supabase Schema
-- Version: 1.0 (Lite MVP)
--
-- This is a MINIMAL schema for the proof-of-concept.
-- No authentication, no projects, just annotations.

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- ANNOTATIONS TABLE (Lite version - no auth, no projects)
-- ============================================================================
CREATE TABLE annotations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- 3D Position (in meters)
  position_x FLOAT NOT NULL DEFAULT 0,
  position_y FLOAT NOT NULL DEFAULT 0,
  position_z FLOAT NOT NULL DEFAULT 0,

  -- Text label for the annotation
  text_label TEXT NOT NULL DEFAULT '',

  -- Metadata
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for fetching annotations by creation date
CREATE INDEX idx_annotations_created_at ON annotations(created_at DESC);

-- ============================================================================
-- ROW LEVEL SECURITY - DISABLED FOR LITE MVP
-- ============================================================================
-- For the Lite MVP, we allow public read access (no auth required)
-- In production, you would enable RLS and require authentication

ALTER TABLE annotations ENABLE ROW LEVEL SECURITY;

-- Allow anyone to read annotations (public access for MVP)
CREATE POLICY "Public read access"
  ON annotations FOR SELECT
  USING (true);

-- Allow anyone to insert annotations (for seed script)
CREATE POLICY "Public insert access"
  ON annotations FOR INSERT
  WITH CHECK (true);

-- Allow anyone to delete annotations (for clearing test data)
CREATE POLICY "Public delete access"
  ON annotations FOR DELETE
  USING (true);

-- ============================================================================
-- SEED DATA (Optional - can also be inserted via app)
-- ============================================================================
-- Test data pattern: 3D cross positioned 1 meter in front
-- Coordinate system: X=right, Y=up, Z=forward (negative Z = in front of camera)

INSERT INTO annotations (position_x, position_y, position_z, text_label) VALUES
  (0.0, 0.0, -1.0, 'Center'),
  (-0.3, 0.0, -1.0, 'Left'),
  (0.3, 0.0, -1.0, 'Right'),
  (0.0, 0.3, -1.0, 'Up'),
  (0.0, -0.3, -1.0, 'Down'),
  (0.0, 0.0, -0.5, 'Close'),
  (0.0, 0.0, -1.5, 'Far');
