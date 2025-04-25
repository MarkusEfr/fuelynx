defmodule Fuelynx.Core.Calculator do
  @moduledoc """
  NASA-spec fuel calculator with proper mass accumulation.

  Calculates fuel recursively for each step and adds fuel's mass to next.
  """

  @gravity %{
    "Earth" => 9.807,
    "Moon" => 1.62,
    "Mars" => 3.711
  }

  @type planet :: String.t()
  @type action :: :launch | :land
  @type step :: {action, planet}

  @spec calculate_total_fuel(pos_integer(), [step()]) :: non_neg_integer()
  def calculate_total_fuel(initial_mass, steps) when initial_mass > 0 do
    {total_fuel, _final_mass} =
      Enum.reduce(Enum.with_index(steps), {0, initial_mass}, fn {{action, planet}, _index},
                                                                {fuel_acc, current_mass} ->
        gravity = Map.fetch!(@gravity, planet)
        step_fuel = fuel_required(current_mass, action, gravity)
        {fuel_acc + step_fuel, current_mass + step_fuel}
      end)

    total_fuel
  end

  defp fuel_required(mass, action, gravity) do
    {factor, offset} =
      case action do
        :launch -> {0.042, 33}
        :land -> {0.033, 42}
      end

    recursive_fuel(mass, gravity, factor, offset, 1)
  end

  defp recursive_fuel(mass, gravity, factor, offset, depth) do
    raw = mass * gravity * factor
    fuel = Float.floor(raw - offset) |> trunc()

    if fuel > 0 do
      fuel + recursive_fuel(fuel, gravity, factor, offset, depth + 1)
    else
      0
    end
  end
end
