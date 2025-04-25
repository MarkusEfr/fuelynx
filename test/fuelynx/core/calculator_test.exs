defmodule Fuelynx.Core.CalculatorTest do
  use ExUnit.Case, async: true
  alias Fuelynx.Core.Calculator

  @initial_mass 28_801

  @doc """
  Apollo 11 Mission Full Breakdown:

  Steps:
    1. Launch from Earth
    2. Land on Moon
    3. Launch from Moon
    4. Land on Earth

  Fuel calculations include additional fuel weight recursively.
  """

  test "Apollo 11 mission step-by-step fuel calculations" do
    # Step 1: Launch from Earth
    mass1 = @initial_mass
    fuel1 = Calculator.calculate_total_fuel(mass1, [{:launch, "Earth"}])
    assert fuel1 == 19_772

    # Step 2: Land on Moon (includes fuel from step 1)
    mass2 = mass1 + fuel1
    fuel2 = Calculator.calculate_total_fuel(mass2, [{:land, "Moon"}])
    assert fuel2 == 2648

    # Step 3: Launch from Moon (includes fuel from step 1 + 2)
    mass3 = mass2 + fuel2
    fuel3 = Calculator.calculate_total_fuel(mass3, [{:launch, "Moon"}])
    assert fuel3 == 3653

    # Step 4: Land on Earth (includes fuel from step 1 + 2 + 3)
    mass4 = mass3 + fuel3
    fuel4 = Calculator.calculate_total_fuel(mass4, [{:land, "Earth"}])
    assert fuel4 == 25_878

    # Final total
    total_fuel = fuel1 + fuel2 + fuel3 + fuel4
    assert total_fuel == 51_951
  end
end
