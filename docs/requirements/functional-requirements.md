# Requirements Documentation for AshTrail

## Project Overview

**Product Name**: AshTrail  
**Product Type**: Cross-platform smoke logging and insights application  
**Primary Platform**: iOS (iPhone 16 Pro Max baseline)  
**Secondary Platforms**: Android, Web, Desktop  
**Development Phase**: Early development / MVP  

## Functional Requirements

### FR-001: Smoke Session Logging
**Priority**: P0  
**Epic**: Data  

#### Description
Users must be able to log smoking sessions with detailed metadata for tracking and analysis.

#### Requirements
- **FR-001.1**: Record session start/stop times with millisecond precision
- **FR-001.2**: Capture session duration automatically
- **FR-001.3**: Allow optional method selection (joint, pipe, vaporizer, etc.)
- **FR-001.4**: Support optional notes/comments (max 500 characters)
- **FR-001.5**: Rate mood before/after session (1-10 scale)
- **FR-001.6**: Rate potency/strength (1-10 scale)
- **FR-001.7**: Auto-save to local storage immediately
- **FR-001.8**: Sync to cloud storage when network available

#### Acceptance Criteria
- [ ] Can start session with single tap
- [ ] Timer displays accurate duration in real-time
- [ ] All fields save automatically without data loss
- [ ] Works offline and syncs when online
- [ ] Session data persists across app restarts

### FR-002: Session Dashboard
**Priority**: P0  
**Epic**: Data  

#### Description
Users need a clear overview of their recent smoking activity and key statistics.

#### Requirements
- **FR-002.1**: Display last 10 sessions in chronological order
- **FR-002.2**: Show today's session count and total time
- **FR-002.3**: Display weekly summary statistics
- **FR-002.4**: Show average session duration
- **FR-002.5**: Display mood trend indicators
- **FR-002.6**: Quick access to start new session

#### Acceptance Criteria
- [ ] Dashboard loads in <2 seconds on cold start
- [ ] Statistics update immediately after new session
- [ ] Shows meaningful data even with minimal history
- [ ] Handles empty state gracefully
- [ ] Refreshes automatically when returning to app

### FR-003: Data Visualization
**Priority**: P1  
**Epic**: Quality  

#### Description
Users need visual insights into their smoking patterns and trends over time.

#### Requirements
- **FR-003.1**: Daily activity chart (sessions per day)
- **FR-003.2**: Duration trends over time
- **FR-003.3**: Mood correlation analysis
- **FR-003.4**: Weekly/monthly pattern identification
- **FR-003.5**: Interactive chart navigation
- **FR-003.6**: Export chart data as images

#### Acceptance Criteria
- [ ] Charts render in <200ms
- [ ] Smooth scrolling and zooming
- [ ] Clear axis labels and legends
- [ ] Accessible color schemes
- [ ] Responsive design for all screen sizes

### FR-004: Data Export
**Priority**: P1  
**Epic**: Export  

#### Description
Users must be able to export their data for analysis, backup, or sharing with healthcare providers.

#### Requirements
- **FR-004.1**: Export all data as CSV format
- **FR-004.2**: Export filtered date ranges
- **FR-004.3**: Export summary reports as PDF
- **FR-004.4**: Include charts in PDF exports
- **FR-004.5**: Email export directly from app
- **FR-004.6**: Save exports to device storage

#### Acceptance Criteria
- [ ] CSV includes all session metadata
- [ ] PDF reports are professional and readable
- [ ] Export completes in <30 seconds for 1 year of data
- [ ] Exported data can be re-imported successfully
- [ ] No sensitive data leaked in exports

### FR-005: Multi-Account Support
**Priority**: P2  
**Epic**: Settings  

#### Description
Support multiple user accounts for shared devices or family usage.

#### Requirements
- **FR-005.1**: Create and manage multiple user profiles
- **FR-005.2**: Secure account switching with authentication
- **FR-005.3**: Isolated data per account
- **FR-005.4**: Account-specific settings and preferences
- **FR-005.5**: Family/shared device management

#### Acceptance Criteria
- [ ] Account switching takes <3 seconds
- [ ] No data leakage between accounts
- [ ] Secure authentication required
- [ ] Account data backed up independently
- [ ] Clear indication of active account

### FR-006: Notifications & Reminders
**Priority**: P2  
**Epic**: Notifications  

#### Description
Optional notification system to help users track patterns and maintain awareness.

#### Requirements
- **FR-006.1**: Configurable session reminders
- **FR-006.2**: Weekly summary notifications
- **FR-006.3**: Goal tracking and achievement notifications
- **FR-006.4**: Break/tolerance notifications (optional)
- **FR-006.5**: Full notification control and privacy

#### Acceptance Criteria
- [ ] All notifications are opt-in
- [ ] Notifications can be fully disabled
- [ ] Timing is user-configurable
- [ ] Content is discreet and privacy-focused
- [ ] Works with device Do Not Disturb settings

## Non-Functional Requirements

### NFR-001: Performance
**Priority**: P0  

#### Requirements
- **NFR-001.1**: Cold start time ≤1200ms (p95)
- **NFR-001.2**: Session save time ≤80ms (p95)
- **NFR-001.3**: Chart rendering time ≤200ms (p95)
- **NFR-001.4**: UI response time ≤100ms (p95)
- **NFR-001.5**: Memory usage ≤100MB baseline
- **NFR-001.6**: Battery impact <2% per hour of active use

### NFR-002: Reliability
**Priority**: P0  

#### Requirements
- **NFR-002.1**: 99.9% uptime for local functionality
- **NFR-002.2**: Zero data loss during offline operation
- **NFR-002.3**: Graceful degradation when network unavailable
- **NFR-002.4**: Recovery from app crashes without data loss
- **NFR-002.5**: Automatic conflict resolution for sync

### NFR-003: Security & Privacy
**Priority**: P0  

#### Requirements
- **NFR-003.1**: All data encrypted at rest (AES-256)
- **NFR-003.2**: Secure transmission (TLS 1.3)
- **NFR-003.3**: No telemetry or tracking without consent
- **NFR-003.4**: Local data remains on device by default
- **NFR-003.5**: Optional cloud sync with explicit consent
- **NFR-003.6**: Compliance with GDPR/CCPA
- **NFR-003.7**: Device-level authentication integration

### NFR-004: Usability
**Priority**: P1  

#### Requirements
- **NFR-004.1**: Intuitive interface requiring no training
- **NFR-004.2**: Maximum 3 taps to complete any core action
- **NFR-004.3**: Support for large text accessibility
- **NFR-004.4**: High contrast mode support
- **NFR-004.5**: VoiceOver/TalkBack compatibility
- **NFR-004.6**: One-handed operation support

### NFR-005: Compatibility
**Priority**: P1  

#### Requirements
- **NFR-005.1**: iOS 15.0+ support
- **NFR-005.2**: Android 8.0+ (API 26+) support
- **NFR-005.3**: Modern web browser support
- **NFR-005.4**: macOS 10.15+ and Windows 10+ for desktop
- **NFR-005.5**: Support for devices with 2GB+ RAM
- **NFR-005.6**: Responsive design for 4.7" to 6.9" screens

## User Stories

### Epic: Data Collection
**As a** cannabis user  
**I want to** easily log my smoking sessions  
**So that** I can track my usage patterns and make informed decisions about my consumption.

#### Stories:
- **US-001**: As a user, I want to start logging a session with one tap so that I don't forget to track my usage.
- **US-002**: As a user, I want the app to automatically track duration so that I get accurate timing without manual effort.
- **US-003**: As a user, I want to add notes about my experience so that I can remember what worked well.
- **US-004**: As a user, I want to rate how I feel so that I can track mood patterns.

### Epic: Insights & Analysis
**As a** cannabis user  
**I want to** understand my usage patterns  
**So that** I can optimize my experience and maintain healthy habits.

#### Stories:
- **US-005**: As a user, I want to see my recent sessions so that I can quickly review my activity.
- **US-006**: As a user, I want to see trends over time so that I can identify patterns in my usage.
- **US-007**: As a user, I want to see how my mood correlates with usage so that I can optimize for wellbeing.

### Epic: Data Portability
**As a** cannabis user  
**I want to** export my data  
**So that** I can share it with healthcare providers or use it in other applications.

#### Stories:
- **US-008**: As a user, I want to export my data as CSV so that I can analyze it in spreadsheet software.
- **US-009**: As a user, I want to generate reports so that I can share insights with my doctor.

### Epic: Privacy & Control
**As a** cannabis user  
**I want** complete control over my data  
**So that** I can maintain privacy and comply with local regulations.

#### Stories:
- **US-010**: As a user, I want my data to stay on my device by default so that my privacy is protected.
- **US-011**: As a user, I want to choose whether to sync to the cloud so that I control where my data goes.
- **US-012**: As a user, I want to delete all my data easily so that I can maintain control.

## Business Rules

### BR-001: Data Retention
- Local data is retained indefinitely unless user explicitly deletes
- Cloud data follows user's retention preferences (30 days to indefinite)
- Deleted data is immediately purged, not soft-deleted

### BR-002: Privacy
- No personal data is transmitted without explicit user consent
- Analytics are aggregated and anonymized if collected
- User can opt out of all data collection

### BR-003: Offline Operation
- All core functionality must work without internet connection
- Data syncing is enhancement, not requirement
- No features should be cloud-dependent

### BR-004: Data Accuracy
- All timestamps use device timezone
- Duration tracking is accurate to 100ms precision
- Data validation prevents invalid entries

### BR-005: User Control
- Users can edit or delete any historical data
- All settings are user-configurable
- No forced features or mandatory data collection

## Constraints

### Technical Constraints
- **TC-001**: Must use Flutter for cross-platform development
- **TC-002**: iOS version must support Apple App Store guidelines
- **TC-003**: Android version must comply with Google Play policies
- **TC-004**: Local storage using Isar database
- **TC-005**: Cloud storage using Firebase Firestore (optional)

### Business Constraints
- **BC-001**: No monetization features in MVP
- **BC-002**: Must comply with cannabis regulations in target markets
- **BC-003**: No promotion or encouragement of illegal activity
- **BC-004**: Professional medical disclaimers required

### Legal Constraints
- **LC-001**: GDPR compliance for EU users
- **LC-002**: CCPA compliance for California users
- **LC-003**: Age verification may be required in some jurisdictions
- **LC-004**: Medical disclaimer and "not medical advice" statements

## Success Metrics

### User Engagement
- **Daily Active Users**: Target 70% retention after 30 days
- **Session Logging**: Target 80% of real sessions logged
- **Feature Adoption**: Target 60% use of insights features

### Technical Performance
- **App Store Rating**: Target 4.5+ stars
- **Crash Rate**: Target <0.1% crash rate
- **Performance**: Target 95% of actions complete within performance budgets

### Business Metrics
- **User Satisfaction**: Target NPS >50
- **Support Burden**: Target <5% of users requiring support
- **Privacy Compliance**: Zero privacy violations or data breaches

---

This requirements document will be updated as features are implemented and user feedback is collected.
