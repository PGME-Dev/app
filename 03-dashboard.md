# Dashboard Module API Documentation

**Version:** v1
**Base URL:** `/api/v1`
**Last Updated:** February 2, 2026

---

## Table of Contents
- [Overview](#overview)
- [Dashboard Layout](#dashboard-layout)
- [API Endpoints](#api-endpoints)
  - [3.1 Get User Subject Selections](#31-get-user-subject-selections)
  - [3.2 Get Next Upcoming Live Session](#32-get-next-upcoming-live-session)
  - [3.3 Get Live Sessions](#33-get-live-sessions)
  - [3.4 Get Live Session Details](#34-get-live-session-details)
  - [3.5 Get Packages by Subject](#35-get-packages-by-subject)
  - [3.6 Get Last Watched Videos](#36-get-last-watched-videos)
  - [3.7 Get Faculty List](#37-get-faculty-list)
  - [3.8 Get Faculty Details](#38-get-faculty-details)
- [Frontend Integration Guide](#frontend-integration-guide)

---

## Overview

The Dashboard is the main home screen of the app after user completes onboarding. It displays personalized content based on:
- User's selected subject
- Active purchases (enrolled vs non-enrolled users)
- Progress history
- Upcoming live sessions
- Available faculty

**All Dashboard APIs require authentication** (Bearer token in Authorization header).

---

## Dashboard Layout

```
┌─────────────────────────────────┐
│  Dashboard Header               │
│  - Hello, [Name]!               │
│  - WhatsApp Support Button      │
└─────────────────────────────────┘
┌─────────────────────────────────┐
│  Live Class Banner              │  ← GET /live-sessions/next-upcoming
│  - Show if upcoming session     │
└─────────────────────────────────┘
┌─────────────────────────────────┐
│  Subject Section                │  ← GET /users/subject-selections
│  - Primary Subject Chip         │
│  - Browse All                   │
└─────────────────────────────────┘
┌─────────────────────────────────┐
│  What We Offer (New Users)      │  ← GET /packages
│  OR                             │
│  For You (Enrolled Users)       │  ← GET /users/progress/last-watched
└─────────────────────────────────┘
┌─────────────────────────────────┐
│  Your Faculty                   │  ← GET /faculty
│  - Horizontal List              │
└─────────────────────────────────┘
┌─────────────────────────────────┐
│  Bottom Navigation              │  (Local State)
└─────────────────────────────────┘
```

---

## API Endpoints

### 3.1 Get User Subject Selections

**Purpose:** Retrieve user's selected subjects, especially the primary subject for dashboard display.

#### Endpoint
```
GET /api/v1/users/subject-selections
```

#### Authentication
**Required:** Yes (Bearer token)

#### Request Headers
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

#### Query Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| is_primary | string | Optional | Filter by primary subject. Use "true" to get only primary subject |

#### Success Response
**Status Code:** `200 OK`

```json
{
  "success": true,
  "message": "Subject selections retrieved successfully",
  "data": {
    "selections": [
      {
        "selection_id": "679...",
        "subject_id": "60d5ec49f1b2c72b8c8e4a1a",
        "subject_name": "Community Medicine",
        "subject_description": "Study of community health and preventive medicine",
        "subject_icon_url": "https://cdn.pgme.com/subjects/community-medicine.png",
        "is_primary": true,
        "selected_at": "2026-01-15T10:30:00.000Z"
      }
    ]
  }
}
```

#### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| selection_id | string | Unique selection identifier |
| subject_id | string | Subject ID (MongoDB ObjectId) |
| subject_name | string | Subject name for display |
| subject_description | string | Subject description |
| subject_icon_url | string/null | URL to subject icon |
| is_primary | boolean | Whether this is the primary subject |
| selected_at | string | ISO timestamp of selection |

#### Error Responses

##### Unauthorized
**Status Code:** `401 Unauthorized`
```json
{
  "success": false,
  "message": "Access token has expired"
}
```

#### Important Notes for Frontend

1. **Dashboard Subject Display:** Use `is_primary=true` query parameter to get only the primary subject
2. **Subject Chip:** Display the primary subject name in the subject section
3. **Empty Response:** If selections array is empty, show default message or redirect to subject selection
4. **Subject Icon:** Use subject_icon_url if available, otherwise show placeholder

#### Example API Call
```
GET /api/v1/users/subject-selections?is_primary=true
Authorization: Bearer <token>
```

---

### 3.2 Get Next Upcoming Live Session

**Purpose:** Get the next upcoming live session to display in the Live Class Banner.

#### Endpoint
```
GET /api/v1/live-sessions/next-upcoming
```

#### Authentication
**Required:** No (Public endpoint, but can use optional auth for personalization)

#### Request Headers
```
Content-Type: application/json
Authorization: Bearer <access_token> (optional)
```

#### Query Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| subject_id | string | Optional | Filter by subject ID to get subject-specific sessions |

#### Success Response (Session Found)
**Status Code:** `200 OK`

```json
{
  "success": true,
  "message": "Next upcoming session retrieved successfully",
  "data": {
    "session": {
      "session_id": "6980c7...",
      "title": "Community Medicine - Epidemiology Basics",
      "description": "Comprehensive session covering epidemiology fundamentals",
      "subject_id": "60d5ec...",
      "subject_name": "Community Medicine",
      "faculty_id": "6980c7...",
      "faculty_name": "Dr. Rajesh Kumar",
      "faculty_photo_url": "https://i.pravatar.cc/150?img=12",
      "faculty_specialization": "Community Medicine",
      "scheduled_start_time": "2026-02-02T14:00:00.000Z",
      "scheduled_end_time": "2026-02-02T15:00:00.000Z",
      "duration_minutes": 60,
      "meeting_link": "https://zoom.us/j/123456789",
      "platform": "zoom",
      "status": "scheduled",
      "max_attendees": 100,
      "thumbnail_url": "https://picsum.photos/seed/live1/400/225",
      "createdAt": "2026-02-01T10:00:00.000Z"
    }
  }
}
```

#### Success Response (No Session Found)
**Status Code:** `200 OK`

```json
{
  "success": true,
  "message": "No upcoming live sessions",
  "data": {
    "session": null
  }
}
```

#### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| session_id | string | Unique session identifier |
| title | string | Session title |
| description | string | Session description |
| subject_id | string | Subject ID |
| subject_name | string | Subject name |
| faculty_id | string/null | Faculty ID |
| faculty_name | string/null | Faculty name |
| faculty_photo_url | string/null | Faculty photo URL |
| faculty_specialization | string/null | Faculty specialization |
| scheduled_start_time | string | ISO timestamp of start time |
| scheduled_end_time | string | ISO timestamp of end time |
| duration_minutes | number | Session duration in minutes |
| meeting_link | string/null | Meeting URL (Zoom, etc.) |
| platform | string | Platform: "zoom", "agora", "teams", "other" |
| status | string | Status: "scheduled", "live", "completed", "cancelled" |
| max_attendees | number/null | Maximum attendees allowed |
| thumbnail_url | string/null | Session thumbnail image |
| createdAt | string | ISO timestamp of creation |

#### Important Notes for Frontend

1. **Display Logic:** If `session` is null, hide the Live Class Banner completely
2. **Status Display:**
   - If `status === "live"`: Show "Join Now" button (green)
   - If `status === "scheduled"`: Show "Join Live" button (disabled until 10 min before)
3. **Countdown Timer:** Calculate time remaining until `scheduled_start_time`
4. **Join Button Logic:** Enable "Join Live" button 10 minutes before scheduled_start_time
5. **Meeting Link:** Use `meeting_link` to open the live session (external browser or in-app webview)
6. **Timing Display:** Format scheduled_start_time as "Starts Today - 7:00 PM" or relative time

---

### 3.3 Get Live Sessions

**Purpose:** Get a list of live sessions with filters (for browsing all sessions).

#### Endpoint
```
GET /api/v1/live-sessions
```

#### Authentication
**Required:** No (Public endpoint)

#### Query Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| status | string | Optional | Filter by status: "scheduled", "live", "completed", "cancelled", "upcoming" |
| subject_id | string | Optional | Filter by subject ID |
| limit | number | Optional | Number of results (1-100), default: 10 |
| upcoming_only | boolean | Optional | If true, show only future sessions |

#### Success Response
**Status Code:** `200 OK`

```json
{
  "success": true,
  "message": "Live sessions retrieved successfully",
  "data": {
    "sessions": [
      {
        "session_id": "6980c7...",
        "title": "Community Medicine - Epidemiology Basics",
        "description": "Comprehensive session covering fundamentals",
        "subject_id": "60d5ec...",
        "subject_name": "Community Medicine",
        "faculty_id": "6980c7...",
        "faculty_name": "Dr. Rajesh Kumar",
        "faculty_photo_url": "https://i.pravatar.cc/150?img=12",
        "faculty_specialization": "Community Medicine",
        "scheduled_start_time": "2026-02-02T14:00:00.000Z",
        "scheduled_end_time": "2026-02-02T15:00:00.000Z",
        "duration_minutes": 60,
        "meeting_link": "https://zoom.us/j/123456789",
        "platform": "zoom",
        "status": "scheduled",
        "max_attendees": 100,
        "thumbnail_url": "https://picsum.photos/seed/live1/400/225",
        "createdAt": "2026-02-01T10:00:00.000Z"
      }
    ]
  }
}
```

#### Important Notes for Frontend

1. **Browse All Sessions:** Use this endpoint when user taps "View All" on Live Class Banner
2. **Filter Options:** Allow users to filter by subject or status
3. **Sorting:** Sessions are sorted by scheduled_start_time (ascending)
4. **Empty State:** Show "No live sessions available" if sessions array is empty

---

### 3.4 Get Live Session Details

**Purpose:** Get detailed information about a specific live session.

#### Endpoint
```
GET /api/v1/live-sessions/:session_id
```

#### Authentication
**Required:** No (Public endpoint)

#### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| session_id | string | Yes | Session ID (MongoDB ObjectId) |

#### Success Response
**Status Code:** `200 OK`

```json
{
  "success": true,
  "message": "Live session retrieved successfully",
  "data": {
    "session": {
      "session_id": "6980c7...",
      "title": "Community Medicine - Epidemiology Basics",
      "description": "Comprehensive session covering epidemiology fundamentals and applications in public health",
      "subject": {
        "subject_id": "60d5ec...",
        "name": "Community Medicine",
        "description": "Study of community health",
        "icon_url": "https://cdn.pgme.com/subjects/community-medicine.png"
      },
      "faculty": {
        "faculty_id": "6980c7...",
        "name": "Dr. Rajesh Kumar",
        "photo_url": "https://i.pravatar.cc/150?img=12",
        "specialization": "Community Medicine",
        "bio": "Senior faculty with 15 years of experience",
        "qualifications": "MD, DNB, PGDHHM",
        "experience_years": 15
      },
      "scheduled_start_time": "2026-02-02T14:00:00.000Z",
      "scheduled_end_time": "2026-02-02T15:00:00.000Z",
      "duration_minutes": 60,
      "meeting_link": "https://zoom.us/j/123456789",
      "platform": "zoom",
      "status": "scheduled",
      "max_attendees": 100,
      "thumbnail_url": "https://picsum.photos/seed/live1/400/225",
      "createdAt": "2026-02-01T10:00:00.000Z",
      "updatedAt": "2026-02-01T10:00:00.000Z"
    }
  }
}
```

#### Error Responses

##### Session Not Found
**Status Code:** `404 Not Found`
```json
{
  "success": false,
  "message": "Live session not found"
}
```

#### Important Notes for Frontend

1. **Detail Screen:** Use this when user taps "View Details" on Live Class Banner
2. **Faculty Info:** Display faculty details with photo, qualifications, and bio
3. **Subject Info:** Show which subject this session belongs to

---

### 3.5 Get Packages by Subject

**Purpose:** Get available packages for a subject (for "What We Offer" section - new users without purchases).

#### Endpoint
```
GET /api/v1/packages
```

#### Authentication
**Required:** No (Public endpoint, but use optional auth to check enrollment status)

#### Request Headers
```
Content-Type: application/json
Authorization: Bearer <access_token> (optional)
```

#### Query Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| subject_id | string | Optional | Filter packages by subject ID |
| package_type | string | Optional | Filter by type: "Theory" or "Practical" |

#### Success Response
**Status Code:** `200 OK`

```json
{
  "success": true,
  "message": "Packages retrieved successfully",
  "data": {
    "packages": [
      {
        "package_id": "60d5ec...",
        "name": "Practical Package",
        "type": "Practical",
        "description": "Comprehensive practical training",
        "price": 4999,
        "original_price": 5999,
        "is_on_sale": true,
        "sale_price": 4999,
        "sale_end_date": "2026-03-01T00:00:00.000Z",
        "duration_days": 365,
        "thumbnail_url": "https://cdn.pgme.com/packages/practical.jpg",
        "features": ["Access to all practical videos", "Live doubt sessions"],
        "display_order": 1
      },
      {
        "package_id": "60d5ec...",
        "name": "Theory Package",
        "type": "Theory",
        "description": "Complete theory coverage",
        "price": 3999,
        "original_price": 4999,
        "is_on_sale": true,
        "sale_price": 3999,
        "sale_end_date": "2026-03-01T00:00:00.000Z",
        "duration_days": 365,
        "thumbnail_url": "https://cdn.pgme.com/packages/theory.jpg",
        "features": ["All theory videos", "Study materials"],
        "display_order": 2
      }
    ]
  }
}
```

#### Important Notes for Frontend

1. **Display Condition:** Show "What We Offer" section only if user has NO active purchases
2. **Package Cards:** Display 2 package cards (Theory and Practical) in grid layout
3. **Pricing Display:** Show sale_price if is_on_sale is true, otherwise show price
4. **Enroll Button:** Opens purchase/payment modal
5. **Browse All:** Navigate to all packages screen filtered by user's primary subject

---

### 3.6 Get Last Watched Videos

**Purpose:** Get user's recent watching history (for "For You" section - enrolled users with active purchases).

#### Endpoint
```
GET /api/v1/users/progress/last-watched
```

#### Authentication
**Required:** Yes (Bearer token)

#### Request Headers
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

#### Query Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| limit | number | Optional | Number of results (default: 10) |

#### Success Response
**Status Code:** `200 OK`

```json
{
  "success": true,
  "message": "Last watched videos retrieved successfully",
  "data": {
    "videos": [
      {
        "video_id": "60d5ec...",
        "title": "Anatomy - Heart Valves",
        "thumbnail_url": "https://cdn.pgme.com/videos/thumb1.jpg",
        "duration_seconds": 2700,
        "module_title": "Cardiovascular System",
        "position_seconds": 1800,
        "watch_percentage": 67,
        "completed": false,
        "last_accessed_at": "2026-02-01T15:30:00.000Z"
      }
    ]
  }
}
```

#### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| video_id | string | Video identifier |
| title | string | Video title |
| thumbnail_url | string/null | Video thumbnail |
| duration_seconds | number | Total video duration |
| module_title | string/null | Module/chapter name |
| position_seconds | number | Last watched position |
| watch_percentage | number | Percentage watched (0-100) |
| completed | boolean | Whether video is completed (≥90%) |
| last_accessed_at | string | ISO timestamp of last access |

#### Error Responses

##### Unauthorized
**Status Code:** `401 Unauthorized`
```json
{
  "success": false,
  "message": "Access token has expired"
}
```

#### Important Notes for Frontend

1. **Display Condition:** Show "For You" section only if user HAS active purchases
2. **Resume Card:** Display the first video from the list with:
   - Title
   - Time remaining: `duration_seconds - position_seconds`
   - "RESUME" label
   - "Continue where you left off" text
3. **Calculate Remaining Time:**
   ```
   remaining_seconds = duration_seconds - position_seconds
   remaining_minutes = Math.ceil(remaining_seconds / 60)
   Display as: "45 Min Left"
   ```
4. **Resume Action:** Navigate to video player, starting at `position_seconds`
5. **Empty State:** If videos array is empty, show "Start Learning" message

---

### 3.7 Get Faculty List

**Purpose:** Get list of faculty members for "Your Faculty" section.

#### Endpoint
```
GET /api/v1/faculty
```

#### Authentication
**Required:** No (Public endpoint)

#### Query Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| specialization | string | Optional | Filter by specialization |
| limit | number | Optional | Number of results (1-100), default: 10 |

#### Success Response
**Status Code:** `200 OK`

```json
{
  "success": true,
  "message": "Faculty retrieved successfully",
  "data": {
    "faculty": [
      {
        "faculty_id": "6980c7...",
        "name": "Dr. Rajesh Kumar",
        "photo_url": "https://i.pravatar.cc/150?img=12",
        "bio": "Senior faculty with 15 years of experience",
        "qualifications": "MD, DNB, PGDHHM",
        "experience_years": 15,
        "specialization": "Community Medicine",
        "is_active": true
      },
      {
        "faculty_id": "6980c7...",
        "name": "Dr. Priya Sharma",
        "photo_url": "https://i.pravatar.cc/150?img=9",
        "bio": "Expert in Anatomy with clinical focus",
        "qualifications": "MBBS, MD Anatomy",
        "experience_years": 10,
        "specialization": "Anatomy",
        "is_active": true
      }
    ]
  }
}
```

#### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| faculty_id | string | Faculty identifier |
| name | string | Faculty name |
| photo_url | string/null | Faculty photo URL |
| bio | string/null | Short biography |
| qualifications | string/null | Academic qualifications |
| experience_years | number/null | Years of experience |
| specialization | string | Specialization/subject |
| is_active | boolean | Whether faculty is active |

#### Important Notes for Frontend

1. **Horizontal Scroll:** Display faculty in a horizontal scrollable list
2. **Card Display:** Show photo, name (with "Dr." prefix), and specialization
3. **Limit:** Use `limit=10` for dashboard display
4. **Tap Action:** Navigate to faculty detail screen
5. **Browse All:** Navigate to all faculty screen (no limit)

---

### 3.8 Get Faculty Details

**Purpose:** Get detailed information about a specific faculty member.

#### Endpoint
```
GET /api/v1/faculty/:faculty_id
```

#### Authentication
**Required:** No (Public endpoint)

#### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| faculty_id | string | Yes | Faculty ID (MongoDB ObjectId) |

#### Success Response
**Status Code:** `200 OK`

```json
{
  "success": true,
  "message": "Faculty details retrieved successfully",
  "data": {
    "faculty": {
      "faculty_id": "6980c7...",
      "name": "Dr. Rajesh Kumar",
      "photo_url": "https://i.pravatar.cc/150?img=12",
      "bio": "Senior faculty with 15 years of experience in Community Medicine. Passionate about public health education.",
      "qualifications": "MD, DNB, PGDHHM",
      "experience_years": 15,
      "specialization": "Community Medicine",
      "is_active": true,
      "createdAt": "2026-01-01T00:00:00.000Z"
    }
  }
}
```

#### Error Responses

##### Faculty Not Found
**Status Code:** `404 Not Found`
```json
{
  "success": false,
  "message": "Faculty not found"
}
```

##### Faculty Not Active
**Status Code:** `404 Not Found`
```json
{
  "success": false,
  "message": "Faculty is not active"
}
```

#### Important Notes for Frontend

1. **Profile Screen:** Display full faculty details with photo, bio, qualifications
2. **Experience Display:** Show experience_years as "15 Years Experience"
3. **Courses:** Optionally fetch courses/sessions taught by this faculty (separate API)

---

## Frontend Integration Guide

### Dashboard Screen Structure

#### 1. Dashboard Header
**No API Required**
- Get user name from local storage (stored during login)
- WhatsApp button opens: `whatsapp://send?phone=+919630000080&text=Hi, I need help with PGME app`
- Pull-to-refresh triggers reload of all dashboard sections

#### 2. Live Class Banner
**API:** `GET /api/v1/live-sessions/next-upcoming`

**When to Call:** On dashboard load

**Display Logic:**
```
IF session === null:
  Hide banner completely
ELSE IF status === "live":
  Show "Join Now" button (green)
ELSE IF status === "scheduled":
  Calculate time_until_start = scheduled_start_time - current_time
  IF time_until_start <= 10 minutes:
    Enable "Join Live" button
  ELSE:
    Disable "Join Live" button, show countdown
```

**Countdown Timer:**
- Update every second
- Display as "Starts Today - 7:00 PM" or "Starts in 2h 30m"

#### 3. Subject Section
**API:** `GET /api/v1/users/subject-selections?is_primary=true`

**Display:**
- Show primary subject name in a chip/button
- "Browse All" opens subject selection modal

#### 4. Conditional Section (Based on Purchase Status)

**How to Determine User Status:**
Check user's active purchases (you may need a separate endpoint or check during login):
```
IF user has active purchase:
  Show "For You" section
ELSE:
  Show "What We Offer" section
```

**Option A: For You Section (Enrolled Users)**

**API:** `GET /api/v1/users/progress/last-watched?limit=1`

**Display:**
- Resume Card (first video from list)
- Theory Card (navigate to theory package)
- Practical Card (navigate to practical package)

**Option B: What We Offer Section (New Users)**

**API:** `GET /api/v1/packages?subject_id=[primary_subject_id]`

**Display:**
- Theory Package card
- Practical Package card
- "Enroll Now" button opens purchase modal

#### 5. Your Faculty Section
**API:** `GET /api/v1/faculty?limit=10`

**Display:**
- Horizontal scrollable list
- Faculty photo (circular)
- "Dr. [Name]"
- Specialization text
- Tap to view faculty profile

#### 6. Bottom Navigation
**No API Required**
- Local state management
- Tabs: Home, Courses, Live, Profile
- Highlight active tab

---

### Dashboard Loading Strategy

#### Initial Load
```
1. Show loading indicator
2. Call APIs in parallel:
   - GET /users/subject-selections?is_primary=true
   - GET /live-sessions/next-upcoming
   - GET /faculty?limit=10
   - GET /packages OR /users/progress/last-watched (based on user status)
3. Hide loading indicator
4. Render sections as data arrives
```

#### Pull to Refresh
```
1. Show refresh indicator
2. Re-fetch all APIs
3. Update UI with new data
4. Hide refresh indicator
```

---

### Error Handling

| Error Type | Action |
|------------|--------|
| 401 Unauthorized | Attempt token refresh, if fails → Logout |
| Network Error | Show "Check your connection", provide Retry button |
| Empty Data | Show appropriate empty state for each section |
| API Failure | Show error message, allow retry |

---

### State Management

**Track These States:**
```
Dashboard State {
  // User Info
  userName: string,
  primarySubject: Subject | null,

  // Live Session
  upcomingSession: LiveSession | null,
  isLoadingSession: boolean,

  // Packages or Progress
  packages: Package[],
  lastWatchedVideo: Video | null,
  hasActivePurchase: boolean,

  // Faculty
  facultyList: Faculty[],
  isLoadingFaculty: boolean,

  // UI State
  isRefreshing: boolean,
  activeTab: number
}
```

---

### Caching Strategy

**Recommended Cache Durations:**
- Live Sessions: 5 minutes (frequently changing)
- Faculty List: 1 hour (rarely changes)
- Subject Selections: Session duration (changes only when user updates)
- Last Watched: 1 minute (updates frequently during viewing)
- Packages: 1 hour (prices/features change occasionally)

---

## Testing

### Test Scenarios

1. **New User (No Purchases):** Verify "What We Offer" section shows
2. **Enrolled User:** Verify "For You" section with resume card shows
3. **No Upcoming Sessions:** Verify Live Class Banner is hidden
4. **Live Session Now:** Verify "Join Now" button is green and enabled
5. **Multiple Faculty:** Verify horizontal scroll works
6. **Network Failure:** Verify error handling and retry works
7. **Token Expiry:** Verify automatic token refresh

---

## Integration Checklist

### Dashboard Header
- [ ] Display user name from local storage
- [ ] WhatsApp button opens WhatsApp with correct number and message
- [ ] Pull-to-refresh reloads all sections

### Live Class Banner
- [ ] API call on dashboard load
- [ ] Hide banner if no upcoming session
- [ ] Show correct button based on status (Join Now vs Join Live)
- [ ] Countdown timer updates every second
- [ ] Enable join button 10 minutes before start time
- [ ] "View Details" navigates to session detail screen
- [ ] "Join Live" opens meeting_link

### Subject Section
- [ ] Display primary subject name
- [ ] "Browse All" opens subject selection modal
- [ ] Handle case when no subject selected

### What We Offer / For You
- [ ] Correctly determine user purchase status
- [ ] Show "What We Offer" for non-enrolled users
- [ ] Show "For You" for enrolled users
- [ ] Resume card shows correct video and time remaining
- [ ] Theory/Practical cards navigate correctly
- [ ] "Enroll Now" opens purchase flow

### Your Faculty
- [ ] Horizontal scroll works smoothly
- [ ] Faculty photos display correctly
- [ ] Tap navigates to faculty profile
- [ ] "Browse All" shows all faculty

### General
- [ ] All API calls include Authorization header
- [ ] Token refresh on 401
- [ ] Loading indicators during API calls
- [ ] Error messages for failures
- [ ] Empty states for no data
- [ ] Pull-to-refresh works

---

**Ready to integrate the Dashboard Module!** ✅

For Authentication and Onboarding APIs, check:
- [01-authentication.md](./01-authentication.md)
- [02-onboarding.md](./02-onboarding.md)
