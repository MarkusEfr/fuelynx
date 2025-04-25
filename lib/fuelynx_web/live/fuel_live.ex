defmodule FuelynxWeb.FuelLive do
  use FuelynxWeb, :live_view
  alias Fuelynx.Core.Calculator

  @actions [:launch, :land]
  @planets ["Earth", "Moon", "Mars"]

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        mass: nil,
        steps: [%{action: :launch, planet: "Earth"}],
        result: nil,
        actions: @actions,
        planets: @planets,
        can_calculate: false
      )

    {:ok, socket}
  end

  def handle_event("add-step", _params, socket) do
    {:noreply,
     socket
     |> update(:steps, fn steps -> steps ++ [%{action: :launch, planet: "Earth"}] end)
     |> assign(:result, nil)
     |> evaluate_ready()}
  end

  def handle_event("remove-step", %{"index" => index}, socket) do
    new_steps =
      socket.assigns.steps
      |> List.delete_at(String.to_integer(index))

    {:noreply, socket |> assign(steps: new_steps, result: nil) |> evaluate_ready()}
  end

  def handle_event("mass-input", %{"mass" => val}, socket) do
    mass = String.trim(val)

    socket =
      case Integer.parse(mass) do
        {num, ""} when num > 0 ->
          assign(socket, mass: num)

        _ ->
          assign(socket, mass: nil)
      end

    {:noreply, socket |> assign(:result, nil) |> evaluate_ready()}
  end

  def handle_event("calculate", %{"mass" => _mass_str, "step" => step_map}, socket) do
    steps =
      step_map
      |> Map.to_list()
      |> Enum.sort_by(fn {k, _} -> String.to_integer(k) end)
      |> Enum.map(fn {_k, %{"action" => a, "planet" => p}} ->
        %{action: String.to_atom(a), planet: p}
      end)

    result_steps = Enum.map(steps, fn %{action: a, planet: p} -> {a, p} end)

    result = Calculator.calculate_total_fuel(socket.assigns.mass, result_steps)

    {:noreply, assign(socket, steps: steps, result: result)}
  end

  defp evaluate_ready(socket) do
    valid =
      socket.assigns.mass &&
        Enum.all?(socket.assigns.steps, fn %{action: a, planet: p} -> a && p end)

    assign(socket, can_calculate: valid)
  end

  def render(assigns) do
    ~H"""
    <div class="p-6 max-w-2xl mx-auto space-y-6 bg-white rounded shadow">
      <h1 class="text-3xl font-bold text-center text-sky-800">Mission Fuel Planner</h1>
      <p class="text-center text-gray-600 mb-4">Enter your mass and define your flight steps.</p>

      <.form for={%{}} phx-change="mass-input" phx-submit="calculate">
        <div class="space-y-4">
          <label class="block">
            <span class="text-sm font-medium">Mass (kg)</span>
            <input
              type="number"
              name="mass"
              value={@mass || ""}
              class="input input-bordered w-full"
              required
            />
          </label>

          <div class="space-y-4">
            <%= for {step, index} <- Enum.with_index(@steps) do %>
              <div class="flex flex-col border p-3 rounded-md bg-gray-50">
                <div class="flex justify-between items-center mb-2">
                  <span class="text-sm font-semibold text-gray-600">
                    Step <%= index + 1 %>
                  </span>
                  <button
                    type="button"
                    phx-click="remove-step"
                    phx-value-index={index}
                    class="btn btn-xs btn-outline btn-error"
                  >
                    Remove
                  </button>
                </div>

                <div class="flex gap-2">
                  <select name={"step[#{index}][action]"} class="select select-bordered w-1/2" required>
                    <%= for a <- @actions do %>
                      <option value={Atom.to_string(a)} selected={step.action == a}>
                        {Atom.to_string(a)}
                      </option>
                    <% end %>
                  </select>

                  <select name={"step[#{index}][planet]"} class="select select-bordered w-1/2" required>
                    <%= for p <- @planets do %>
                      <option value={p} selected={step.planet == p}>{p}</option>
                    <% end %>
                  </select>
                </div>
              </div>
            <% end %>

            <button type="button" phx-click="add-step" class="btn btn-sm btn-secondary mt-2">
              Add Step
            </button>
          </div>

          <button class="btn btn-primary w-full mt-4" type="submit" disabled={!@can_calculate}>
            Calculate
          </button>
        </div>
      </.form>

      <%= if @result do %>
        <div class="text-center mt-6">
          <p class="text-lg font-semibold text-gray-700">Total Fuel Required:</p>
          <p class="text-3xl text-green-600 font-bold">{@result} kg</p>
        </div>
      <% end %>
    </div>
    """
  end
end
