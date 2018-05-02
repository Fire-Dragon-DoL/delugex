defmodule Ex1.Events do
  defmodule Created do
    use Ex1.Event

    defevent([:campaign_id, :name])
  end

  defmodule Started do
    use Ex1.Event

    defevent([:campaign_id, :start_time])
  end
end
