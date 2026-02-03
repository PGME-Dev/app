# Theory Package Module - API Specification

## Overview
The Theory Package Module allows users to browse series within a theory package, view detailed series information, access lectures (modules and videos), and view/download notes and documents.

**Base URL:** `/api/v1`

**Authentication:** Most endpoints are public, but authentication is optional for tracking user progress and library status.

---

## Endpoints

### 1. Get Package Series

Retrieve all series included in a theory package.

**Endpoint:** `GET /packages/:package_id/series`

**Headers:**
```
Content-Type: application/json
```

**URL Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| package_id | string | Yes | MongoDB ObjectId of the package |

**Success Response (200 OK):**
```json
{
  "success": true,
  "message": "Package series retrieved successfully",
  "data": {
    "series": [
      {
        "series_id": "6979e234a123bc45de678901",
        "name": "TECOM Revision Series I",
        "description": "Comprehensive revision series covering key topics for TECOM exams",
        "display_order": 1,
        "module_count": 5,
        "total_videos": 24,
        "total_documents": 8
      },
      {
        "series_id": "6979e234a123bc45de678902",
        "name": "Advanced Topics Series",
        "description": "Deep dive into advanced forensic medicine topics",
        "display_order": 2,
        "module_count": 3,
        "total_videos": 15,
        "total_documents": 12
      }
    ]
  }
}
```

**Response Field Descriptions:**
| Field | Type | Description |
|-------|------|-------------|
| series_id | string | Unique identifier for the series |
| name | string | Series title |
| description | string | Series description |
| display_order | number | Order to display series (1, 2, 3...) |
| module_count | number | Number of modules in series |
| total_videos | number | Total video lectures in series |
| total_documents | number | Total documents/notes in series |

**Error Responses:**

404 Not Found:
```json
{
  "success": false,
  "message": "Package not found"
}
```

**Implementation Notes:**
- This endpoint is public (no authentication required)
- Returns only active series
- Series are sorted by `display_order`
- `total_documents` represents the number of PDF notes/handouts available
- Use `total_videos` to show "X Lectures" badge

---

### 2. Get Series Details

Retrieve detailed information about a specific series.

**Endpoint:** `GET /series/:series_id`

**Headers:**
```
Content-Type: application/json
```

**URL Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| series_id | string | Yes | MongoDB ObjectId of the series |

**Success Response (200 OK):**
```json
{
  "success": true,
  "message": "Series details retrieved successfully",
  "data": {
    "series_id": "6979e234a123bc45de678901",
    "package_id": "697739396ceba945fe76690a",
    "name": "TECOM Revision Series I",
    "description": "Comprehensive revision series covering key topics for TECOM exams. This series includes detailed lectures on all major subjects with expert faculty guidance.",
    "module_count": 5,
    "total_pages": 48,
    "created_at": "2026-01-21T00:00:00.000Z"
  }
}
```

**Response Field Descriptions:**
| Field | Type | Description |
|-------|------|-------------|
| series_id | string | Unique identifier for the series |
| package_id | string | ID of the parent package |
| name | string | Series title |
| description | string | Full series description |
| module_count | number | Number of modules in series |
| total_pages | number | Sum of all document page counts |
| created_at | string | Series creation date (ISO 8601) |

**Error Responses:**

404 Not Found:
```json
{
  "success": false,
  "message": "Series not found"
}
```

**Implementation Notes:**
- This endpoint is public (no authentication required)
- Returns 404 if series is not active
- `total_pages` is calculated from all documents in the series
- Use this data to populate the series detail header

---

### 3. Get Series Modules

Retrieve all modules (with videos) for a series, including progress tracking for authenticated users.

**Endpoint:** `GET /series/:series_id/modules`

**Headers:**
```
Authorization: Bearer <access_token>  (optional)
Content-Type: application/json
```

**URL Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| series_id | string | Yes | MongoDB ObjectId of the series |

**Success Response (200 OK):**
```json
{
  "success": true,
  "message": "Series modules retrieved successfully",
  "data": {
    "modules": [
      {
        "module_id": "6979f123b234cd56ef789012",
        "name": "Introduction to Forensic Medicine",
        "description": "Fundamental concepts and principles",
        "display_order": 1,
        "lesson_count": 5,
        "completed_lessons": 2,
        "estimated_duration_minutes": 180,
        "videos": [
          {
            "video_id": "6979f456c345de67fg890123",
            "title": "What is Forensic Medicine?",
            "duration_seconds": 1800,
            "faculty_name": "Dr. Rajesh Kumar",
            "is_completed": true,
            "is_locked": false
          },
          {
            "video_id": "6979f456c345de67fg890124",
            "title": "Legal Aspects of Medical Practice",
            "duration_seconds": 2100,
            "faculty_name": "Dr. Rajesh Kumar",
            "is_completed": true,
            "is_locked": false
          },
          {
            "video_id": "6979f456c345de67fg890125",
            "title": "Medical Ethics and Law",
            "duration_seconds": 1500,
            "faculty_name": "Dr. Priya Sharma",
            "is_completed": false,
            "is_locked": false
          }
        ]
      },
      {
        "module_id": "6979f123b234cd56ef789013",
        "name": "Thanatology",
        "description": "Study of death and post-mortem changes",
        "display_order": 2,
        "lesson_count": 4,
        "completed_lessons": 0,
        "estimated_duration_minutes": 150,
        "videos": [
          {
            "video_id": "6979f456c345de67fg890126",
            "title": "Definition and Types of Death",
            "duration_seconds": 1200,
            "faculty_name": "Dr. Anjali Mehta",
            "is_completed": false,
            "is_locked": true
          }
        ]
      }
    ]
  }
}
```

**Response Field Descriptions:**

**Module Fields:**
| Field | Type | Description |
|-------|------|-------------|
| module_id | string | Unique identifier for the module |
| name | string | Module title |
| description | string | Module description |
| display_order | number | Order to display (1, 2, 3...) |
| lesson_count | number | Total videos in module |
| completed_lessons | number | Videos marked as completed (0 if not authenticated) |
| estimated_duration_minutes | number | Total duration of all videos |
| videos | array | Array of video objects |

**Video Fields:**
| Field | Type | Description |
|-------|------|-------------|
| video_id | string | Unique identifier for the video |
| title | string | Video title |
| duration_seconds | number | Video duration in seconds |
| faculty_name | string | Name of the faculty teaching |
| is_completed | boolean | Whether user completed this video (false if not authenticated) |
| is_locked | boolean | Whether video is locked for the user |

**Error Responses:**

404 Not Found:
```json
{
  "success": false,
  "message": "Series not found"
}
```

**Implementation Notes:**
- Authentication is optional via `optionalAuth` middleware
- If authenticated, includes user progress (`is_completed`, `completed_lessons`)
- If not authenticated, `is_completed` and `completed_lessons` will be false/0
- `is_locked` is true if:
  - User is not enrolled in the package AND
  - Video is not marked as free (`is_free: false`)
- `estimated_duration_minutes` is pre-calculated for the module
- Videos are sorted by `display_order` within each module
- Modules are sorted by `display_order`
- Use this to populate the "Watch Lectures" section

---

### 4. Get Series Documents

Retrieve all documents (PDFs, notes, handouts) for a series.

**Endpoint:** `GET /series/:series_id/documents`

**Headers:**
```
Authorization: Bearer <access_token>  (optional)
Content-Type: application/json
```

**URL Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| series_id | string | Yes | MongoDB ObjectId of the series |

**Success Response (200 OK):**
```json
{
  "success": true,
  "message": "Series documents retrieved successfully",
  "data": {
    "documents": [
      {
        "document_id": "6979g567d456ef78gh901234",
        "title": "Forensic Medicine Lecture Notes - Part 1",
        "description": "Comprehensive notes covering introduction and thanatology",
        "file_url": "https://storage.pgme.app/documents/forensic-notes-1.pdf",
        "file_format": "PDF",
        "file_size_mb": 2.5,
        "page_count": 24,
        "is_free": false,
        "is_in_library": true
      },
      {
        "document_id": "6979g567d456ef78gh901235",
        "title": "Quick Reference Guide - Forensic Medicine",
        "description": "One-page quick reference for key concepts",
        "file_url": "https://storage.pgme.app/documents/forensic-quick-ref.pdf",
        "file_format": "PDF",
        "file_size_mb": 0.3,
        "page_count": 1,
        "is_free": true,
        "is_in_library": false
      }
    ]
  }
}
```

**Response Field Descriptions:**
| Field | Type | Description |
|-------|------|-------------|
| document_id | string | Unique identifier for the document |
| title | string | Document title |
| description | string | Document description |
| file_url | string | Direct URL to download/view the document |
| file_format | string | File format (PDF, DOCX, etc.) |
| file_size_mb | number | File size in megabytes (rounded to 1 decimal) |
| page_count | number | Number of pages in document |
| is_free | boolean | Whether document is freely accessible |
| is_in_library | boolean | Whether user has saved to library (false if not authenticated) |

**Error Responses:**

404 Not Found:
```json
{
  "success": false,
  "message": "Series not found"
}
```

**Implementation Notes:**
- Authentication is optional via `optionalAuth` middleware
- If authenticated, `is_in_library` indicates if user has saved this document
- If not authenticated, `is_in_library` will always be false
- Documents are sorted by `display_order`
- Use `file_url` to open/download the document
- Show lock icon if `is_free: false` and user not enrolled
- Use this to populate the "View Notes" section

---

## Screen-by-Screen Breakdown

### Screen 1: Theory Packages List (Series List)

**Purpose:** Display all series available in the purchased theory package

**API Calls:**
1. `GET /packages/:package_id/series` - Get all series in package

**Data Mapping:**
- Series card:
  - Title → `series.name`
  - Description → `series.description`
  - Page count → `series.total_documents` (show as "X Pages" or "X Documents")
  - Date → Use `series.created_at` if available from package purchase

**UI Flow:**
- Display series sorted by `display_order`
- Show module count: `series.module_count` modules
- Show video count: `series.total_videos` lectures
- Tap card → Navigate to Series Detail with `series_id`

**Search Implementation:**
- Filter series list locally by `series.name` or `series.description`
- No API call needed for search

**Sorting Options:**
- By display order (default): Use `display_order` field
- By name: Sort locally by `name` alphabetically
- By date: Sort locally by `created_at` if available

---

### Screen 2: Theory Series Detail

**Purpose:** Show series details with quick access to lectures and notes

**API Calls:**
1. `GET /series/:series_id` - Get series details
2. `GET /series/:series_id/modules` - Get modules and videos (pre-load for "Watch Lectures")
3. `GET /series/:series_id/documents` - Get documents (pre-load for "View Notes")

**Data Mapping:**

**Series Header:**
- Title → `series.name`
- Description → `series.description`
- Module count → `series.module_count`
- Page count → `series.total_pages`

**Quick Access Cards:**

*"Watch Lectures" Card:*
- Shows module count from `series.module_count`
- Shows total video count from modules response
- Button action → Navigate to Module List or Video Player

*"View Notes" Card:*
- Shows document count from documents response
- Shows total pages from `series.total_pages`
- Button action → Navigate to Documents List

**Details/Inclusions Section:**
- Display `series.description` (full text)
- Show created date: `series.created_at`
- Show module count: `series.module_count`
- Show total pages: `series.total_pages`

---

### Screen 3: Module List / Lectures List

**Purpose:** Display all modules and their videos for watching

**API Calls:**
1. `GET /series/:series_id/modules` - Get modules with videos and progress

**Data Mapping:**

**Module Accordion/Section:**
- Module title → `module.name`
- Module description → `module.description`
- Lesson count → `module.lesson_count` lectures
- Duration → `module.estimated_duration_minutes` (format: "X hrs Y mins")
- Progress → `module.completed_lessons / module.lesson_count` (e.g., "2/5 completed")

**Video List Item:**
- Video title → `video.title`
- Faculty name → `video.faculty_name`
- Duration → `video.duration_seconds` (format: "MM:SS" or "HH:MM:SS")
- Completion status → `video.is_completed` (show checkmark if true)
- Lock status → `video.is_locked` (show lock icon if true)

**UI Behavior:**
- Show completed videos with green checkmark
- Show locked videos with lock icon (prevent tap)
- Tap unlocked video → Navigate to Video Player with `video_id`
- Expand/collapse modules by tapping module header

**Progress Display:**
- Show circular progress or linear progress bar for each module
- Calculate: `(completed_lessons / lesson_count) * 100`

---

### Screen 4: Documents List / View Notes

**Purpose:** Display all documents/notes available for the series

**API Calls:**
1. `GET /series/:series_id/documents` - Get all documents

**Data Mapping:**

**Document Card:**
- Title → `document.title`
- Description → `document.description`
- File format → `document.file_format` (show badge: "PDF", "DOCX")
- File size → `document.file_size_mb` (format: "X.Y MB")
- Page count → `document.page_count` (show as "X pages")
- Free indicator → `document.is_free` (show "Free" badge if true)
- Library status → `document.is_in_library` (show "In Library" or "Add to Library")

**UI Actions:**
- Tap document → Open PDF viewer or download (use `document.file_url`)
- Tap "Add to Library" → Call `POST /users/library` (from Enrolled Courses module)
- Show lock icon if `is_free: false` and user not enrolled

**Filtering (Optional):**
- All documents (default)
- Free only: Filter `is_free === true`
- In Library: Filter `is_in_library === true`

---

## Integration with Other Modules

### Connection to Enrolled Courses Module

**From Package Details (Enrolled Courses) → Theory Packages List:**
```
User taps on Theory Package in Enrolled Courses
↓
Navigate to Theory Packages List with package_id
↓
Call GET /packages/:package_id/series
```

**From Series List → Series Detail:**
```
User taps on Series Card
↓
Navigate to Series Detail with series_id
↓
Call GET /series/:series_id
```

### Connection to Video Player

**From Module List → Video Player:**
```
User taps on Video in Module
↓
Navigate to Video Player with video_id
↓
Video Player module handles playback and progress tracking
```

### Connection to Library Module

**Add Document to Library:**
```
User taps "Add to Library" on Document
↓
Call POST /users/library (from Enrolled Courses module)
Body: {
  document_id: "<document_id>",
  series_id: "<series_id>"
}
```

---

## Common Patterns

### Optional Authentication

Several endpoints support optional authentication:
- If user is authenticated → Include JWT token in `Authorization` header
- If user is not authenticated → Omit `Authorization` header

**Benefits of Authentication:**
- Progress tracking (`is_completed`, `completed_lessons`)
- Library status (`is_in_library`)
- Locked content detection (based on enrollment)

**Example:**
```javascript
// Authenticated request
headers: {
  'Authorization': 'Bearer <token>',
  'Content-Type': 'application/json'
}

// Unauthenticated request
headers: {
  'Content-Type': 'application/json'
}
```

### Error Handling

All endpoints return consistent error format:
```json
{
  "success": false,
  "message": "Error description"
}
```

**Common Error Codes:**
- 400: Bad Request → Invalid parameters
- 404: Not Found → Series/Package doesn't exist or is inactive
- 500: Server Error → Show generic error message

### Locked Content

**Video Lock Logic:**
- Video is locked if: `is_locked === true`
- Locked videos should show lock icon
- Prevent navigation to locked videos
- Show upgrade/purchase prompt if user taps locked content

**Document Lock Logic:**
- Document is locked if: `is_free === false` AND user not enrolled
- Locked documents should show lock icon
- Allow preview of first page (optional)
- Show upgrade/purchase prompt if user taps locked content

### Duration Formatting

**Seconds to Time Format:**
```javascript
// For videos (duration_seconds)
function formatDuration(seconds) {
  const hours = Math.floor(seconds / 3600);
  const minutes = Math.floor((seconds % 3600) / 60);
  const secs = seconds % 60;

  if (hours > 0) {
    return `${hours}:${padZero(minutes)}:${padZero(secs)}`;
  }
  return `${minutes}:${padZero(secs)}`;
}

// For modules (estimated_duration_minutes)
function formatModuleDuration(minutes) {
  const hours = Math.floor(minutes / 60);
  const mins = minutes % 60;

  if (hours > 0) {
    return `${hours} hr${hours > 1 ? 's' : ''} ${mins} min${mins !== 1 ? 's' : ''}`;
  }
  return `${mins} min${mins !== 1 ? 's' : ''}`;
}
```

---

## Integration Checklist

### Theory Packages List Screen
- [ ] Fetch series for package
- [ ] Display series cards with counts
- [ ] Implement local search
- [ ] Handle tap navigation to series detail
- [ ] Show loading state
- [ ] Handle empty state (no series)

### Theory Series Detail Screen
- [ ] Fetch series details
- [ ] Pre-fetch modules (for Watch Lectures)
- [ ] Pre-fetch documents (for View Notes)
- [ ] Display quick access cards
- [ ] Handle navigation to modules list
- [ ] Handle navigation to documents list
- [ ] Show series description

### Module List Screen
- [ ] Fetch modules with videos
- [ ] Display module accordions
- [ ] Show progress for each module
- [ ] Display video list with statuses
- [ ] Handle locked videos (prevent access)
- [ ] Show completion checkmarks
- [ ] Navigate to video player
- [ ] Calculate and display progress

### Documents List Screen
- [ ] Fetch documents for series
- [ ] Display document cards
- [ ] Show file size and page count
- [ ] Handle locked documents
- [ ] Implement add to library
- [ ] Open document viewer
- [ ] Show library status
- [ ] Handle free vs paid documents

### General
- [ ] Handle optional authentication
- [ ] Implement error handling
- [ ] Show loading states
- [ ] Format durations correctly
- [ ] Handle locked content
- [ ] Implement deep linking
- [ ] Cache data appropriately

---

## Notes

1. **Optional Authentication:** Most endpoints work without authentication but provide enhanced features when authenticated
2. **Locked Content:** Videos and documents can be locked based on enrollment status
3. **Progress Tracking:** Only available for authenticated users with active enrollment
4. **Display Order:** Always respect `display_order` field for sorting
5. **Module Counts:** Pre-calculated for performance (no need to count manually)
6. **File URLs:** Direct download/view URLs provided in document responses
7. **Free Content:** Some videos and documents may be marked as free for preview
8. **Library Integration:** Use Enrolled Courses Module APIs for library management

---

## API Quick Reference

| Screen | Endpoint | Method | Auth | Purpose |
|--------|----------|--------|------|---------|
| Series List | `/packages/:package_id/series` | GET | No | Get all series |
| Series Detail | `/series/:series_id` | GET | No | Get series info |
| Module List | `/series/:series_id/modules` | GET | Optional | Get modules + videos |
| Documents List | `/series/:series_id/documents` | GET | Optional | Get documents |

---

**Last Updated:** 2026-02-02
**API Version:** v1
