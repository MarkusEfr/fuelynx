# Fuelynx – Interplanetary Fuel Calculator

**Fuelynx** is a Phoenix LiveView app that calculates the fuel required for space missions using NASA-style physics.

## Features

- Dynamic flight path builder (launch/land on Earth, Moon, Mars)
- Real-time fuel calculations
- Recursive mass accumulation logic
- Built with Elixir, Phoenix 1.8, and LiveView
- No database required

## Calculation Logic

- **Launch:** `mass * gravity * 0.042 - 33`
- **Land:** `mass * gravity * 0.033 - 42`
- Fuel weight recursively adds more fuel.

## Usage

```bash
mix deps.get
mix phx.server
