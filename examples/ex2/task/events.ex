defmodule Ex2.Task.Events do
  defmodule Created do
    defstruct [:id, :position, :metadata, :campaign_id, :name]
  end

  defmodule Started do
    defstruct [:id, :position, :metadata, :campaign_id, :start_time]
  end

  def transform("Created", event) do
    %Created{
      id: event.id,
      position: event.position,
      metadata: event.metadata,
      campaign_id: event.campaign_id,
      name: event.name
    }
  end

  def transform("Started", event) do
    %Started{
      id: event.id,
      position: event.position,
      metadata: event.metadata,
      campaign_id: event.campaign_id,
      start_time: event.start_time
    }
  end

  def transform(_, event) do
    event
  end
end
