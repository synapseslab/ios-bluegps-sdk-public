# Changelog

What changed in SynapsesSDK, for the people who integrate it.

This file records changes to the **public surface** and to behaviour an
integrator can observe. Internal refactoring is left out unless it changes what
you see. Entries are newest first.

> Versions are the tags of the Swift package at
> [ios-bluegps-sdk-public](https://github.com/synapseslab/ios-bluegps-sdk-public).
> Changes not released yet sit under **Unreleased**, which takes the version's number
> when it ships. Entries name the commit that carries them.

---

## 3.0.1

### Changed — behaviour

- **`startAdvertising` waits for Bluetooth, as `startAdvertisingRegion` always
  did.** With Bluetooth off or not authorized it still throws `bluetoothOff` or
  `bluetoothNotAuthorized`, and now keeps the start pending: advertising begins
  by itself once Bluetooth powers on, and `advertising` turns `on`.
  `stopAdvertising()` drops a pending start. Before, such a start was dropped,
  and the app had to call `startAdvertising` again.

## 3.0.0

The first release of the **3.0** series, after 2.0.123. Rebuild your app against it:
21 methods changed their binary interface (see below). It needs iOS 17 and the Xcode
version the release notes name.

The tag `v5.0.0` has been removed. It carried 2.0.109, and Xcode proposed it when
adding the package, so a dependency added that way has stayed on 2.0.109 since. If
your rule starts from 5.0.0, change it to *Up to Next Major Version* from 3.0.0.

### ⚠️ Changed — binary compatibility

- **21 facade methods are now `nonisolated(nonsending)`**, so they inherit the
  isolation of whoever calls them instead of hopping off it. This is what lets
  you pass a model you own — a `BGPSFormModel` you are editing, a `Resource` you
  are showing — without Swift 6 reporting a data race on the call.

  Affected: `assignmentList`, `search`, `searchByBooking`, `setDNDFilters`,
  `stampsList`, `postWidgetCard`, `submitNewTicket`, `getNewTicketForm`,
  `postVisitForm`, `postAddVisitorForm`, `swapResults`, `getWayfinding`, the four
  EasyPlanner verbs and the four notification verbs.

  **This changes the ABI of those functions**: the compiler passes an implicit
  isolation parameter, so a client linked against a *previously built*
  XCFramework and calling one of them is not binary-compatible with this build.
  Source is unaffected — **rebuild against the new XCFramework and nothing else
  changes**. Nothing breaks at compile time, which is precisely why this needs
  saying: an unrebuilt client fails at run time, not at build time.

  It was accepted on the stated understanding that no current integrator uses
  those areas. If that is wrong for you, tell us before upgrading.

### ⚠️ Changed — source compatibility

- **`startAdvertisingRegion(with:frequency:)` (both variants) and
  `stopAdvertisingRegion()` are deprecated** in favour of
  `startAdvertising(configuration:)` and `stopAdvertising()` (see *Added — API*).
  They keep working; the compiler now warns where you call them. (`2da1385`)

- **The advertising settings have generic names.** `AdvertisingEnvironment`,
  `EnvironmentModel.advertisingEnv`,
  `EnvironmentModel.init(endpoint:timeout:keycloakEnv:advertisingEnv:)`,
  `BlueGPS.advertisingRate`, an `AdvertisingConfiguration.Rate`, and
  `ARType.BlueGPSAntennas` replace names that named a positioning vendor. The old
  names stay as deprecated aliases, and Xcode's fix-it renames them. Environments
  persisted under the old names, and the old `ARType` value in an Info.plist, are
  still read.

- **`NewTicket.id` is now a `String` — the server's ticket id — and no longer a
  per-instance `UUID`.** It was assigned at declaration and absent from
  `CodingKeys`, so every decode minted a new one: two fetches of the same ticket
  were two different identities. In a SwiftUI `ForEach` that means a refresh
  deletes and reinserts every row, and a refresh landing on top of a row
  animation crashes the list with `NSInternalInconsistencyException`.

  `==` and `hash(into:)` now both key on `ticketId` alone. Hashing also mixed in
  `creationTimestamp`, `name`, `status` and `categoryId`, which are mutable: once
  equality keys on the id, hashing anything mutable means two equal values can
  have different hashes, which corrupts any `Set` or `Dictionary` holding them.

  **What this means for you:** code that stored a `NewTicket.id` as a `UUID` no
  longer compiles — use the `String`. Two `NewTicket` values for the same ticket
  now compare equal where they previously did not; `ForEach(tickets)` and
  `Set<NewTicket>` behave the way you would expect instead.

- **`MobileIcon.image` is now `@MainActor`.** It reads the presented view
  controller's trait collection to pick the light or dark path, and UIKit is not
  thread-safe: the accessor was reachable from any context and would have read
  those off the main thread. Callers are SwiftUI bodies and view controllers,
  which are already on the main actor; anything else has to hop.

### Changed — behaviour

- **The advertising settings of the Info.plist apply.** `setupSDK()` reads them from
  the new `AdvertisingConfig` dictionary (see *Added — API*), and from the dictionary
  it replaces, which earlier versions ignored: values other than the defaults kept
  there apply again. An `EnvironmentModel` built in code without `advertisingEnv`
  takes them too.

- **Signing out stops background work.** `logout(parameters:contextProvider:)` and
  `localLogout()` now stop the background session, tag advertising and beacon
  tracking before clearing the credentials: once no one is signed in, the device
  no longer broadcasts the last user's tag. Beacon tracking is stopped only if it
  was started. If your app restarted advertising after a logout on purpose, do it
  after the next sign-in. (`9764cf9`)

- **An error answered in the platform's standard envelope keeps its message.**
  That body — `status`, `error`, `message`, `path`, `requestId`, … — has no
  `code`, so it never decoded as a `ResponseMessage` and the call threw
  `"Invalid status code"`, dropping the server's reason. It now throws an
  `APIError` whose `responseMessage.message` is the body's `message`.

  **What this means for you:** `responseMessage.code` is still the HTTP status,
  so code that branches on it is unaffected; `localizedDescription` now returns
  the server's message where it used to return `"Invalid status code"`. That
  message is written for diagnostics, not necessarily for the end user.

- **The log redacts sensitive values by default.** While
  `BGPSLogManager.redactsSensitiveData` is on, which it is unless you turn it off,
  `BGPSLogManager.log(_:)` writes `REDACTED-DUE-TO-PRIVACY-LOGS-ENFORCEMENT` in
  place of text in the shape of a secret: JWTs, `Bearer` credentials, token,
  secret and password parameters, the `code`, `state` and PKCE parameters of a
  URL, token fields of a JSON body, FCM registration tokens, and the identifiers
  of the device or the person — `uuid`, `session_state`, `sid` and `sub` in a URL
  query or a JSON body. The ids of bookings, tickets and other objects stay
  readable. The SDK's own log
  lines that carry such values now go through the same redaction, including the
  login and logout URLs, which also mask `state` and `code_challenge` now.

  **What this means for you:** lines you send through `BGPSLogManager.log(_:)`
  are redacted as well, so a token you used to see in `console.log` now reads as
  the placeholder. Wrap the sensitive values you log yourself with
  `BGPSLogManager.redacted(_:)` — the shape-based replacement is a safety net and
  cannot recognise every secret — and use it for lines you `print` directly.
  Set `redactsSensitiveData` to `false` at launch, before anything logs, only in a
  build that needs the raw values to debug.

- **`logout` now ends the Keycloak session on the server.** Before, the
  end-session request carried no `id_token_hint` and ran in an ephemeral web
  session with no cookie, so Keycloak could not tell which session to end: it
  showed its own page, the session stayed alive, and its refresh token kept
  minting access tokens after the user had signed out. `logout` now sends the id
  token as `id_token_hint`, and then ends the session with a POST to the
  end-session endpoint carrying the refresh token, which works in every login mode
  and whether or not the web step is completed.

  **What this means for you:** the local session is now cleared in every case, also
  when the web step fails; before, a failed web step left it in place. The
  completion reports `true` once the server session is known to be ended, and
  `false` with `NSError` code `-23013` when it could not be confirmed, for instance
  offline: the device is signed out, but the session may outlive the logout until
  it expires. An access token issued before the logout stays valid until it
  expires unless your backend checks the session on each request (token
  introspection): keep its lifetime short.

- **`getNotificationsCount(for:notificationType:)` asks with a body, not a query
  string.** The call is now `POST /api/ntfm/v1/notification/count` carrying the
  push token and the stream as JSON (`BlueGPS.GetNotificationCountPayload`),
  where it was a `GET` with both as query items. The signature is unchanged; the
  old form came back empty, which left an unread badge at zero.

- **Beacon tracking hands values across its Core Location callbacks, not
  objects.** The four `CLLocationManagerDelegate` methods used to carry the
  `CLRegion` — a non-`Sendable` class — into the main-actor hop; they now read
  `identifier` and `beaconIdentityConstraint` on Core Location's own queue and
  send those. Same for the beacon identities in `didRange`. The one visible
  difference is that a non-beacon region returns before scheduling a Task rather
  than after.

  ⚠️ **Verified by compiling only.** Beacon tracking is experimental, was built
  for one installation (Museo del Futuro) to locate devices by floor in the
  background, and has never been exercised: no app in this repository calls any
  of its five entry points, and none ever has. Anyone who puts it in front of
  real beacons should treat this as untested.

- **Ticket audio uploads are announced as M4A, not raw AAC.** The multipart part
  built by `SaveNewTicketRequest` (and its legacy twin `SaveTicketRequest`) named
  the file `<sha256>.aac` with `Content-Type: audio/aac`, while the bytes are
  MPEG-4 AAC inside an MPEG-4 container. They are now `<sha256>.m4a` with
  `audio/mp4`. A backend that keys off the extension or the media type was being
  told the wrong thing.

- **`DynamicMapView.delegate` and `.resourcesDelegate` are now `weak`.**
  They were strong, so the map view retained whatever was listening to it —
  normally its own owner, which is a reference cycle neither side can break.

  **What this means for you:** assigning a temporary no longer works.

  ```swift
  mapView.delegate = MyHandler()      // was fine, now goes nil at once
  self.handler = MyHandler()          // keep your own reference
  mapView.delegate = self.handler
  ```

  A delegate that is a view controller, a coordinator or anything else you
  already hold is unaffected.

- **The map view's JavaScript callbacks capture `self` weakly.** A map torn
  down while a command was in flight could crash on a dangling reference; it
  no longer can. Your completion handler is still called in that case — only
  the delegate notification is skipped, because it needs the view as its
  sender.

- **The package downloads the XCFramework from the release.** The binary is an
  asset of each GitHub release, no longer a file of the repository, so the
  repository stops growing by a binary at every version. Nothing changes in your
  project. If your network allows only listed hosts, it must reach GitHub's
  release downloads, not only its raw files.

### Added — API

- **Advertising settings in the Info.plist.** An optional `AdvertisingConfig`
  dictionary in `SynapsesSDK` sets the rate of `startAdvertising()` without a
  configuration and the two bytes the advertised identifier is derived from; in code
  they are an `AdvertisingEnvironment`. **Keep the defaults**: change them only when
  Synapses technicians ask you to, as any other change can interrupt the service or
  degrade its performance. The *Positioning* article describes them.

- **EV charging on a booked spot**, on the DepotFinity connector.
  `getActiveEVBookings()` returns the current user's EV bookings active right now, each an
  `ActiveEVBooking` with the snapshot for the first paint (`ChargerState`) and a fresh
  socket URL; `openEVChargeSocket(for:)` opens the status channel for one of them, which
  delivers `EVChargeEvent`s, `BookingClosedInfo` among them. Keep the socket's reference:
  releasing it closes the channel. (`b65409a`, `ea584f1`)

- **Ticket comments**: `getTicketComments(ticketId:)` and
  `saveTicketComment(ticketId:comment:)`, with the `TicketComment` model. The JSON field
  `id` decodes into `commentId`, since `id` is the local SwiftUI identity. (`d68ab89`)

- **NFC stamps without a session**: `getUserUUID()` reads the user's Micronpass identity
  (`UserUUID`) and keeps it in the keychain; `postPublicRFID(for:uuid:)` stamps an RFID tag
  for that identity on a public endpoint, with no token, so it works before the session
  is restored. `logout(parameters:contextProvider:)` removes the identity;
  `localLogout()` keeps it, so stamps keep working after a session expires. (`2aa5872`)

- **Token expiry instants**: `KeycloakTokenPayload.accessTokenExpiryDate` and
  `refreshTokenExpiryDate`, the moments `accessTokenValid` and `refreshTokenValid` turn
  false, for scheduling work ahead of expiry. (`cb4b00f`)

- **`resumeAuth(callbackURL:)`** resumes an interactive login from a redirect delivered
  through `openURL`, as an Intune MAM wrap does instead of letting
  `ASWebAuthenticationSession` capture it. Returns whether the URL was consumed.
  (`4535b96`)

- **Map**: the `navFloors` event (`NavFloorsResponse`) lists the floors the current route
  crosses, in order (`71a4c78`); `DynamicMapView.selectResourceOnMap` selects a resource on
  the map (`d7d75f8`).

- **Background sessions**: `BlueGPS.shared.backgroundSession` keeps the app working
  in the background while a Live Activity of yours is on screen, with tag
  advertising and the two Bluetooth background modes. You own the Live Activity:
  its `ActivityAttributes` type, its content and the widget extension that draws
  it; the SDK adds nothing to it. `start(_:initial:updates:options:)` takes the
  attributes, which must be `Sendable` (a struct of plain values is), the first
  content and an `AsyncSequence` of updates (equal values are skipped, at
  most one update a second, the newest wins); `stop(dismissal:)` ends it and stops
  tag advertising;
  `state`, `indicator`, `limitations`, `lastSuspension` and `events()` report how
  it goes. DocC article *Background Sessions*. (`b795d30`)

- **Tag advertising with typed outcomes**: `startAdvertising(configuration:)`
  (the server's configuration, or an `AdvertisingConfiguration` with a tag id and
  a rate), `stopAdvertising()`, and the observable `advertising` state
  (`off`, `on`, `failed`). Failures throw an `AdvertisingError`:
  `bluetoothOff`, `bluetoothNotAuthorized` and `advertisingNotSupported` — all
  three were `-27009` before — `invalidTagId`, `configurationUnavailable`, or
  `advertisingFailed` with Core Bluetooth's code. Starting again restarts without
  reporting `off`; stopping reports `off` once. The state follows advertising
  started with the deprecated API too. (`2da1385`)

- **The home's widget sections with their title**:
  `getWidgetsHomeContainer(tagId:)`, on `GET /api/v2/widget/home/container`,
  returns a `WidgetsHomeContainer` — the `title` to show above the sections, the
  container `type`, and `widgets: [BGPSComponent]?`, the same `WIDGET_SECTION`s
  as `getWidgetsHome(tagId:)`, `nil` when the profile enables none. The backend
  deprecates `/api/v2/widget/home`, but `getWidgetsHome(tagId:)` is unchanged:
  it is the fallback on a backend that predates the container endpoint.

- **Instant EV charging**: taking a charging spot without a booking, on the
  depot-finity connector.
  - Six calls: `getInstantStatus()`, `getInstantCandidates()`,
    `requestInstantSpot(resourceId:)`, `leaveInstantQueue()`,
    `replaceInstantSpot(reason:note:resourceId:)` and `declineInstantSpot()`.
    Every one answers `404` when instant is switched off on the installation.
  - Models: `InstantStatus` (the same object on REST and on the socket),
    `InstantCandidates`, `InstantCandidate`, `InstantRequestResult`,
    `InstantOpeningHours`, and the enums `InstantState`, `InstantPhase`,
    `InstantPoolState`, `InstantRequestOutcome`, `InstantReplaceReason`.
  - The instant channel: `openInstantChargeSocket(wsUrl:onStatus:onTermination:)`,
    which returns an `EVChargeSocket` opened with the new
    `connect(onInstantStatus:onTermination:)`, and `InstantStatusMessage` for
    its frames. The booking channel's API is unchanged.
  - `WidgetActionType.CHARGER_ACTION`, the home action card that opens the flow.

- **`ScheduleElement.description: String?`**, the booking's free-text
  description. Optional and omitted by the backend when the booking has none, so
  an existing booking decodes as before.

- **Multi-resource bookings on `ScheduleElement`**: `multiResources: [Resource]?`,
  every resource of a booking that holds more than one (it includes `resource`),
  and `action: ScheduleAction?`, what the booking allows besides navigating to
  it — `NOT_EDITABLE`, `NOT_DELETABLE`, `NOT_EDITABLE_AND_NOT_DELETABLE` or
  `DEFAULT`, with `allowsEdit` / `allowsDelete` to read it. Both are optional and
  omitted by the backend when they do not apply, so an existing booking decodes
  as before; `ScheduleAction` is a `SafeCodableEnums`, so an unknown value
  decodes to `DEFAULT`.

- **A cover image on occupancy cards**: `BGPSWidgetDoubleValueModel.image:
  String?`, the path of the zone's image relative to the server. Load it with
  `fetchResource(path:)`, which adds the server URL and the bearer token, and
  decode the bytes: the response is a PNG whose `Content-Type` may read
  `application/json`. Absent when the zone has no image, so an existing payload
  decodes as before; a merge keeps the current image when the update does not
  carry one, and encoding writes the key only when it is set.

- **`BGPSLogManager.redactsSensitiveData`, `redactionPlaceholder` and
  `redacted(_:)`**: the switch for the log's redaction, the text a redacted value
  is written as, and the wrapper that applies it to one value. See *Changed —
  behaviour*.

- **`BookingStatus`, and a `status` on `ScheduleRequest` and `ScheduleElement`.**
  A resource can require manual approval before a booking is confirmed, in which
  case the booking answers `PENDING_APPROVAL` instead of `CONFIRMED`. The field
  is optional and the backend omits it for resources that need no approval, so
  **`nil` means confirmed** — the behaviour you have today. Like the other
  API-driven enums it is a `SafeCodableEnums`, so a status this version does not
  know decodes to `UNKNOWN` instead of making the whole response throw.

  The status is assigned by the backend and is deliberately absent from
  `ScheduleRequest.encode(to:)`: the booking request you send is unchanged.

- **`ntfmUnregister(_:)`**, the counterpart of `ntfmRegister(_:)`:
  `DELETE /api/ntfm/v1/device/unregister`, taking an `UnregisterDeviceRequest`
  (push token, and the device UUID where a token may be registered from more
  than one install) and answering `[RegistrationInfoResponse]` — the registrations
  the call removed. Until a token is unregistered the backend keeps it as a valid
  destination, so pushes for an account that has signed out keep arriving on that
  device.

### Added — concurrency

- **219 public value types now declare `Sendable`.** A public struct is not
  implicitly `Sendable` outside its own module, so DTOs whose contents were
  perfectly fine still arrived non-sendable. Purely additive, no ABI impact.
- Not every type could take it: anything holding a mutable class —
  `MapPositionModel`, `BGPSAlertModel`, the `@Observable` component models,
  `AnyCodable` — cannot be `Sendable` however it is declared. `Resource`,
  `ScheduleElement`, `Filter` and `BGPSComponent` are in that group. That is
  what the `nonisolated(nonsending)` change above is for.

### Added — documentation

- **A new README and new guides.** The README is now an overview with diagrams
  that links into the online documentation. *Getting Started* covers
  configuration, sign-in and advertising end to end, and two articles are new:
  *Maps* and *Live Data*. They replace the long integration guide, retired with
  its PDF and screenshots.
- **Positioning.** The new *Positioning* article covers the two ways a position
  reaches the SDK: by default from the BlueGPS antennas, which pick up the tag
  the device broadcasts, or from another supported positioning system that
  computes the position on the device and hands its fixes to
  `BGPSPositionCoordinator`. Tag advertising moved there from *Getting Started*,
  which now ends with registering the device.
- The configuration types of specific positioning vendors are no longer on the
  documentation site. They remain public API, unchanged.
- Every public type is documented, as is every public function outside the
  model layer. That covers the server-driven component models, the navigation
  and mapping types, booking, home, tickets, visitors, the Keycloak OIDC models,
  the SSE request shapes and `EventSource`'s stream API.
- Two contracts that were implicit are now written down:
  - `SafeCodableEnums` decodes an unrecognised value as **`allCases.last`**, so
    a conforming enum must declare its catch-all case last.
  - `BGPSComponent`, `Widget` and `SensorInfo` decode an unknown kind to their
    `UNSUPPORTED` case rather than failing, so one new server-side value does
    not cost the whole response. Handle that case.

### Fixed

- **The Swift package declares iOS 17**, which the XCFramework requires; it declared iOS
  13, so an app with a lower deployment target resolved the package and then failed. The
  package's URL also uses the repository's current name.

- `startAdvertisingRegion`: a start that Core Bluetooth refuses now reaches the
  completion with its error; the `async` variant used to wait forever. A start
  reported as failed because Bluetooth was off no longer calls the same
  completion a second time when Bluetooth is turned on, which crashed the `async`
  variant. (`2da1385`)

- Twenty force unwraps removed from the multipart upload paths
  (`"…".data(using: .utf8)!` → `Data("…".utf8)`).
- `BlueGPS.swift` no longer force-casts a response body that it has just
  type-checked.
- `FoodWebView.setTheme(_:)` and `setLanguage(_:)` no longer lose a value pushed
  before the page has installed its bridge. Both keep the last value and deliver
  it again when the page posts `B2GPS_READY`, before the token. A host that
  pushed appearance from `foodViewDidFinishLoad(_:)` could see the language
  dropped: the navigation can finish while the page's module script, which
  creates the bridge, is still pending. Call them any time, before or after
  `load(_:)`.

### Internal — no effect on integrators

- SwiftLint now runs as a build phase on the framework target, and the
  framework is at zero violations.

---

## Known issues

- **`BGPSButtonStyle` decodes an unknown value as `PRIMARY_FILLED`.**
  `SafeCodableEnums` falls back to the last case, and that enum's last case is
  a real style rather than a catch-all, so a button style this SDK version does
  not know renders as a filled primary button. Fixing it means adding a case to
  a public enum, which is a breaking change and is being scheduled rather than
  slipped in.
- **`DynamicMapView.load` only reloads when *both* the URL and the
  configuration change.** The guard reads
  `oldConfiguration != configuration, oldURL != url`, so changing just one of
  them takes the early-return path and reports `resetView` instead of
  reloading. Documented as it stands; not yet changed.
