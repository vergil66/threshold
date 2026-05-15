# Threshold — Development Notes

## Project Overview

Threshold is a reflective classroom daybook for teachers.

Part planner, part field notebook, part reflective companion,
Threshold is designed to help educators notice patterns,
transitions, and moments of change within the lived experience
of teaching.

The project grows out of several earlier Vergil’s Coffee Table
projects and practices:

- The Vestibule → intentional beginning and sustained practice
- Turn → follow-through and returning
- Circles of Change → reflective pattern noticing
- Field Ledger → daily logging and practical reflection
- Crossing → confidence and movement through transition
- Start Anywhere → Engage / Reduce / Persist as lived practice

Threshold is not intended to become:
- an LMS
- a grading platform
- a standards tracker
- a compliance tool

Instead, the project centers:
- planning
- presence
- reflection
- transition moments
- classroom rhythm
- teacher noticing
- accumulated teaching memory

---

## Core Questions

Threshold begins with several foundational questions:

- What changes in the room during a lesson?
- What transition moments matter most?
- How does a teacher notice growth over time?
- What should be remembered from one semester to the next?
- What patterns emerge across periods and weeks?
- How can reflection remain lightweight enough to sustain?

---

## Initial Design Direction

The earliest version of Threshold will likely include:

### Course Layer
- semester overview
- units
- recurring practices
- goals
- Engage / Reduce / Persist tracking

### Unit Layer
- pacing
- reflections
- instructional notes
- future adjustments

### Daily Layer
- lesson focus
- lesson sequence
- transition notes
- reflections
- follow-up items
- period-specific observations

### Reflection Layer
- daily reflections
- weekly reflections
- transition tracking
- pattern noticing

---

## Philosophical Direction

Threshold is less interested in:
“How much content was covered?”

and more interested in:
“What changed during the experience of learning?”

The project assumes that teaching is not merely delivery,
but accompaniment through transitions:
- uncertainty → confidence
- silence → participation
- dependence → ownership
- confusion → clarity

Threshold attempts to create space for teachers to notice
those movements while they are still happening.

## Origin Reflection — 15 May 2026

While leaving John Adams High School on 15 May 2026,
the idea for Threshold began to crystallize as a classroom
practice companion that combined:

- lesson planning
- transition awareness
- daily reflection
- weekly reflection
- teacher noticing
- longitudinal classroom memory

The project emerged from earlier work on:
- Field Ledger
- OneDay
- Crossing
- The Vestibule

A central realization during the reflection was that the
project was less about planning content and more about
paying attention to movement inside the classroom:

- who is doing the intellectual work
- how transitions shape energy
- how teaching rhythms evolve
- what should be noticed and remembered

The reflection also introduced the idea of:
“tracking the ways that I engage, reduce, and persist
within each class.”

This became an early philosophical anchor for the project.---

## Technical Direction (Initial)

Initial prototype:
- Perl
- command-line interface
- JSON-based storage
- Markdown export

Future possibilities:
- local-first web version
- Next.js interface
- optional Supabase sync
- printable daily plans
- longitudinal reflection archive

The project intentionally begins small.

The goal is not feature completeness,
but discovering what reflective practices naturally persist.

---

## Early Prototype Commands

Planned initial commands:

```bash
./threshold.pl add
./threshold.pl today
./threshold.pl week
./threshold.pl export
