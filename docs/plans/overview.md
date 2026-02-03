# Overview

## Purpose

The long-term goal of this project is not only to have a product comparison tool, but to create a tool for planning pedalboard builds. The data about all of the pedals should expand to all pedal-related products, including pedalboards, power supplies, MIDI controllers, etc. so that users can use this tool to help them plan their pedalboard builds.

## Vision

The data collected and stored by this application will be a powerful tool to inform an AI agent so that it can help to plan a pedalboard build. This could be coupled with a tool like pedalplayground.com to also help visualize it. This would ideally enable a more detailed, granular pedalboard plan that takes multiple factors into account:

* Pedalboard layout, including space needed for plugs and cables
* Signal path, including sequence, send/return loops, series/parallel, etc.
* Power requirements
* Control needs (MIDI, CV, USB)
* Cabling, plug types

## Possible Solutions

AI could potentially:

* Set up a midi controller:
	* Ask the user the preferred workflow
	* Set up presets, banks, and pages
	* Set up the configuration using natural language prompts
	* Set up the devices
	* Explain the setup in plain language to educate the player
* Recommend power supplies based on:
	* Total number of power taps
	* Power input needs (international, battery, etc.)
	* Current available (per outlet and cumulative)
	* Size and profile (can it fit under the board?)
	* Expandability
* Recommend pedals based on:
	* Circuit types (bluesbreaker, screamer, bucket brigade, etc.)
	* Tags (transparent, mid-hump, mid-scoop, etc.)
	* Size
	* Mono/stereo
	* Jack position (topmount vs. side jacks)
	* MIDI implementation (CC, PC, independent presets)
	* Analog/digital
	* Expression-capable
	* Bypass type
	* Position in signal path