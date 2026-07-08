---
layout: post
title:  "Kerami BowlSight™"
date:   2026-07-08 09:00:00 -0700
description: "A deeply unserious product concept for instrumented toilets that accidentally wanders into facilities analytics, retry rates, and predictive maintenance."
tags: [humor, distributed-systems, infrastructure, iot, analytics]
---

This began as a joke. It is not a product proposal. Unfortunately, it gradually becomes one.

The fictional product is **Kerami BowlSight™**: a colorimetric or turbidity sensor inside a toilet, an embedded controller, cloud-managed networking, and a dashboard. The original feature was a red light outside the stall when the previous flush had not achieved its stated objective.

No cameras. No image storage. No computer vision model creating tickets that would make HR leave the room. Just a sensor deciding whether the water returned to a sufficiently uninteresting state.

```text
GREEN: fixture available for ordinary civilization
RED:   another flush is recommended before handoff
```

This is, in the narrowest possible sense, privacy-preserving. The system does not know who you are or what happened. It is simply an unusually judgmental embedded device attached to a porcelain state machine.

## The Red-Light Prototype

The prototype architecture is almost disappointingly normal.

```text
+-------------------+       +----------------------+       +----------------+
| turbidity sensor  | ----> | embedded controller  | ----> | Kerami cloud   |
+-------------------+       +----------------------+       +----------------+
          |                            |                            |
          v                            v                            v
   bowl water state             local decision              dashboard events
                                      |
                                      v
                              red stall indicator
```

The firmware observes a baseline, detects the flush cycle, waits for the system to settle, and compares the post-flush measurement against a threshold. If the reading remains outside the acceptable band, the controller asserts a GPIO pin and the hallway receives a small but unmistakable piece of operational feedback.

There are edge cases, obviously. Some fixtures refill slowly. Some sensors foul. Some bowls have unusual optical characteristics. Some humans deploy enough toilet paper to suggest an attempted denial-of-service attack against municipal infrastructure.

Still, the bounded joke is simple: detect whether flushing succeeded, and recommend a retry when it did not. Then comes the question every product manager fears and every infrastructure engineer eventually asks anyway:

> ...wait...what useful data would this actually collect?

## Enterprise Feature Creep

Once a device emits an event, the enterprise software organism begins reproducing. A single toilet with a red light is a prank; five thousand fixtures reporting health metrics across a campus is a platform.

Facilities will want fleet management, site hierarchy, and a single pane of glass across buildings, floors, wings, and mysterious sub-basements that nobody admits are still in use. Then come the REST APIs.

```http
GET /api/v1/fixtures
GET /api/v1/fixtures/{fixture_id}/flush-events
GET /api/v1/sites/{site_id}/clearance-rate
POST /api/v1/webhooks/retry-threshold-exceeded
```

You can already hear the launch webinar.

> With Kerami BowlSight™, facilities teams gain real-time visibility into fixture performance, historical clearance trends, and exception-driven alerting across distributed restroom environments.

The phrase "distributed restroom environments" should be illegal, but it is also exactly how this product would be described if it existed.

Alerting is table stakes. Nobody wants to stare at the dashboard waiting for Stall 3 to develop opinions, so you add webhooks:

- notify chat when retry rate crosses a threshold,
- open a ticket when first-pass success drops below policy,
- page the on-call plumber when correlated failures cluster in a fifteen-minute interval,
- export weekly compliance reports for reasons nobody can fully explain.

Eventually, the roadmap gets a compliance dashboard, because every enterprise product must eventually imply that not buying it creates liability.

```text
Kerami BowlSight™
Unified restroom telemetry for the modern enterprise.

- Cloud-managed fixture observability
- Historical trend analysis
- Configurable red-light policy enforcement
- Webhook-driven custodial workflows
- Cross-site compliance dashboards
- Native integration with existing Kerami organizations
```

And then, at the bottom of the slide, in smaller text than legal would prefer:

**Kerami BowlSight™: making every packet drop visible.**

## The Low-Flow Toilet Question

This is where the joke starts behaving badly.

Everyone assumes low-flow toilets save water. The label says fewer gallons per flush, the number is lower, the planet nods approvingly, and procurement orders eight hundred of them. But distributed systems people are constitutionally unable to accept the nominal success path as the only metric that matters.

If an operation frequently needs to be retried, the advertised unit cost is not the effective unit cost. A toilet that uses 1.28 gallons per flush is excellent if the operation succeeds on the first attempt. If users routinely flush twice, the interesting metric is not gallons per flush. It is:

```text
effective gallons per successful flush
```

Or, if we want to make the facilities director regret inviting us to the meeting:

```text
effective gallons per completed event =
    gallons per flush * average flush attempts per successful clearance
```

Now we are measuring the system, not the brochure. The useful telemetry is mundane and, unfortunately, real:

- **Flush count:** how many flush operations occur per fixture per day.
- **Retry rate:** how often one flush is followed by another flush within the same plausible event window.
- **First-pass success rate:** how often one flush appears to clear the bowl state.
- **Successful clearance:** whether the post-flush sensor reading returns to an acceptable baseline.
- **Water consumed per completed event:** whether the low-flow fixture is actually low-flow in production.

This is not conceptually different from measuring request retries in a microservice. If Service A advertises 50 ms median latency but the client library retries 18% of calls, the customer experiences the system after failure handling. Likewise, a building consumes the water required to complete the workload, not the water printed on the fixture specification sheet.

I do not like that this paragraph is defensible.

## Facilities Analytics

The commercial product, to be clear, is not embarrassing employees. That would be creepy, useless, and somehow less profitable. The useful product is fixture analytics.

Facilities teams already care about which assets are failing, where maintenance is being deferred, and why one corner of Building B generates custodial tickets at three times the rate of the rest of the campus. BowlSight telemetry could reveal:

- toilets that need maintenance before they fully fail,
- recurring clogs that correlate with fixture model, age, or location,
- leaking valves with abnormal refill or flush signatures,
- poor-performing fixtures whose low-flow savings vanish under retry load,
- stalls with unusually high utilization and therefore higher service priority,
- sensor drift indicating that the monitoring system also needs monitoring, because of course it does.

At this point the red light is almost irrelevant. The light was the joke. The dashboard is the product. The joke has accidentally wandered into predictive maintenance.

That is the uncomfortable part. Remove the bathroom context and this is a normal IoT facilities-management system: distributed sensors, noisy local measurements, cloud aggregation, anomaly detection, asset health scoring, workflow integration, and a dashboard that lets operations spend money slightly before the outage instead of immediately after it.

The only reason it feels absurd is that the failure domain has tile walls.

## A Totally Normal Dashboard

The executive dashboard would not show raw sensor traces. It would show a confident rectangle containing percentages.

```text
Kerami BowlSight Fleet Dashboard

Organization: ExampleCo Global
Site:         San Jose Campus
Window:       Last 30 days

Fleet health:                 Mostly hydrated
First-pass success rate:       82%
Average flushes/event:         1.31
Effective gallons/event:       1.68
Estimated retry water/month:   14,220 gallons

Highest retry fixture:
  Building: B
  Floor:    2
  Stall:    3
  Model:    Legacy low-flow, installed 2011

Observed behavior:
  - 61% first-pass success
  - 2.04 average flushes/event
  - elevated turbidity persistence after refill
  - retry clusters between 09:00 and 10:30 local time

Recommendation:
  Replace fixture with one possessing greater personal conviction.
```

There would be trend lines, export buttons, and a CSV with column names like `fixture_id`, `event_start`, `flush_attempts`, `clearance_confidence`, and `water_estimate_gallons`. A customer would ask whether the API supports custom retention periods. Someone in sales engineering would say, truthfully, that retention is configurable by organization policy.

A security reviewer would ask whether the telemetry could be linked to individuals. The answer would be no, assuming nobody integrates it with badge access, occupancy sensors, Wi-Fi association logs, janitorial schedules, or the other seventy-nine data sources enterprises already collect while insisting they are not building a panopticon.

This is why architecture review exists.

## Implementation Notes Nobody Asked For

The embedded device should make local decisions. Do not round-trip to the cloud to decide whether to illuminate the red light. A bathroom stall is an edge environment in the strongest possible sense of the phrase.

The cloud should receive events, not vibes.

```json
{
  "fixture_id": "bldg-b-floor-2-stall-3",
  "event_id": "01J2RESTROOMOBSERVABILITY",
  "flush_attempts": 2,
  "first_pass_success": false,
  "clearance_confidence": 0.94,
  "estimated_gallons": 2.56,
  "sensor_health": "nominal"
}
```

There should be hysteresis so the indicator does not flicker during refill turbulence, calibration routines, maintenance mode, and local buffering because restroom Wi-Fi is often worse than anyone wants to admit.

Most importantly, the system should fail boring. If BowlSight cannot determine state, it should mark the event unknown, suppress confident recommendations, and ask for sensor maintenance. The worst version is not one that misses an occasional retry; it is one that becomes certain about things it cannot know.

That principle applies outside bathrooms too, but nobody asked me to ruin the mood.

## Roadmap Discipline

No reasonable product manager would approve this roadmap item. Not because the system is impossible; impossibility would be comforting. The problem is that the technical pieces are all boring enough to fit in a quarterly planning document.

Sensor. Controller. Cloud ingestion. Dashboard. Alerts. Workflows. Predictive maintenance. ROI model based on water savings and reduced service tickets.

The absurdity is not that it cannot be built. The absurdity is that, given the right spreadsheet, it probably could be justified.

Every joke eventually reaches the point where someone asks whether it comes in an enterprise SKU.

This one got there before the second flush.
